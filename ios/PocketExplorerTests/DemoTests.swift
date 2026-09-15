import XCTest
@testable import PocketExplorer

@MainActor
final class DemoTests: XCTestCase {
    var directory: URL!
    var session: URLSession!
    let now = Date(timeIntervalSince1970: 1_800_000_000)
    let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "b", count: 64))
    let activation = DemoActivation(url: URL(string: "pocketexplorer://demo/activate#" + String(repeating: "x", count: 43))!)!
    var access: DemoAccess { DemoAccess(authorized: true, id: "11111111-1111-4111-8111-111111111111", label: "Test phone", expiresAt: now.addingTimeInterval(604800).timeIntervalSince1970 * 1000) }
    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let configuration = URLSessionConfiguration.ephemeral; configuration.protocolClasses = [DiscoveryHTTPProtocol.self]
        session = URLSession(configuration: configuration)
    }
    override func tearDown() async throws {
        session.invalidateAndCancel(); DiscoveryHTTPProtocol.respond = nil
        try? FileManager.default.removeItem(at: directory)
    }
    func store(name: String = "demo.json", writer: ((Data, URL) throws -> Void)? = nil) -> DemoStore {
        let value = DemoStore(file: directory.appendingPathComponent(name), client: DemoClient(session: session), writer: writer)
        value.now = { self.now }; return value
    }
    func cache() -> PreparedAssets { PreparedAssets(directory: directory.appendingPathComponent("assets"), session: session) }
    func respond(items: [PreparedContent] = [], authorized: Bool = true) throws {
        let grant = authorized ? access : DemoAccess(authorized: false)
        let result = DemoDownload(access: grant, catalog: RecommendationCatalog(schemaVersion: 1, revision: "demo-1", serverTime: now.timeIntervalSince1970 * 1000, refreshAfterSeconds: 21600, items: items, withdrawals: []))
        let accessData = try JSONEncoder().encode(grant), catalogData = try JSONEncoder().encode(result)
        let image = PreparedDiscoveryTests.image(), audio = NarrationTests.wave()
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            let path = request.url!.path
            if path.hasSuffix(".png") { return (200, ["Content-Type": "image/png"], image) }
            if path.hasSuffix(".wav") { return (200, ["Content-Type": "audio/wav"], audio) }
            return (200, ["Content-Type": "application/json"], path.hasSuffix("catalog") ? catalogData : accessData)
        }
    }
    func testPrivateLinkParsingAndAccessValidation() {
        for url in ["https://pocket.example/demo#abc", "pocketexplorer://demo/activate#short", "pocketexplorer://evil/activate#" + activation.token,
                    "pocketexplorer://demo/activate?token=x#" + activation.token, "pocketexplorer://user@demo/activate#" + activation.token] {
            XCTAssertNil(DemoActivation(url: URL(string: url)!))
        }
        XCTAssertEqual(activation.id, activation.token)
        XCTAssertTrue(access.isValid(at: now)); XCTAssertFalse(access.isValid(at: now.addingTimeInterval(604800)))
        XCTAssertFalse(DemoAccess(authorized: true, id: "bad", expiresAt: .infinity).isValid(at: now))
        for error in [DemoError.invitation, .unauthorized, .unavailable, .invalidResponse] { XCTAssertFalse(error.localizedDescription.isEmpty) }
    }
    func testUninvitedPhoneHasNoEntryAndActivationDoesNotEnableMode() async throws {
        let demo = store()
        XCTAssertFalse(demo.authorized); XCTAssertFalse(demo.enabled); XCTAssertNil(demo.expiresAt)
        DiscoveryHTTPProtocol.respond = { _ in XCTFail("Uninvited phones should not query demo access"); throw URLError(.notConnectedToInternet) }
        await demo.checkAccess(connection: connection)
        await demo.refresh(connection: connection, language: "en", age: 7)
        XCTAssertThrowsError(try demo.setEnabled(true))
        try respond(); try await demo.activate(activation, connection: connection)
        XCTAssertTrue(demo.authorized); XCTAssertFalse(demo.enabled)
        XCTAssertEqual(store().expiresAt, now.addingTimeInterval(604800))
        try demo.setEnabled(true); XCTAssertTrue(store().enabled)
        try demo.setEnabled(false); XCTAssertFalse(demo.enabled)
    }
    func testStableOrderedOfflinePresentationSurvivesRelaunchAndKeepsDailySnapshot() async throws {
        let prepared = PreparedDiscoveryTests(), items = [prepared.item(9), prepared.item(2), prepared.item(5)]
        let trip = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: .examples(), bundledContent: (20..<26).map { prepared.item($0) })
        let normal = try trip.recommendations.activate(language: "en", age: 7, now: now)
        let demo = store(); try respond(items: items)
        try await demo.activate(activation, connection: connection); try demo.setEnabled(true)
        demo.selectContext(language: "en", age: 7, cache: cache())
        await demo.refresh(connection: connection, language: "en", age: 7, cache: cache())
        XCTAssertEqual(demo.items.map(\.topicID), items.map(\.topicID)); XCTAssertTrue(demo.offlineReady); XCTAssertNil(demo.error)
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        let restored = store(); restored.selectContext(language: "en", age: 7, cache: cache())
        await restored.checkAccess(connection: connection)
        XCTAssertEqual(restored.items, items); XCTAssertTrue(restored.offlineReady)
        await restored.refresh(connection: connection, language: "en", age: 7, cache: cache())
        XCTAssertNotNil(restored.error); XCTAssertEqual(restored.items, items)
        try restored.setEnabled(false)
        XCTAssertEqual(try trip.recommendations.activate(language: "en", age: 7, now: now), normal)
        XCTAssertTrue(restored.items.isEmpty)
        try restored.setEnabled(true)
        restored.now = { self.now.addingTimeInterval(604800) }
        XCTAssertFalse(restored.authorized); XCTAssertFalse(restored.enabled); XCTAssertTrue(restored.items.isEmpty)
    }
    func testRevocationClearsAccessEvenWhenDiskWriteFails() async throws {
        let demo = store(); try respond(); try await demo.activate(activation, connection: connection); try demo.setEnabled(true)
        let broken = store(writer: { _, _ in throw CocoaError(.fileWriteOutOfSpace) })
        try respond(authorized: false); await broken.checkAccess(connection: connection)
        XCTAssertFalse(broken.authorized); XCTAssertFalse(store().authorized)
        try respond(); try await demo.activate(activation, connection: connection)
        DiscoveryHTTPProtocol.respond = { _ in (403, [:], Data()) }
        await demo.checkAccess(connection: connection); XCTAssertFalse(demo.authorized)
        try respond(authorized: false)
        do { try await demo.activate(activation, connection: connection); XCTFail("Invalid grant") } catch {}
    }
    func testInvalidAndExpiredCatalogsNeverReplaceLastGoodContent() async throws {
        let items = [PreparedDiscoveryTests().item(1)], demo = store()
        try respond(items: items); try await demo.activate(activation, connection: connection); try demo.setEnabled(true)
        demo.selectContext(language: "en", age: 7, cache: cache())
        await demo.refresh(connection: connection, language: "en", age: 7, cache: cache())
        try respond(items: items + items)
        await demo.refresh(connection: connection, language: "en", age: 7, cache: cache()); XCTAssertEqual(demo.items, items)
        try respond(items: items)
        await demo.refresh(connection: connection, language: "ja", age: 7, cache: cache()); XCTAssertEqual(demo.items, items)
        try respond(authorized: false)
        await demo.refresh(connection: connection, language: "en", age: 7, cache: cache()); XCTAssertFalse(demo.enabled)
        try Data("invalid".utf8).write(to: directory.appendingPathComponent("bad.json"))
        XCTAssertFalse(store(name: "bad.json").authorized)
        let broken = store(name: "broken.json", writer: { _, _ in throw CocoaError(.fileWriteOutOfSpace) })
        try respond()
        do { try await broken.activate(activation, connection: connection); XCTFail("Write failure must be reported") } catch {}
        XCTAssertFalse(broken.authorized)
    }
    func testClientErrorsAreBoundedAndDoNotRevealActivationTokens() async throws {
        let client = DemoClient(session: session)
        for status in [401, 403, 410, 429, 500, 200] {
            DiscoveryHTTPProtocol.respond = { _ in (status, [:], Data("bad".utf8)) }
            do { _ = try await client.activate(activation, connection: connection); XCTFail("Invalid response") }
            catch { XCTAssertFalse(error.localizedDescription.contains(activation.token)) }
        }
        do { _ = try await client.access(connection: ShareConnection(baseURL: "http://bad.example", ownerKey: connection.ownerKey)); XCTFail("Invalid origin") } catch {}
    }
}
