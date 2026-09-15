import CryptoKit
import UIKit
import XCTest
@testable import PocketExplorer

final class DiscoveryHTTPProtocol: URLProtocol {
    static var respond: ((URLRequest) throws -> (Int, [String: String], Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, headers, data) = try Self.respond!(request)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers)!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

@MainActor
final class PreparedDiscoveryTests: XCTestCase {
    var directory: URL!
    var session: URLSession!
    let now = Date(timeIntervalSince1970: 1_800_000_000)
    let utc = TimeZone(secondsFromGMT: 0)!
    let base = URL(string: "https://pocket.example")!
    var language: LanguagePreference?
    let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [DiscoveryHTTPProtocol.self]
        session = URLSession(configuration: config)
        language = LanguageSettings.selection
        LanguageSettings.save(.english)
    }
    override func tearDown() async throws {
        if let language { LanguageSettings.save(language) } else { LanguageSettings.preferences.removeObject(forKey: "app-language") }
        session.invalidateAndCancel()
        DiscoveryHTTPProtocol.respond = nil
        try? FileManager.default.removeItem(at: directory)
    }
    static func image() -> Data {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024), format: format).image { context in
            UIColor.blue.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
        }.pngData()!
    }
    static func asset(_ data: Data, kind: String) -> PreparedAsset {
        let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        return PreparedAsset(path: "/api/knowledge-assets/\(hash).\(kind)", sha256: hash, bytes: data.count)
    }
    func item(_ index: Int = 0, language: String = "en") -> PreparedContent {
        PreparedContent(id: String(format: "11111111-1111-4111-8111-%012d", index), version: 1, topicID: "topic-\(index)", language: language, minAge: 5, maxAge: 18,
            question: "Why does the sky look blue? \(index)",
            reply: AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Notice the sky.", category: index % 2 == 0 ? "science" : "nature", artworkPrompt: "Sky",
                quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air scatters blue light.")),
            policy: "discovery-v1", verifiedAt: now.addingTimeInterval(-86400).timeIntervalSince1970 * 1000,
            reviewAt: now.addingTimeInterval(30 * 86400).timeIntervalSince1970 * 1000, expiresAt: now.addingTimeInterval(90 * 86400).timeIntervalSince1970 * 1000,
            artwork: Self.asset(Self.image(), kind: "png"), narration: Self.asset(NarrationTests.wave(), kind: "wav"), speechRevision: "fixture-v1",
            sources: [PreparedSource(url: "https://spaceplace.nasa.gov/blue-sky/en/", sha256: String(repeating: "a", count: 64))])
    }
    func catalog(_ items: [PreparedContent], revision: String = "1", withdrawals: [ContentWithdrawal] = []) -> RecommendationCatalog {
        RecommendationCatalog(schemaVersion: 1, revision: revision, serverTime: now.timeIntervalSince1970 * 1000, refreshAfterSeconds: 21600, items: items, withdrawals: withdrawals)
    }
    func store(_ items: [PreparedContent], name: String = "bank.json") -> RecommendationStore {
        RecommendationStore(file: directory.appendingPathComponent(name), bundled: items, client: RecommendationClient(session: session))
    }
    func respond(_ catalog: RecommendationCatalog) throws {
        let data = try JSONEncoder().encode(catalog)
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            return (200, ["Content-Type": "application/json", "ETag": "\"\(catalog.revision)\""], data)
        }
    }
    func testPersistentDailySelectionSurvivesDownloadRelaunchTimezoneAndClockRollback() async throws {
        let old = (0..<9).map { item($0) }, fresh = (10..<40).map { item($0) }
        let store = store(old)
        let first = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        XCTAssertEqual(first.items.count, 3)
        try respond(catalog(fresh))
        await store.synchronize(base: base, language: "en", age: 7, now: now)
        XCTAssertEqual(store.items, first.items)
        let recreated = self.store([])
        let same = try recreated.activate(language: "en", age: 7, now: now.addingTimeInterval(3600), timeZone: TimeZone(identifier: "Pacific/Auckland")!)
        XCTAssertEqual(same, first)
        XCTAssertEqual(try recreated.activate(language: "en", age: 7, now: now.addingTimeInterval(-86400), timeZone: utc), first)
        let next = try recreated.activate(language: "en", age: 7, now: first.rolloverAt, timeZone: utc)
        XCTAssertEqual(next.items.count, 3)
        XCTAssertTrue(Set(next.items.map(\.topicID)).isDisjoint(with: first.items.map(\.topicID)))
        XCTAssertTrue(next.items.allSatisfy { fresh.contains($0) })
        XCTAssertEqual(try self.store([]).activate(language: "en", age: 7, now: next.createdAt, timeZone: utc), next)
    }
    func testLanguageAgeContextsAndSevenDayAvoidanceWithSmallBankFallback() throws {
        let english = (0..<30).map { item($0) }
        let store = store(english + (0..<6).map { item($0, language: "zh-Hans") })
        let first = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        let chinese = try store.activate(language: "zh-Hans", age: 7, now: now, timeZone: utc)
        XCTAssertTrue(chinese.items.allSatisfy { $0.language == "zh-Hans" })
        XCTAssertEqual(try store.activate(language: "en", age: 7, now: now, timeZone: utc), first)
        XCTAssertNotEqual(try store.activate(language: "en", age: 8, now: now, timeZone: utc).context, first.context)
        var history: [String: Date] = [:]
        for index in 0..<8 {
            let time = now.addingTimeInterval(Double(index) * 86400)
            let selection = DailySelection.make(candidates: english, previous: nil, history: history, language: "en", age: 7, now: time, timeZone: utc, seed: "stable")
            XCTAssertTrue(selection.items.allSatisfy { history[$0.topicID] == nil })
            for item in selection.items { history[item.topicID] = time }
        }
        let short = DailySelection.make(candidates: [item(), item()], previous: nil, history: [item().topicID: now], language: "en", age: 7, now: now, timeZone: utc, seed: "small")
        XCTAssertEqual(short.items.count, 1)
        var expired = item(31); expired.expiresAt = now.timeIntervalSince1970 * 1000
        var young = item(32); young.maxAge = 6
        XCTAssertTrue(DailySelection.make(candidates: [expired, young], previous: nil, history: [:], language: "en", age: 7, now: now, timeZone: utc, seed: "small").items.isEmpty)
    }
    func testWithdrawalRemovesWithoutReplacementAnd304PreservesCandidateBank() async throws {
        let old = (0..<9).map { item($0) }, store = store((0..<9).map { item($0) })
        let first = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        let withdrawn = first.items[0]
        try respond(catalog(old.filter { $0.id != withdrawn.id }, withdrawals: [ContentWithdrawal(id: withdrawn.id, version: withdrawn.version, reason: "correcting")]))
        await store.synchronize(base: base, language: "en", age: 7, now: now)
        XCTAssertEqual(store.items, Array(first.items.dropFirst())); XCTAssertEqual(store.removedCount, 1)
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "If-None-Match"), "\"1\"")
            return (304, [:], Data())
        }
        await store.synchronize(base: base, language: "en", age: 7, now: now.addingTimeInterval(21601))
        let restored = self.store([])
        XCTAssertTrue(restored.isWithdrawn(withdrawn.reference))
        XCTAssertFalse(restored.isWithdrawn(first.items[1].reference))
        XCTAssertEqual(try restored.activate(language: "en", age: 7, now: now, timeZone: utc).items, Array(first.items.dropFirst()))
        XCTAssertFalse(try restored.activate(language: "en", age: 7, now: first.rolloverAt, timeZone: utc).items.contains(withdrawn))
    }
    func testFailuresRateLimitCorruptDiskAndWriteFailureRetainLastGoodSnapshot() async throws {
        let file = directory.appendingPathComponent("bank.json")
        try Data("corrupt".utf8).write(to: file)
        let store = store((0..<6).map { item($0) })
        let first = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        var calls = 0
        DiscoveryHTTPProtocol.respond = { _ in calls += 1; return (429, ["Retry-After": "3600"], Data()) }
        await store.synchronize(base: base, language: "en", age: 7, now: now)
        await store.synchronize(base: base, language: "en", age: 7, now: now.addingTimeInterval(60), force: true)
        XCTAssertEqual(calls, 1); XCTAssertEqual(store.items, first.items)
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await store.synchronize(base: base, language: "en", age: 7, now: now.addingTimeInterval(3601))
        XCTAssertEqual(store.items, first.items)
        let blocked = RecommendationStore(file: file, bundled: [], writer: { _, _ in throw CocoaError(.fileWriteOutOfSpace) })
        XCTAssertThrowsError(try blocked.activate(language: "en", age: 7, now: first.rolloverAt, timeZone: utc))
        XCTAssertEqual(try self.store([]).activate(language: "en", age: 7, now: now, timeZone: utc), first)
        let empty = self.store([], name: "empty.json")
        XCTAssertTrue(try empty.activate(language: "en", age: 7, now: now, timeZone: utc).items.isEmpty)
        try respond(catalog([item()]))
        await empty.synchronize(base: base, language: "en", age: 7, now: now)
        XCTAssertEqual(try empty.activate(language: "en", age: 7, now: now, timeZone: utc).items.count, 1)
    }
    func testClientRejectsMalformedWrongLanguageMissingAudioAndUnsafeAssetPaths() async throws {
        let client = RecommendationClient(session: session)
        var bad = item(); bad.artwork.path = "/api/private-photo"; XCTAssertFalse(bad.isValid)
        let candidates = [catalog([item(0, language: "zh-Hans")]), catalog([item(), item()]), catalog([bad])]
        for candidate in candidates {
            try respond(candidate)
            do { _ = try await client.fetch(base: base, language: "en", age: 7, etag: nil); XCTFail("Invalid catalog accepted") } catch {}
        }
        var noAudio = item(); noAudio.narration = nil
        try respond(catalog([noAudio]))
        do { _ = try await client.fetch(base: base, language: "en", age: 7, etag: nil); XCTFail() } catch {}
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data("broken".utf8)) }
        do { _ = try await client.fetch(base: base, language: "en", age: 7, etag: nil); XCTFail() } catch {}
        DiscoveryHTTPProtocol.respond = { _ in (503, ["Retry-After": "99999999"], Data()) }
        do { _ = try await client.fetch(base: base, language: "en", age: 7, etag: nil); XCTFail() }
        catch RecommendationError.retryAfter(let delay) { XCTAssertEqual(delay, 86400) }
    }
    func testPreparedAssetDownloadsVerifyHashesCacheAndNeverSendCredentials() async throws {
        let cache = PreparedAssets(directory: directory, session: session)
        let data = Self.image(), asset = Self.asset(Self.image(), kind: "png")
        var calls = 0
        DiscoveryHTTPProtocol.respond = { request in
            calls += 1; XCTAssertNil(request.value(forHTTPHeaderField: "Authorization")); XCTAssertEqual(request.url?.path, asset.path)
            return (200, ["Content-Type": "image/png"], data)
        }
        let loaded = try await cache.load(asset, base: base); XCTAssertEqual(loaded, data)
        let cached = try await cache.load(asset, base: base); XCTAssertEqual(cached, data); XCTAssertEqual(calls, 1)
        XCTAssertEqual(PreparedAssets(directory: directory).cached(asset), data)
        XCTAssertFalse(cache.valid(Data("bad".utf8), for: asset))
        let invalid = Self.asset(Data("bad".utf8), kind: "png")
        XCTAssertFalse(cache.valid(Data("bad".utf8), for: invalid))
        let wav = NarrationTests.wave(), sound = Self.asset(NarrationTests.wave(), kind: "wav")
        DiscoveryHTTPProtocol.respond = { _ in (200, ["Content-Type": "audio/wav"], wav) }
        let audio = try await cache.load(sound, base: base); XCTAssertEqual(audio, wav)
        var changed = sound; changed.sha256 = String(repeating: "f", count: 64)
        do { _ = try await cache.load(changed, base: base); XCTFail() } catch {}
        let broken = Self.asset(Data("not an image".utf8), kind: "png")
        DiscoveryHTTPProtocol.respond = { _ in (200, ["Content-Type": "image/png"], Data("not an image".utf8)) }
        do { _ = try await cache.load(broken, base: base); XCTFail() } catch {}
        let folder = directory.appendingPathComponent("artwork")
        try Data(repeating: 0, count: 64_000_000).write(to: folder.appendingPathComponent("old.png"))
        cache.prune(protecting: [asset])
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.appendingPathComponent("old.png").path))
        XCTAssertEqual(cache.cached(asset), data)
    }
    func testOfflineCardHasImageBeforeServerRegistrationAndPersistsPersonalMetadata() async throws {
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let content = item()
        let question = try store.beginPrepared(content, age: 7, now: now)
        XCTAssertEqual(question.reply, content.reply)
        XCTAssertEqual(try store.beginPrepared(content, age: 7, id: question.id, now: now), question)
        let card = try store.keepQuestion(question.id, observation: "A clear afternoon", place: .sydney, now: now, preparedImage: Self.image())
        XCTAssertNil(card.artwork); XCTAssertNotNil(card.artworkFilename)
        XCTAssertEqual(try Data(contentsOf: store.mediaURL(card.artworkFilename!)), Self.image())
        let reopened = try TripStore(fileURL: store.fileURL)
        XCTAssertEqual(reopened.state.discoveries, [card]); XCTAssertEqual(reopened.questions[0].preparedContent, content)
        XCTAssertEqual(card.place, .sydney); XCTAssertEqual(card.observation, "A clear afternoon")
        XCTAssertThrowsError(try store.savePreparedArtwork(Data("bad".utf8), discoveryID: card.id, asset: content.artwork))
        try store.savePreparedArtwork(Self.image(), discoveryID: card.id, asset: content.artwork)
        XCTAssertThrowsError(try store.beginPrepared(content, age: 4, now: now))
        XCTAssertThrowsError(try store.beginPrepared(content, age: 7, now: content.expiry))
    }
    func testRegistrationDeduplicatesAndShareUsesReadyArtworkWithoutChangingWords() async throws {
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let content = item(), question = try store.beginPrepared(item(), age: 7, now: now)
        let card = try store.verifyTestCard(store.keepQuestion(question.id, preparedImage: Self.image()))
        let snapshot = PublicStory.make(trip: store.state.trips[0], discoveries: [card])
        let registration = PreparedRegistration(); registration.client = AIClient(session: session)
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "ready", attempts: 0, imagePath: nil)
        var calls = 0
        DiscoveryHTTPProtocol.respond = { request in
            calls += 1
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            let data: Data
            if request.url!.path.hasSuffix("/artwork") { data = try JSONEncoder().encode(job) }
            else { data = try JSONEncoder().encode(AIReceipt(id: question.id, question: content.question, status: "ready", reply: content.reply)) }
            return (200, ["Content-Type": "application/json"], data)
        }
        async let one = registration.register(question.id, store: store, connection: connection)
        async let two = registration.register(question.id, store: store, connection: connection)
        _ = try await (one, two)
        let result = try await registration.prepareShare(snapshot, store: store, connection: connection)
        XCTAssertEqual(calls, 2); XCTAssertEqual(result.cards[0].artworkID, job.id)
        var expected = snapshot; expected.cards[0].artworkID = job.id; XCTAssertEqual(result, expected)
        XCTAssertEqual(try TripStore(fileURL: store.fileURL).state.discoveries[0].artwork?.id, job.id)
        XCTAssertEqual(store.questions[0].preparedRegistered, true)
        await registration.refresh(store: store, now: now, connection: { self.connection }); XCTAssertEqual(calls, 2)
        try await registration.register(UUID(), store: store, connection: connection)
    }
    func testRegistrationFailureRetriesLaterAndNeverSubstitutesThePreparedAnswer() async throws {
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let question = try store.beginPrepared(item(), age: 7, now: now)
        let registration = PreparedRegistration(); registration.client = AIClient(session: session)
        var calls = 0
        DiscoveryHTTPProtocol.respond = { _ in calls += 1; throw URLError(.notConnectedToInternet) }
        await registration.refresh(store: store, now: now, connection: { self.connection })
        await registration.refresh(store: store, now: now.addingTimeInterval(59), connection: { self.connection })
        XCTAssertEqual(calls, 1)
        await registration.refresh(store: store, now: now.addingTimeInterval(61), connection: { self.connection })
        XCTAssertEqual(calls, 2); XCTAssertEqual(store.questions[0], question)
        var wrong = item().reply; wrong.answer = "A different answer"
        let data = try JSONEncoder().encode(AIReceipt(id: question.id, question: question.question, status: "ready", reply: wrong))
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], data) }
        do { try await registration.register(question.id, store: store, connection: connection); XCTFail() } catch {}
        XCTAssertEqual(store.questions[0], question)
    }
    func testPrefetchWarmsTodaysAndNextCandidatesAndHonorsRefreshCadence() async throws {
        let store = store((0..<12).map { item($0) })
        _ = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        try respond(catalog((0..<12).map { item($0) }))
        await store.synchronize(base: base, language: "en", age: 7, now: now)
        DiscoveryHTTPProtocol.respond = { request in
            if request.url!.path.hasSuffix(".png") { return (200, ["Content-Type": "image/png"], Self.image()) }
            if request.url!.path.hasSuffix(".wav") { return (200, ["Content-Type": "audio/wav"], NarrationTests.wave()) }
            XCTFail("Catalog should not refetch before six hours"); throw URLError(.badServerResponse)
        }
        await store.synchronize(base: base, language: "en", age: 7, now: now.addingTimeInterval(60))
        let cache = PreparedAssets(directory: directory.appendingPathComponent("assets"), session: session)
        await store.prefetch(base: base, cache: cache)
        XCTAssertNotNil(cache.cached(item().artwork)); XCTAssertNotNil(cache.cached(item().narration!))
        var client = NarrationClient(session: session); client.preparedAssets = cache
        var record = ExplorationRecord(id: UUID(), question: item().question, language: "en", age: 7, createdAt: now, reply: item().reply, preparedContent: item())
        let audio = try await client.audio(for: record, connection: connection); XCTAssertEqual(audio, NarrationTests.wave())
        record.preparedContent?.narration = nil
        do { _ = try await client.audio(for: record, connection: connection); XCTFail() } catch {}
    }

    func testWithdrawnRegistrationPersistsWithoutAutomaticRetryOrLosingTheCard() async throws {
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let question = try store.beginPrepared(item(), age: 7, now: now)
        let card = try store.verifyTestCard(store.keepQuestion(question.id, observation: "My own discovery", preparedImage: Self.image()))
        XCTAssertFalse(store.preparedContentNeedsUpdate(question.id))
        XCTAssertFalse(store.preparedContentNeedsUpdate(nil))
        let registration = PreparedRegistration(); registration.client = AIClient(session: session)
        var calls = 0
        DiscoveryHTTPProtocol.respond = { _ in
            calls += 1
            return (409, [:], Data("{\"error\":\"prepared_content_unavailable\"}".utf8))
        }
        await registration.refresh(store: store, now: now, connection: { self.connection })
        XCTAssertEqual(calls, 1)
        let reopened = try TripStore(fileURL: store.fileURL)
        XCTAssertEqual(reopened.questions[0].preparedUnavailable, true)
        XCTAssertEqual(reopened.questions[0].reply, question.reply)
        XCTAssertEqual(reopened.state.discoveries, [card])
        XCTAssertTrue(reopened.preparedContentNeedsUpdate(question.id))
        await registration.refresh(store: reopened, now: now.addingTimeInterval(86400), connection: { self.connection })
        let snapshot = PublicStory.make(trip: reopened.state.trips[0], discoveries: [card])
        do { _ = try await registration.prepareShare(snapshot, store: reopened, connection: connection); XCTFail("Withdrawn content cannot be registered for sharing") }
        catch { XCTAssertEqual(error as? AIClientError, .preparedUnavailable) }
        XCTAssertEqual(calls, 1)
        XCTAssertFalse(AIClientError.preparedUnavailable.allowsImmediateRetry)
        XCTAssertTrue(AIClientError.preparedUnavailable.localizedDescription.contains("can no longer be shared"))
        XCTAssertThrowsError(try reopened.markPreparedUnavailable(UUID()))
    }

    func testCollectedWithdrawalNoticePreservesRegisteredArtworkAndPersonalWords() async throws {
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        store.recommendations.client = RecommendationClient(session: session)
        let content = item(), question = try store.beginPrepared(item(), age: 7, now: now)
        let card = try store.keepQuestion(question.id, observation: "My own discovery", preparedImage: Self.image())
        let artwork = ArtworkJob(id: UUID().uuidString, status: "ready", attempts: 0)
        try store.markPreparedRegistered(question.id, artwork: artwork)
        try respond(catalog([], withdrawals: [ContentWithdrawal(id: content.id, version: content.version, reason: "correcting")]))
        await store.recommendations.synchronize(base: base, language: "en", age: 7, now: now)
        XCTAssertTrue(store.preparedContentNeedsUpdate(question.id))
        XCTAssertEqual(store.questions[0].preparedArtwork, artwork)
        XCTAssertEqual(store.state.discoveries[0].observation, card.observation)
        XCTAssertTrue(try TripStore(fileURL: store.fileURL).preparedContentNeedsUpdate(question.id))
    }

    func testFoundationBundleHasSixCompleteTopicsInEveryLanguageAndVerifiedOfflineArt() throws {
        let file = try XCTUnwrap(Bundle.main.url(forResource: "prepared-discoveries", withExtension: "json"))
        let items = try JSONDecoder().decode([PreparedContent].self, from: Data(contentsOf: file))
        XCTAssertEqual(items.count, 60)
        let cache = PreparedAssets(directory: directory)
        for language in AppLanguage.allCases {
            let localized = items.filter { $0.language == language.rawValue }
            XCTAssertEqual(Set(localized.map(\.topicID)).count, 6, language.rawValue)
            for item in localized {
                XCTAssertTrue(item.isValid)
                XCTAssertTrue(item.isEligible(language: language.rawValue, age: 5, at: Date()))
                XCTAssertTrue(item.isEligible(language: language.rawValue, age: 18, at: Date()))
                XCTAssertNotNil(item.narration)
                XCTAssertNotNil(cache.cached(item.artwork, bundled: item.bundledArtwork), item.topicID)
            }
            let store = RecommendationStore(file: directory.appendingPathComponent(language.rawValue + ".json"))
            let selected = try store.activate(language: language.rawValue, age: 7)
            XCTAssertEqual(selected.items.count, 3)
            XCTAssertTrue(selected.items.allSatisfy { localized.contains($0) })
        }
    }
    func testRegisteredNarrationUsesOwnedDurableAssetAfterPublicVersionExpires() async throws {
        let content = item()
        let record = ExplorationRecord(id: UUID(), question: content.question, language: "en", age: 7, createdAt: now,
            reply: content.reply, preparedContent: content, preparedRegistered: true)
        var client = NarrationClient(session: session, directory: directory.appendingPathComponent("owned"))
        client.preparedAssets = PreparedAssets(directory: directory.appendingPathComponent("public"), session: session)
        var paths: [String] = []
        DiscoveryHTTPProtocol.respond = { request in
            paths.append(request.url!.path)
            if request.url!.path.contains("knowledge-assets") { return (404, [:], Data()) }
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            return (200, ["Content-Type": "audio/wav"], NarrationTests.wave())
        }
        let data = try await client.audio(for: record, connection: connection)
        XCTAssertEqual(data, NarrationTests.wave())
        XCTAssertEqual(paths, [content.narration!.path, "/api/narration/\(record.id.uuidString.lowercased())"])
    }

    func testPreparedArtworkCoordinatorUsesAssetWithoutRequestingGeneration() async throws {
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let record = try store.beginPrepared(item(), age: 7, now: now)
        let card = try store.keepQuestion(record.id)
        let coordinator = ArtworkCoordinator()
        coordinator.preparedAssets = PreparedAssets(directory: directory.appendingPathComponent("assets"), session: session)
        var calls = 0
        DiscoveryHTTPProtocol.respond = { request in
            calls += 1
            XCTAssertTrue(request.url!.path.contains("knowledge-assets"))
            return (200, ["Content-Type": "image/png"], Self.image())
        }
        await coordinator.update(card, store: store)
        XCTAssertEqual(calls, 1)
        XCTAssertNotNil(store.state.discoveries[0].artworkFilename)
        XCTAssertTrue(coordinator.errors.isEmpty)
    }

    func testRealHTTPFixtureCatalogRoundTrip() async throws {
        guard let endpoint = ProcessInfo.processInfo.environment["POCKET_DAILY_INTEGRATION_URL"], let base = URL(string: endpoint) else { throw XCTSkip("Requires the local prepared-content HTTP fixture") }
        let result = try await RecommendationClient().fetch(base: base, language: "en", age: 7, etag: nil)
        XCTAssertEqual(result.catalog?.items.count, 3)
    }

    func testViewTaskReplacementJoinsDownloadInsteadOfLosingItsOnlyRefresh() async throws {
        let store = store([])
        _ = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        let data = try JSONEncoder().encode(catalog([item()]))
        var calls = 0
        DiscoveryHTTPProtocol.respond = { _ in
            calls += 1
            Thread.sleep(forTimeInterval: 0.05)
            return (200, ["Content-Type": "application/json"], data)
        }
        let original = Task { await store.synchronize(base: base, language: "en", age: 7, now: now) }
        await Task.yield()
        let replacement = Task { await store.synchronize(base: base, language: "en", age: 7, now: now) }
        await Task.yield()
        original.cancel()
        await replacement.value
        await original.value
        XCTAssertEqual(calls, 1)
        XCTAssertEqual(try store.activate(language: "en", age: 7, now: now, timeZone: utc).items.count, 1)
    }

    func testEvictedLanguageBankRequestsAFullCatalogInsteadOfAnUnusable304() async throws {
        let store = store([])
        for (index, language) in ["en", "zh-Hans", "ja"].enumerated() {
            try respond(catalog([item(index, language: language)]))
            await store.synchronize(base: base, language: language, age: 7, now: now.addingTimeInterval(Double(index)))
        }
        let data = try JSONEncoder().encode(catalog([item(20)]))
        var calls = 0
        DiscoveryHTTPProtocol.respond = { request in
            calls += 1
            XCTAssertNil(request.value(forHTTPHeaderField: "If-None-Match"))
            return (200, ["Content-Type": "application/json", "ETag": "updated"], data)
        }
        await store.synchronize(base: base, language: "en", age: 7, now: now.addingTimeInterval(3))
        XCTAssertEqual(calls, 1)
        XCTAssertEqual(try store.activate(language: "en", age: 7, now: now, timeZone: utc).items.first?.topicID, "topic-20")
    }

    func testBackgroundRefreshDownloadsWithoutActivatingOrReplacingTodaysQuestions() async throws {
        var submitted = 0
        XCTAssertTrue(RecommendationRefresh.schedule(now: now) { request in
            submitted += 1
            XCTAssertEqual(request.identifier, RecommendationRefresh.identifier)
            XCTAssertEqual(request.earliestBeginDate, now.addingTimeInterval(21600))
        })
        XCTAssertFalse(RecommendationRefresh.schedule { _ in throw RecommendationError.unavailable })
        XCTAssertEqual(submitted, 1)
        let store = store([item(1)])
        let old = try store.activate(language: "en", age: 7, now: now, timeZone: utc)
        let candidate = item(2)
        let data = try JSONEncoder().encode(catalog([candidate]))
        let image = Self.image(), wave = NarrationTests.wave()
        DiscoveryHTTPProtocol.respond = { request in
            if request.url!.path == "/api/recommendations" { return (200, ["Content-Type": "application/json"], data) }
            let isImage = request.url!.path.hasSuffix(".png")
            return (200, ["Content-Type": isImage ? "image/png" : "audio/wav"], isImage ? image : wave)
        }
        let cache = PreparedAssets(directory: directory.appendingPathComponent("background-assets"), session: session)
        await RecommendationRefresh.run(store: store, base: base, language: "en", age: 7, cache: cache)
        XCTAssertEqual(store.items, old.items)
        XCTAssertNotNil(cache.cached(candidate.artwork))
        let next = try store.activate(language: "en", age: 7, now: old.rolloverAt, timeZone: utc)
        XCTAssertEqual(next.items.map(\.topicID), [candidate.topicID])
    }

    func testExpiredBackgroundWorkCancelsItsDownloadAndForegroundCanRecover() async throws {
        let store = store([])
        let data = try JSONEncoder().encode(catalog([item()]))
        DiscoveryHTTPProtocol.respond = { _ in
            Thread.sleep(forTimeInterval: 0.15)
            return (200, ["Content-Type": "application/json"], data)
        }
        let task = Task { await RecommendationRefresh.run(store: store, base: base, language: "en", age: 7) }
        try await Task.sleep(for: .milliseconds(25))
        task.cancel()
        await task.value
        try respond(catalog([item()]))
        await store.synchronize(base: base, language: "en", age: 7, now: now, force: true)
        XCTAssertEqual(try store.activate(language: "en", age: 7, now: now, timeZone: utc).items.count, 1)
    }

}
