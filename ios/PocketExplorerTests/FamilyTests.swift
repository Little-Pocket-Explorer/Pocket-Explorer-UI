import XCTest
@testable import PocketExplorer

@MainActor
final class FamilyTests: XCTestCase {
    var directory: URL!
    var session: URLSession!
    var clock = Date(timeIntervalSince1970: 1_800_000_000)
    var elapsed: TimeInterval = 100
    let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    let token = String(repeating: "p", count: 43)
    var remote: ExplorerFamily!
    var posted: [UUID: UsageEntry] = [:]

    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let configuration = URLSessionConfiguration.ephemeral; configuration.protocolClasses = [DiscoveryHTTPProtocol.self]
        session = URLSession(configuration: configuration)
        var profile = ExplorerProfile(); profile.timeZone = "UTC"
        remote = ExplorerFamily(id: UUID().uuidString, friendCode: "012345ABCDEF", profile: profile, policy: FamilyPolicy(), revision: 1,
            createdAt: clock.timeIntervalSince1970 * 1000, usage: FamilyUsage(day: "2027-01-15", seconds: 0, serverTime: clock.timeIntervalSince1970 * 1000))
        clock = Date(timeIntervalSince1970: 1_800_000_000); elapsed = 100; posted = [:]
    }
    override func tearDown() async throws {
        session.invalidateAndCancel(); DiscoveryHTTPProtocol.respond = nil
        try? FileManager.default.removeItem(at: directory)
    }
    func make(writer: ((Data, URL) throws -> Void)? = nil) throws -> FamilyStore {
        let value = try FamilyStore(file: directory.appendingPathComponent("family.json"), client: FamilyClient(session: session), writer: writer)
        value.now = { self.clock }; value.uptime = { self.elapsed }; return value
    }
    func body(_ request: URLRequest) -> Data {
        if let data = request.httpBody { return data }
        let stream = request.httpBodyStream!; stream.open(); defer { stream.close() }
        var data = Data(), buffer = [UInt8](repeating: 0, count: 2048)
        while stream.hasBytesAvailable { let n = stream.read(&buffer, maxLength: buffer.count); if n <= 0 { break }; data.append(buffer, count: n) }
        return data
    }
    func testDeletionAuthorizationRequiresAnUnexpiredParentSession() async throws {
        let family = try make()
        XCTAssertNil(try family.deletionToken())
        serve()
        try await family.setup(profile: remote.profile, pin: "926418", connection: connection)
        XCTAssertEqual(try family.deletionToken(), token)
        elapsed += 601
        XCTAssertThrowsError(try family.deletionToken())
    }
    func serve() {
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            XCTAssertEqual(request.timeoutInterval, 15)
            let path = request.url!.path
            if path.hasSuffix("/usage") {
                let entry = try JSONDecoder().decode(UsageEntry.self, from: self.body(request))
                self.posted[entry.id] = entry
                self.remote.usage.seconds = self.posted.values.reduce(0) { $0 + $1.seconds }
            }
            if path.hasSuffix("/settings") {
                XCTAssertEqual(request.value(forHTTPHeaderField: "x-parent-session"), self.token)
                struct Input: Decodable { var profile: ExplorerProfile; var policy: FamilyPolicy; var revision: Int }
                let input = try JSONDecoder().decode(Input.self, from: self.body(request))
                XCTAssertEqual(input.revision, self.remote.revision)
                self.remote.profile = input.profile; self.remote.policy = input.policy; self.remote.revision += 1
            }
            if path.hasSuffix("/lock") { return (200, [:], Data("{\"locked\":true}".utf8)) }
            struct Output: Encodable { var family: ExplorerFamily; var parent: ParentSession; var recoveryCode: String }
            return (200, [:], try JSONEncoder().encode(Output(family: self.remote, parent: ParentSession(token: self.token, expiresAt: self.clock.timeIntervalSince1970 * 1000 + 600_000), recoveryCode: String(repeating: "r", count: 43))))
        }
    }
    func testProfileValidationAndPermissionRules() {
        XCTAssertTrue(remote.isValid)
        for feature in [FamilyFeature.exploration, .events, .sharing] { XCTAssertTrue(remote.permits(feature)) }
        XCTAssertFalse(remote.permits(.social)); XCTAssertFalse(remote.permits(.mapSharing))
        remote.policy.mapSharing = true; XCTAssertTrue(remote.permits(.mapSharing))
        remote.policy.sharing = false; XCTAssertFalse(remote.permits(.mapSharing))
        var profile = remote.profile
        profile.nickname = " "; XCTAssertFalse(profile.isValid)
        profile = remote.profile; profile.interests = ["animals", "animals"]; XCTAssertFalse(profile.isValid)
        profile = remote.profile; profile.language = "xx"; XCTAssertFalse(profile.isValid)
        profile = remote.profile; profile.timeZone = "no/zone"; XCTAssertFalse(profile.isValid)
        profile = remote.profile; profile.avatar = "unknown"; XCTAssertFalse(profile.isValid)
        profile = remote.profile; profile.interests = ["unknown"]; XCTAssertFalse(profile.isValid)
        profile = remote.profile; profile.learningLevel = 4; XCTAssertFalse(profile.isValid)
        for code in ["parent_required", "family_required", "parent_pin_incorrect", "parent_recovery_incorrect", "parent_try_later", "please_wait", "family_changed", "family_exists", "family_day_changed", "family_feature_disabled", "family_time_finished", "invalid_request", "invalid_input", "unknown"] {
            XCTAssertFalse(FamilyError.from(code).localizedDescription.isEmpty)
        }
        XCTAssertFalse(FamilyError.invalidResponse.localizedDescription.isEmpty); XCTAssertFalse(FamilyError.saveFailed.localizedDescription.isEmpty)
    }
    func testSetupReadbackProtectedEditsAndRecoveryKeepSecretsOutOfDisk() async throws {
        serve(); let store = try make()
        XCTAssertNil(store.family); XCTAssertTrue(store.allows(.exploration)); XCTAssertFalse(store.parentUnlocked)
        try await store.setup(profile: remote.profile, pin: "926418", connection: connection)
        XCTAssertEqual(store.family, remote); XCTAssertTrue(store.parentUnlocked); XCTAssertEqual(store.recoveryCode?.count, 43)
        XCTAssertEqual(try make().family, remote); XCTAssertFalse(try make().parentUnlocked)
        let written = try String(contentsOf: directory.appendingPathComponent("family.json"), encoding: .utf8)
        for secret in ["926418", token, String(repeating: "r", count: 43)] { XCTAssertFalse(written.contains(secret)) }
        store.clearRecoveryCode(); XCTAssertNil(store.recoveryCode)
        var profile = remote.profile; profile.nickname = "River"; profile.interests = ["nature"]
        var policy = remote.policy; policy.sharing = false
        try await store.save(profile: profile, policy: policy, connection: connection)
        XCTAssertEqual(try make().family?.profile.nickname, "River"); XCTAssertFalse(store.allows(.sharing))
        await store.lock(connection: connection); XCTAssertFalse(store.parentUnlocked)
        do { try await store.save(profile: profile, policy: policy, connection: connection); XCTFail("Parent required") } catch { XCTAssertEqual(error as? FamilyError, .parentRequired) }
        try await store.unlock(pin: "926418", connection: connection); XCTAssertTrue(store.parentUnlocked)
        elapsed += 600; XCTAssertFalse(store.parentUnlocked)
        try await store.recover(code: String(repeating: "r", count: 43), pin: "812739", connection: connection)
        XCTAssertTrue(store.parentUnlocked); XCTAssertNotNil(store.recoveryCode)
        await store.lock(); XCTAssertNil(store.recoveryCode)
    }
    func testMonotonicUsageOfflineRelaunchAndIdempotentUpload() async throws {
        serve(); let store = try make(); await store.synchronize(connection: connection)
        remote.policy.dailyMinutes = 1; await store.synchronize(connection: connection)
        try store.tick(); XCTAssertEqual(store.usedSeconds, 0)
        store.beginActive(); elapsed += 30; try store.tick()
        XCTAssertEqual(store.usedSeconds, 30); XCTAssertEqual(store.pendingUsage.count, 1)
        let id = store.pendingUsage[0].id
        await store.synchronize(connection: connection)
        XCTAssertEqual(posted[id]?.seconds, 30); XCTAssertTrue(store.pendingUsage.isEmpty); XCTAssertEqual(store.usedSeconds, 30)
        elapsed += 30; clock = clock.addingTimeInterval(-3600); try store.tick()
        XCTAssertEqual(store.usedSeconds, 60); XCTAssertTrue(store.timeFinished); XCTAssertFalse(store.allows(.exploration))
        elapsed += 60; try store.tick(); XCTAssertEqual(store.usedSeconds, 60)
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        let restored = try make(); await restored.synchronize(connection: connection)
        XCTAssertTrue(restored.timeFinished); XCTAssertNotNil(restored.error); XCTAssertEqual(restored.pendingUsage.count, 1)
        serve(); await restored.synchronize(connection: connection)
        XCTAssertEqual(remote.usage.seconds, 60); XCTAssertTrue(restored.pendingUsage.isEmpty)
        await restored.synchronize(connection: connection); XCTAssertEqual(remote.usage.seconds, 60)
        try restored.endActive(); elapsed += 3600; try restored.tick(); XCTAssertEqual(restored.usedSeconds, 60)
        clock = clock.addingTimeInterval(86_400 + 3600); remote.usage = FamilyUsage(day: "2027-01-16", seconds: 0, serverTime: clock.timeIntervalSince1970 * 1000)
        await restored.synchronize(connection: connection); XCTAssertFalse(restored.timeFinished); XCTAssertEqual(restored.usedSeconds, 0)
    }
    func testRetryAfterLostResponseDoesNotDoubleCountAndBackgroundEndsParentSession() async throws {
        serve(); let store = try make(); try await store.setup(profile: remote.profile, pin: "926418", connection: connection)
        store.beginActive(); elapsed += 0.5; try store.tick(); XCTAssertEqual(store.usedSeconds, 0)
        elapsed += 8; try store.endActive(); XCTAssertEqual(store.usedSeconds, 8); XCTAssertFalse(store.parentUnlocked)
        let entry = store.pendingUsage[0]; posted[entry.id] = entry; remote.usage.seconds = 8
        await store.synchronize(connection: connection); XCTAssertEqual(store.usedSeconds, 8); XCTAssertEqual(posted.count, 1)
        store.beginActive(); elapsed -= 100; try store.tick(); XCTAssertEqual(store.usedSeconds, 8)
    }
    func testInvalidAndOutdatedResponsesAndDiskFailuresDoNotSilentlyRemoveSettings() async throws {
        serve(); let store = try make(); await store.synchronize(connection: connection)
        remote.revision = 2; await store.synchronize(connection: connection)
        remote.revision = 1; await store.synchronize(connection: connection)
        XCTAssertNotNil(store.error); XCTAssertEqual(store.family?.revision, 2)
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data("{\"family\":null}".utf8)) }
        await store.synchronize(connection: connection); XCTAssertNotNil(store.family)
        let broken = try make(writer: { _, _ in throw CocoaError(.fileWriteOutOfSpace) })
        serve(); remote.revision = 3; await broken.synchronize(connection: connection)
        XCTAssertTrue(broken.storageFailed); XCTAssertFalse(broken.allows(.sharing)); XCTAssertNotNil(broken.error)
        remote.id = UUID().uuidString; await store.synchronize(connection: connection); XCTAssertEqual(store.family?.revision, 2)
        try Data("invalid".utf8).write(to: directory.appendingPathComponent("family.json"))
        XCTAssertThrowsError(try make())
    }
    func testClientValidationFailuresAndInvalidParentGrants() async throws {
        let client = FamilyClient(session: session), store = try make()
        serve()
        for code in ["parent_pin_incorrect", "parent_required", "parent_try_later", "family_changed"] {
            DiscoveryHTTPProtocol.respond = { _ in (403, [:], Data("{\"error\":\"\(code)\"}".utf8)) }
            do { try await store.unlock(pin: "926418", connection: connection); XCTFail("Request should fail") } catch { XCTAssertEqual(error as? FamilyError, FamilyError.from(code)) }
        }
        for payload in ["bad", "{\"family\":{}}", "{}", "{\"parent\":{\"token\":\"bad\",\"expiresAt\":12}}"] {
            DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data(payload.utf8)) }
            do { try await store.unlock(pin: "926418", connection: connection); XCTFail("Invalid grant") } catch {}
            do { try await store.setup(profile: remote.profile, pin: "926418", connection: connection); XCTFail("Invalid setup") } catch {}
            do { try await store.recover(code: String(repeating: "r", count: 43), pin: "926418", connection: connection); XCTFail("Invalid recovery") } catch {}
        }
        for pin in ["123", "abcdef", "１２３４５６"] {
            do { _ = try await client.setup(profile: remote.profile, pin: pin, connection: connection); XCTFail("Invalid PIN") } catch {}
            do { _ = try await client.unlock(pin: pin, connection: connection); XCTFail("Invalid PIN") } catch {}
        }
        do { _ = try await client.recover(code: "bad", pin: "926418", connection: connection); XCTFail("Invalid recovery") } catch {}
        remote.profile.nickname = ""
        do { _ = try await client.update(remote, parent: token, connection: connection); XCTFail("Invalid profile") } catch {}
        do { _ = try await client.read(connection: ShareConnection(baseURL: "http://bad.example", ownerKey: connection.ownerKey)); XCTFail("Invalid origin") } catch {}
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.cancelled) }
        do { _ = try await client.read(connection: connection); XCTFail("Cancelled") } catch { XCTAssertTrue(error is CancellationError) }
    }
}
