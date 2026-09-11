import XCTest
import Security
@testable import PocketExplorer

final class MockShareProtocol: URLProtocol {
    static var reply: ((URLRequest) throws -> (Int, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, data) = try Self.reply!(request)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

final class SharingTests: XCTestCase {
    private let connection = ShareConnection(baseURL: "https://stories.example", ownerKey: String(repeating: "x", count: 40))
    private var client: ShareClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockShareProtocol.self]
        return ShareClient(session: URLSession(configuration: config))
    }
    private var story: PublicStory {
        let state = JournalState.examples()
        return .make(trip: state.trips[0], discoveries: [state.discoveries[0]])
    }

    func testPublicExportMatchesSharedFixtureAndExcludesPrivateInformation() throws {
        let fixture = Bundle(for: Self.self).url(forResource: "public-story-v1", withExtension: "json")!
        XCTAssertEqual(try JSONDecoder().decode(PublicStory.self, from: Data(contentsOf: fixture)), story)
        let state = JournalState.examples()
        let publicStory = PublicStory.make(trip: state.trips[0], discoveries: state.discoveries)
        XCTAssertEqual(publicStory.cards.count, 2)
        XCTAssertNil(publicStory.firstName)
        XCTAssertNil(publicStory.city)
        let text = String(data: try JSONEncoder().encode(publicStory), encoding: .utf8)!
        for field in ["latitude", "longitude", "photoFilename", "createdAt", "tripID", "rawRecording", "unlockedAt", "origin", "tier"] { XCTAssertFalse(text.contains(field)) }
        let included = PublicStory.make(trip: state.trips[0], discoveries: state.discoveries, firstName: " Alex ", includeCity: true)
        XCTAssertEqual(included.firstName, "Alex")
        XCTAssertEqual(included.city, "Sydney")
        XCTAssertNil(PublicStory.make(trip: state.trips[0], discoveries: state.discoveries, firstName: " ").firstName)
    }

