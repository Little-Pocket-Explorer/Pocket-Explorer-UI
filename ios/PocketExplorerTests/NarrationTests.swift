import AVFoundation
import XCTest
@testable import PocketExplorer

final class NarrationHTTPProtocol: URLProtocol {
    static var response: ((URLRequest) throws -> (Int, String, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, mime, data) = try Self.response!(request)
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: ["Content-Type": mime])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

@MainActor
final class NarrationTests: XCTestCase {
    private var directory: URL!
    private var client: NarrationClient!
    private let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    private var record: ExplorationRecord {
        ExplorationRecord(id: UUID(), question: "Why is the sky blue?", language: "en", age: 7, createdAt: Date(),
                          reply: AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Look up.", category: "science", artworkPrompt: "Sky",
                                         quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air.")))
    }
    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [NarrationHTTPProtocol.self]
        client = NarrationClient(session: URLSession(configuration: configuration), directory: directory, permission: { _ in })
    }
    override func tearDown() async throws { try? FileManager.default.removeItem(at: directory); NarrationHTTPProtocol.response = nil }

    static func wave() -> Data {
        var bytes = [UInt8](repeating: 1, count: 9644)
        func word(_ offset: Int, _ value: String) { bytes.replaceSubrange(offset..<offset + 4, with: value.utf8) }
        func number(_ offset: Int, _ value: Int, count: Int = 4) {
            for index in 0..<count { bytes[offset + index] = UInt8((value >> (index * 8)) & 255) }
        }
        word(0, "RIFF"); number(4, bytes.count - 8); word(8, "WAVE"); word(12, "fmt "); number(16, 16)
        number(20, 1, count: 2); number(22, 1, count: 2); number(24, 24000); number(28, 48000)
        number(32, 2, count: 2); number(34, 16, count: 2); word(36, "data"); number(40, 9600)
        return Data(bytes)
    }
    func testDownloadsOwnedAudioAndReusesDiskCacheAfterRecreationWithoutCredentialsInNames() async throws {
        let record = record
        var calls = 0
        NarrationHTTPProtocol.response = { request in
            calls += 1
            XCTAssertEqual(request.url?.path, "/api/narration/\(record.id.uuidString.lowercased())")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            XCTAssertEqual(request.timeoutInterval, 12)
            return (200, "audio/wav", Self.wave())
        }
        let first = try await client.audio(for: record, connection: connection)
        XCTAssertEqual(first, Self.wave())
        let second = try await NarrationClient(session: client.session, directory: directory, permission: { _ in }).audio(for: record, connection: connection)
        XCTAssertEqual(second, first); XCTAssertEqual(calls, 1)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 1); XCTAssertEqual(files[0].lastPathComponent.count, 68)
        XCTAssertEqual(try Data(contentsOf: files[0]), first)
    }
    func testCacheSeparatesAnswerLanguageOwnerAndOriginAndExpires() async throws {
        var calls = 0
        NarrationHTTPProtocol.response = { _ in calls += 1; return (200, "audio/wav", Self.wave()) }
        let record = record
        _ = try await client.audio(for: record, connection: connection)
        var translated = record; translated.language = "zh-Hans"
        _ = try await client.audio(for: translated, connection: connection)
        translated.reply?.answer = "A different answer."
        _ = try await client.audio(for: translated, connection: connection)
        _ = try await client.audio(for: record, connection: ShareConnection(baseURL: connection.baseURL, ownerKey: String(repeating: "b", count: 64)))
        _ = try await client.audio(for: record, connection: ShareConnection(baseURL: "https://another.example", ownerKey: connection.ownerKey))
        client.now = Date().addingTimeInterval(31 * 86400)
        _ = try await client.audio(for: record, connection: connection)
        XCTAssertEqual(calls, 6)
    }
    func testRejectsFailuresRedirectsHTMLTruncationAndOversizeWithoutCaching() async {
        for (status, mime, bytes) in [(429, "audio/wav", Self.wave()), (302, "audio/wav", Self.wave()), (200, "text/html", Self.wave()), (200, "audio/wav", Data()), (200, "audio/wav", Data(repeating: 1, count: 12_000_001))] {
            NarrationHTTPProtocol.response = { _ in (status, mime, bytes) }
            do { _ = try await client.audio(for: record, connection: connection); XCTFail("Must reject") } catch {}
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path))
        XCTAssertFalse(NarrationClient.isAudio(Data(repeating: 1, count: 100)))
        var damaged = Self.wave(); damaged[8] = 0; XCTAssertFalse(NarrationClient.isAudio(damaged))
        var falseHeader = Data(repeating: 0, count: 100)
        falseHeader.replaceSubrange(0..<4, with: Data("RIFF".utf8))
        falseHeader.replaceSubrange(8..<12, with: Data("WAVE".utf8))
        XCTAssertFalse(NarrationClient.isAudio(falseHeader))
        var incomplete = record; incomplete.reply = nil
        do { _ = try await client.audio(for: incomplete, connection: connection); XCTFail() } catch {}
        do { _ = try await client.audio(for: record, connection: ShareConnection(baseURL: "http://unsafe.example", ownerKey: "bad")); XCTFail() } catch {}
    }
    func testBadCacheIsReplacedAndDiskFailuresDoNotPreventPlayback() async throws {
        NarrationHTTPProtocol.response = { _ in (200, "audio/wav", Self.wave()) }
        let record = record
        _ = try await client.audio(for: record, connection: connection)
        let file = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)[0]
        try Data("corrupt".utf8).write(to: file)
        let recovered = try await client.audio(for: record, connection: connection)
        XCTAssertEqual(recovered, Self.wave()); XCTAssertEqual(try Data(contentsOf: file), Self.wave())
        let blocked = directory.appendingPathComponent("file"); try Data().write(to: blocked)
        client.directory = blocked
        let uncached = try await client.audio(for: record, connection: connection)
        XCTAssertEqual(uncached, Self.wave())
    }
    func testPrunesOldestFilesWhenCacheExceedsBudget() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let old = directory.appendingPathComponent("old.wav")
        try Data(repeating: 1, count: 32_000_000).write(to: old)
        try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(-1000)], ofItemAtPath: old.path)
        NarrationHTTPProtocol.response = { _ in (200, "audio/wav", Self.wave()) }
        _ = try await client.audio(for: record, connection: connection)
        XCTAssertFalse(FileManager.default.fileExists(atPath: old.path))
    }
    func testRefusesRedirectAndPropagatesTimeout() async {
        let session = URLSession(configuration: .ephemeral)
        let url = URL(string: "https://pocket.example")!
        let request = URLRequest(url: url)
        NarrationRedirectPolicy().urlSession(session, task: session.dataTask(with: request), willPerformHTTPRedirection: HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)!, newRequest: request) { XCTAssertNil($0) }
        NarrationHTTPProtocol.response = { _ in throw URLError(.timedOut) }
        do { _ = try await client.audio(for: record, connection: connection); XCTFail() } catch { XCTAssertEqual((error as? URLError)?.code, .timedOut) }
    }
    func testCloudPlaybackSuccessFallsBackOnFailureAndUsesContentLanguage() async throws {
        let hardware = FakeVoiceTransport(); let voice = VoiceSession(transport: hardware)
        var finished = 0; voice.onFinishedSpeaking = { finished += 1 }
        try voice.speak("Hello", language: "en", cloud: { Self.wave() })
        for _ in 0..<100 where hardware.played == nil { await Task.yield() }
        XCTAssertEqual(hardware.played, Self.wave()); XCTAssertEqual(hardware.spoken, "")
        hardware.onFinishedSpeaking?(); XCTAssertEqual(finished, 1)
        hardware.playError = true
        try voice.speak("你好", language: "zh-Hans", cloud: { Self.wave() })
        for _ in 0..<100 where hardware.spoken.isEmpty { await Task.yield() }
        XCTAssertEqual(hardware.spoken, "你好"); XCTAssertEqual(hardware.spokenLanguage, "zh-Hans")
        hardware.spoken = ""; hardware.playError = false
        try voice.speak("Offline reply", cloud: { throw URLError(.notConnectedToInternet) })
        for _ in 0..<100 where hardware.spoken.isEmpty { await Task.yield() }
        XCTAssertEqual(hardware.spoken, "Offline reply")
    }
    func testStopNavigationAndInterruptionSuppressLateAudioAndFallback() async throws {
        for fail in [false, true] {
            let hardware = FakeVoiceTransport(); let voice = VoiceSession(transport: hardware)
            var pending: CheckedContinuation<Data, Error>?
            try voice.speak("Stale words", cloud: { try await withCheckedThrowingContinuation { pending = $0 } })
            while pending == nil { await Task.yield() }
            voice.stop()
            if fail { pending?.resume(throwing: URLError(.timedOut)) } else { pending?.resume(returning: Self.wave()) }
            for _ in 0..<10 { await Task.yield() }
            XCTAssertNil(hardware.played); XCTAssertEqual(hardware.spoken, "")
        }
    }
    func testDoubleFailureAndAsynchronousPlayerFailureFinishTheSession() async throws {
        let hardware = FakeVoiceTransport(); let voice = VoiceSession(transport: hardware)
        hardware.speakError = true
        var errors = 0; voice.onError = { _ in errors += 1 }
        try voice.speak("Hello", cloud: { throw VoiceError.unavailable })
        for _ in 0..<100 where errors == 0 { await Task.yield() }
        XCTAssertEqual(errors, 1)
        hardware.speakError = false
        try voice.speak("Hello", cloud: { Self.wave() })
        for _ in 0..<100 where hardware.played == nil { await Task.yield() }
        let stale = hardware.onError; hardware.onError?("Decode failure")
        XCTAssertEqual(errors, 2); stale?("Stale failure"); XCTAssertEqual(errors, 2)
    }
    func testActualPCMPlaybackCompletesAndRejectsInvalidAudio() async throws {
        let transport = SystemVoiceTransport()
        XCTAssertThrowsError(try transport.play(Data("bad".utf8)))
        let finished = expectation(description: "PCM playback completed")
        transport.onFinishedSpeaking = { finished.fulfill() }
        try transport.play(Self.wave())
        await fulfillment(of: [finished], timeout: 5)
        transport.stop()
    }
}
