import XCTest
@testable import PocketExplorer

@MainActor final class AIDataPermissionTests: XCTestCase {
    private var preferences: UserDefaults!
    private var suite: String!
    private var cache: AIPermissionCache!
    private var session: URLSession!
    private let connection = ShareConnection(baseURL: "https://privacy.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    private func receipt(_ granted: Bool, revision: Int = 1) -> AIPermissionReceipt {
        AIPermissionReceipt(policyVersion: AIPermissionReceipt.policyVersion, granted: granted, revision: revision, updatedAt: 1000)
    }
    override func setUp() {
        suite = "AIDataPermissionTests.\(UUID())"; preferences = UserDefaults(suiteName: suite)!
        cache = AIPermissionCache(preferences: preferences)
        let configuration = URLSessionConfiguration.ephemeral; configuration.protocolClasses = [MockShareProtocol.self]
        session = URLSession(configuration: configuration)
    }
    override func tearDown() { preferences.removePersistentDomain(forName: suite); session.invalidateAndCancel(); MockShareProtocol.reply = nil }

    private func body(_ request: URLRequest) -> Data {
        if let data = request.httpBody { return data }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open(); defer { stream.close() }
        var data = Data(), buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count <= 0 { break }
            data.append(buffer, count: count)
        }
        return data
    }

    func testCacheDefaultsToDeniedAndSeparatesInstallationsAndServices() throws {
        XCTAssertFalse(cache.allows(connection)); XCTAssertThrowsError(try cache.require(connection))
        try cache.accept(receipt(true), connection: connection)
        try cache.require(connection)
        XCTAssertTrue(AIPermissionCache(preferences: preferences).allows(connection))
        XCTAssertFalse(cache.allows(ShareConnection(baseURL: "https://other.example", ownerKey: connection.ownerKey)))
        XCTAssertFalse(cache.allows(ShareConnection(baseURL: connection.baseURL, ownerKey: "pe1_" + String(repeating: "b", count: 64))))
        XCTAssertFalse(receipt(true, revision: 0).allowsRequests)
        var old = receipt(true); old.policyVersion = "old"; XCTAssertFalse(old.allowsRequests)
        var invalid = receipt(true); invalid.revision = -1; XCTAssertFalse(invalid.isValid)
        XCTAssertThrowsError(try cache.accept(invalid, connection: connection))
        invalid = receipt(true); invalid.updatedAt = .infinity; XCTAssertFalse(invalid.isValid)
        invalid = receipt(true); invalid.policyVersion = ""; XCTAssertFalse(invalid.isValid)
        XCTAssertTrue(AIPermissionReceipt(policyVersion: "new", granted: false, revision: 0, updatedAt: nil).isValid)
    }

    func testWithdrawalPersistsBeforeNetworkAndStaleResponsesCannotRestorePermission() throws {
        try cache.accept(receipt(true), connection: connection)
        try cache.withdraw(connection)
        XCTAssertTrue(cache.pending(connection)); XCTAssertFalse(cache.allows(connection))
        try cache.accept(receipt(true, revision: 2), connection: connection)
        XCTAssertFalse(cache.allows(connection)); XCTAssertTrue(cache.pending(connection))
        XCTAssertThrowsError(try cache.accept(receipt(true, revision: 2), connection: connection, withdrawal: true))
        try cache.accept(receipt(false, revision: 3), connection: connection, withdrawal: true)
        XCTAssertFalse(cache.pending(connection)); XCTAssertFalse(cache.allows(connection))
        try cache.accept(receipt(true), connection: connection)
        XCTAssertFalse(cache.allows(connection)); XCTAssertEqual(cache.receipt(connection)?.revision, 3)
    }

    func testCorruptCacheFailsClosed() throws {
        try cache.accept(receipt(true), connection: connection)
        let key = preferences.dictionaryRepresentation().keys.first { $0.hasPrefix("ai-data-permission.") }!
        preferences.set(Data("broken".utf8), forKey: key)
        XCTAssertFalse(cache.allows(connection))
        XCTAssertThrowsError(try cache.require(connection))
    }

    func testClientBindsExplicitChoiceAndParentSessionToCurrentInstallation() async throws {
        let client = AIDataPermissionClient(session: session)
        var calls = 0
        MockShareProtocol.reply = { request in
            calls += 1
            XCTAssertEqual(request.url?.path, "/api/privacy/ai")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            XCTAssertEqual(request.httpMethod, calls == 1 ? "GET" : "POST")
            if calls == 2 {
                XCTAssertEqual(request.value(forHTTPHeaderField: "x-parent-session"), "parent-session")
                let body = try JSONSerialization.jsonObject(with: self.body(request)) as? [String: Any]
                XCTAssertEqual(body?["policyVersion"] as? String, AIPermissionReceipt.policyVersion)
                XCTAssertEqual(body?["granted"] as? Bool, true)
                XCTAssertEqual(body?["revision"] as? Int, 4)
            }
            return (200, try JSONEncoder().encode(self.receipt(true, revision: 5)))
        }
        _ = try await client.read(connection: connection)
        let updated = try await client.update(granted: true, revision: 4, parent: "parent-session", connection: connection)
        XCTAssertTrue(updated.granted)
        XCTAssertEqual(calls, 2)
    }

    func testMalformedDeniedConflictAndOfflineResponsesDoNotGrant() async {
        let client = AIDataPermissionClient(session: session)
        for code in [403, 409, 500, 200] {
            MockShareProtocol.reply = { _ in (code, Data("bad".utf8)) }
            do { _ = try await client.read(connection: connection); XCTFail() } catch {}
        }
        MockShareProtocol.reply = { _ in throw URLError(.notConnectedToInternet) }
        do { _ = try await client.read(connection: connection); XCTFail() } catch {}
        do { _ = try await client.read(connection: ShareConnection(baseURL: "http://unsafe.example", ownerKey: connection.ownerKey)); XCTFail() } catch {}
        XCTAssertFalse(cache.allows(connection))
    }

    func testGrantThenWithdrawAndRelaunchRecovery() async throws {
        let permission = AIDataPermission(cache: cache, client: AIDataPermissionClient(session: session))
        MockShareProtocol.reply = { request in
            (200, try JSONEncoder().encode(self.receipt(request.httpMethod == "POST", revision: request.httpMethod == "POST" ? 2 : 1)))
        }
        await permission.synchronize(connection: connection); XCTAssertFalse(permission.allowed)
        await permission.allow(parent: "parent", connection: connection)
        XCTAssertTrue(permission.allowed); XCTAssertNil(permission.error)
        MockShareProtocol.reply = { _ in throw URLError(.notConnectedToInternet) }
        await permission.withdraw(connection: connection)
        XCTAssertFalse(permission.allowed); XCTAssertTrue(permission.pendingWithdrawal); XCTAssertNotNil(permission.error)
        await permission.allow(parent: "parent", connection: connection)
        XCTAssertFalse(permission.allowed)
        let reopened = AIDataPermission(cache: cache, client: AIDataPermissionClient(session: session))
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertNil(request.value(forHTTPHeaderField: "x-parent-session"))
            return (200, try JSONEncoder().encode(self.receipt(false, revision: 3)))
        }
        await reopened.synchronize(connection: connection)
        XCTAssertFalse(reopened.allowed); XCTAssertFalse(reopened.pendingWithdrawal); XCTAssertNil(reopened.error)
    }

    func testGrantRejectsChangedPolicyAndFalseReceipt() async {
        let permission = AIDataPermission(cache: cache, client: AIDataPermissionClient(session: session))
        MockShareProtocol.reply = { _ in
            var response = self.receipt(false); response.policyVersion = "new-policy"
            return (200, try JSONEncoder().encode(response))
        }
        await permission.allow(parent: "parent", connection: connection)
        XCTAssertFalse(permission.allowed); XCTAssertNotNil(permission.error)
        MockShareProtocol.reply = { _ in (200, try JSONEncoder().encode(self.receipt(false))) }
        await permission.allow(parent: "parent", connection: connection)
        XCTAssertFalse(permission.allowed); XCTAssertNotNil(permission.error)
        XCTAssertNotNil(AIDataPermissionError.required.errorDescription)
        XCTAssertNotNil(AIDataPermissionError.changed.errorDescription)
    }

    func testTransportGuardsProtectQuestionArtworkRetryAndSpeechBeforeAnyUpload() async throws {
        let isolated = ShareConnection(baseURL: "https://privacy-\(UUID().uuidString).example", ownerKey: connection.ownerKey)
        let client = AIClient(session: session)
        let reply = AIReply(title: "Sky", answer: "Blue light scatters.", invitation: "Look up.", category: "science", artworkPrompt: "Sky", quiz: DiscoveryQuiz(question: "What scatters?", choices: ["Light", "Rock", "Water"], correctIndex: 0, explanation: "Light."))
        let record = ExplorationRecord(id: UUID(), question: "Why is the sky blue?", language: "en", age: 7, createdAt: Date(), reply: reply)
        MockShareProtocol.reply = { _ in XCTFail("Sent content without permission"); return (500, Data()) }
        do { _ = try await client.ask(record, photo: nil, connection: isolated); XCTFail() } catch { XCTAssertTrue(error is AIDataPermissionError) }
        do { _ = try await client.createArtwork(record.id, connection: isolated); XCTFail() } catch { XCTAssertTrue(error is AIDataPermissionError) }
        do { _ = try await client.artwork(UUID().uuidString, retry: true, connection: isolated); XCTFail() } catch { XCTAssertTrue(error is AIDataPermissionError) }
        do { _ = try await NarrationClient(session: session).audio(for: record, connection: isolated); XCTFail() } catch { XCTAssertTrue(error is AIDataPermissionError) }
        MockShareProtocol.reply = { _ in (403, Data("{\"error\":\"ai_permission_required\"}".utf8)) }
        do { _ = try await AIClient(session: session, permission: { _ in }).ask(record, photo: nil, connection: isolated); XCTFail() } catch { XCTAssertTrue(error is AIDataPermissionError) }
    }
}