    func testCreateAndRevokeUseOwnerAuthorizationAndReturnedURL() async throws {
        let token = String(repeating: "a", count: 32)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/shares")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            return (201, Data("{\"token\":\"\(token)\",\"url\":\"https://stories.example/s/\(token)\"}".utf8))
        }
        let receipt = try await client.create(story, connection: connection)
        XCTAssertEqual(receipt.url.absoluteString, "https://stories.example/s/\(token)")
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            XCTAssertEqual(request.url?.path, "/api/shares/\(token)")
            return (204, Data())
        }
        try await client.revoke(receipt, connection: connection)
        let persisted = PublishedShare(receipt: receipt, story: story)
        XCTAssertEqual(try JSONDecoder().decode(PublishedShare.self, from: JSONEncoder().encode(persisted)), persisted)
    }

    func testFailuresAndUntrustedURLsNeverProduceAUsableReceipt() async {
        for status in [401, 403, 429, 500, 200] {
            MockShareProtocol.reply = { _ in (status, Data()) }
            do { _ = try await client.create(story, connection: connection); XCTFail("Expected failure") }
            catch { XCTAssertFalse(error.localizedDescription.isEmpty) }
        }
        for (token, url) in [("short", "https://stories.example/s/short"), (String(repeating: "a", count: 32), "https://other.example/s/" + String(repeating: "a", count: 32))] {
            MockShareProtocol.reply = { _ in (201, Data("{\"token\":\"\(token)\",\"url\":\"\(url)\"}".utf8)) }
            do { _ = try await client.create(story, connection: connection); XCTFail("Expected rejection") } catch {}
        }
        MockShareProtocol.reply = { _ in throw URLError(.timedOut) }
        do { _ = try await client.create(story, connection: connection); XCTFail() } catch {}
        do { _ = try await client.create(story, connection: ShareConnection(baseURL: "", ownerKey: "")); XCTFail() } catch {}
        let invalid = ShareReceipt(token: "invalid", url: URL(string: "https://other.example")!)
        do { try await client.revoke(invalid, connection: connection); XCTFail() } catch {}
        let token = String(repeating: "b", count: 32)
        MockShareProtocol.reply = { _ in (500, Data()) }
        do { try await client.revoke(ShareReceipt(token: token, url: URL(string: "https://stories.example/s/\(token)")!), connection: connection); XCTFail() } catch {}
    }

    func testConnectionValidationAndActualKeychainRoundTrip() throws {
        for url in ["", "http://public.example", "https://stories.example/path", "https://user:pass@stories.example", "https://stories.example/?q=x", "https://stories.example/#x"] {
            XCTAssertNil(ShareConnection(baseURL: url, ownerKey: connection.ownerKey).validatedURL)
        }
        XCTAssertNotNil(ShareConnection(baseURL: "http://localhost:4174", ownerKey: connection.ownerKey).validatedURL)
        XCTAssertNotNil(ShareConnection(baseURL: "http://127.0.0.1:4174", ownerKey: connection.ownerKey).validatedURL)
        XCTAssertNil(ShareConnection(baseURL: connection.baseURL, ownerKey: "short").validatedURL)
        let vault = ConnectionVault(service: "pocket-test-\(UUID())")
        defer { SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrService: vault.service] as CFDictionary) }
        XCTAssertNil(try vault.read())
        try vault.save(connection)
        XCTAssertEqual(try ConnectionVault(service: vault.service).read(), connection)
        XCTAssertEqual(try vault.loadOrCreate(), connection, "Existing ownership must survive an app update")
        let changed = ShareConnection(baseURL: "https://second.example", ownerKey: String(repeating: "b", count: 40))
        try vault.save(changed)
        XCTAssertEqual(try ConnectionVault(service: vault.service).read(), changed)
        XCTAssertThrowsError(try vault.save(ShareConnection(baseURL: "", ownerKey: "")))
        for error in [ShareError.configuration, .unauthorized, .unavailable, .invalidResponse, .rateLimited] { XCTAssertNotNil(error.errorDescription) }
        for error in [VoiceError.microphoneDenied, .speechDenied, .unavailable] { XCTAssertNotNil(error.errorDescription) }
        for error in [JournalError.emptyObservation, .emptyQuestion, .missingTrip, .missingDiscovery, .emptyTrip, .invalidVersion] { XCTAssertNotNil(error.errorDescription) }
        for subject in DiscoverySubject.allCases { XCTAssertFalse(subject.sampleQuestion.isEmpty); XCTAssertEqual(subject.id, subject.rawValue) }
    }

    func testFreshInstallationSavesItsOwnCredentialBeforeNetworkingAndRetainsItAfterFailure() async throws {
        let first = ConnectionVault(service: "pocket-test-\(UUID())")
        let second = ConnectionVault(service: "pocket-test-\(UUID())")
        defer {
            for vault in [first, second] { SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrService: vault.service] as CFDictionary) }
        }
        let automatic = try first.loadOrCreate()
        XCTAssertEqual(automatic.baseURL, "https://pocket.changhai.me")
        XCTAssertNotNil(automatic.ownerKey.range(of: "^pe1_[a-f0-9]{64}$", options: .regularExpression))
        XCTAssertEqual(try ConnectionVault(service: first.service).read(), automatic)
        XCTAssertNotEqual(try second.loadOrCreate().ownerKey, automatic.ownerKey)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(automatic.ownerKey)")
            XCTAssertEqual(try ConnectionVault(service: first.service).read(), automatic)
            throw URLError(.notConnectedToInternet)
        }
        do { _ = try await client.create(story, connection: automatic); XCTFail("Expected offline failure") } catch {}
        XCTAssertEqual(try first.loadOrCreate(), automatic)
        let token = String(repeating: "r", count: 32)
        MockShareProtocol.reply = { _ in (201, Data("{\"token\":\"\(token)\",\"url\":\"https://pocket.changhai.me/s/\(token)\"}".utf8)) }
        let receipt = try await client.create(story, connection: automatic)
        XCTAssertEqual(receipt.token, token)
    }
}
