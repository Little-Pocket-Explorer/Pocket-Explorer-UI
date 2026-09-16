import XCTest
@testable import PocketExplorer

@MainActor final class AccountRemovalTests: XCTestCase {
    private var directory: URL!
    private var preferences: UserDefaults!
    private var vault: ConnectionVault!
    private var session: URLSession!
    private var connection: ShareConnection!
    private var file: URL { directory.appendingPathComponent("journal.json") }

    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        preferences = UserDefaults(suiteName: "AccountRemovalTests-\(UUID().uuidString)")!
        vault = ConnectionVault(service: "AccountRemovalTests-\(UUID().uuidString)")
        connection = try vault.loadOrCreate(baseURL: "https://pocket.example")
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockShareProtocol.self]
        session = URLSession(configuration: configuration)
    }
    override func tearDown() async throws {
        session?.invalidateAndCancel(); MockShareProtocol.reply = nil
        try vault?.erase()
        try? FileManager.default.removeItem(at: directory)
    }
    private func removal(clean: ((URL) throws -> Void)? = nil) -> AccountRemoval {
        AccountRemoval(preferences: preferences, vault: vault, client: AccountRemovalClient(session: session), clean: clean ?? { file in
            let folder = file.deletingLastPathComponent()
            if FileManager.default.fileExists(atPath: folder.path) { try FileManager.default.removeItem(at: folder) }
        })
    }
    func testDeletesOwnedAccountAndClearsLocalDataAgainOnNextLaunchBeforeRotatingCredential() async throws {
        try Data("private journal".utf8).write(to: file)
        preferences.set("private receipt", forKey: "share-receipt-test")
        preferences.set("en", forKey: "app-language")
        preferences.set(7, forKey: "explorer-age")
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.url?.path, "/api/account/delete")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-parent-session"), "parent-token")
            return (200, Data("{\"deleted\":true}".utf8))
        }
        let current = removal()
        try current.prepareOnLaunch(file: file)
        await current.start(parent: "parent-token")
        XCTAssertTrue(current.finished); XCTAssertTrue(current.active); XCTAssertFalse(current.busy)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        XCTAssertNil(preferences.object(forKey: "share-receipt-test")); XCTAssertNil(preferences.object(forKey: "explorer-age"))
        XCTAssertEqual(preferences.string(forKey: "app-language"), "en")
        XCTAssertEqual(try vault.read(), connection)
        XCTAssertEqual(preferences.string(forKey: AccountRemoval.key), "completed")
        await current.resume(); await current.start(parent: nil)
        // Simulate a callback from the deleted session writing after the first cleanup.
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("late callback".utf8).write(to: file)
        try current.prepareOnLaunch(file: file)
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        let restarted = removal()
        try restarted.prepareOnLaunch(file: file)
        XCTAssertFalse(restarted.active); XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        XCTAssertNil(try vault.read()); XCTAssertNil(preferences.string(forKey: AccountRemoval.key))
        XCTAssertNotEqual(try vault.loadOrCreate(baseURL: "https://pocket.example").ownerKey, connection.ownerKey)
        try vault.erase(); try vault.erase()
    }
    func testInterruptedRequestRetainsCredentialAndRetriesAfterRelaunch() async throws {
        try Data("keep until confirmed".utf8).write(to: file)
        MockShareProtocol.reply = { _ in throw URLError(.timedOut) }
        let first = removal(); try first.prepareOnLaunch(file: file)
        await first.start(parent: "parent-token")
        XCTAssertTrue(first.active); XCTAssertFalse(first.finished); XCTAssertNotNil(first.error)
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        XCTAssertEqual(preferences.string(forKey: AccountRemoval.key), "requested")
        let restarted = removal(); try restarted.prepareOnLaunch(file: file)
        MockShareProtocol.reply = { request in
            XCTAssertNil(request.value(forHTTPHeaderField: "x-parent-session"))
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            return (200, Data("{\"deleted\":true}".utf8))
        }
        await restarted.resume()
        XCTAssertTrue(restarted.finished)
    }
    func testDeniedParentDoesNotEraseDataAndRequiresUnlockAgain() async throws {
        try Data("keep".utf8).write(to: file)
        MockShareProtocol.reply = { _ in (403, Data()) }
        let current = removal(); try current.prepareOnLaunch(file: file)
        await current.start(parent: "expired")
        XCTAssertFalse(current.active); XCTAssertTrue(current.unlockMessage); XCTAssertFalse(current.finished)
        XCTAssertNil(preferences.string(forKey: AccountRemoval.key))
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
    }
    func testStorageFailureResumesCleanupWithoutRepeatingRemoteDeletion() async throws {
        var calls = 0, attempts = 0
        MockShareProtocol.reply = { _ in calls += 1; return (200, Data("{\"deleted\":true}".utf8)) }
        let current = removal { _ in attempts += 1; if attempts == 1 { throw FamilyError.saveFailed } }
        try current.prepareOnLaunch(file: file)
        await current.start(parent: nil)
        XCTAssertFalse(current.finished); XCTAssertNotNil(current.error)
        await current.resume()
        XCTAssertTrue(current.finished); XCTAssertEqual(calls, 1); XCTAssertEqual(attempts, 2)
    }
    func testClientRejectsInvalidOrUnconfirmedDeletionResponses() async {
        let client = AccountRemovalClient(session: session)
        for (status, body) in [(200, "{}"), (200, "{\"deleted\":false}"), (202, "{\"deleted\":true}"), (500, "internal details")] {
            MockShareProtocol.reply = { _ in (status, Data(body.utf8)) }
            do { try await client.delete(connection: connection, parent: nil); XCTFail("Expected failure") } catch { }
        }
        do { try await client.delete(connection: ShareConnection(baseURL: "http://unsafe.example", ownerKey: "bad"), parent: nil); XCTFail() } catch { }
    }
    func testNoCredentialHasOnlyLocalDataAndNoRemoteRequest() async throws {
        try vault.erase()
        MockShareProtocol.reply = { _ in XCTFail("Unexpected request"); return (500, Data()) }
        let current = removal(); try current.prepareOnLaunch(file: file)
        await current.start(parent: nil)
        XCTAssertTrue(current.finished)
    }
}
