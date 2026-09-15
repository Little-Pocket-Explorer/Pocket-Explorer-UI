import XCTest
@testable import PocketExplorer

final class ProfileIntegrationTests: XCTestCase {
    private var preferences: UserDefaults!
    private var suite: String!
    override func setUp() {
        suite = "ProfileMigrationTests-\(UUID().uuidString)"
        preferences = UserDefaults(suiteName: suite)
    }
    override func tearDown() { preferences.removePersistentDomain(forName: suite) }
    private func save(_ object: [String: Any]) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: object)
        preferences.set(data, forKey: "explorer-profile")
        return data
    }
    private func draft() -> ExplorerProfile? {
        LegacyProfileMigration.draft(from: preferences, language: "zh-Hans", timeZone: "Australia/Sydney")
    }
    func testMigratesLegacyDetailsWithoutChangingSourceOrPermissions() throws {
        let source = try save(["displayName": "  Little explorer  ", "avatar": "doudou", "age": 9,
                              "interests": ["bugs", "nature", "space", "unsupported"],
                              "allowPublicSharing": true, "allowSocial": true, "locationEnabled": true])
        let profile = try XCTUnwrap(draft())
        XCTAssertEqual(profile.nickname, "Little explorer"); XCTAssertEqual(profile.avatar, "dou-dou")
        XCTAssertEqual(profile.age, 9); XCTAssertEqual(profile.interests, ["nature", "space"])
        XCTAssertEqual(profile.language, "zh-Hans"); XCTAssertEqual(profile.timeZone, "Australia/Sydney")
        XCTAssertEqual(profile.learningLevel, 1); XCTAssertTrue(profile.isValid)
        XCTAssertEqual(preferences.data(forKey: "explorer-profile"), source)
        let encoded = String(data: try JSONEncoder().encode(profile), encoding: .utf8)!
        XCTAssertFalse(encoded.contains("allowPublicSharing")); XCTAssertFalse(encoded.contains("locationEnabled"))
        XCTAssertFalse(FamilyPolicy().social); XCTAssertFalse(FamilyPolicy().mapSharing)
        XCTAssertEqual(draft(), profile)
    }
    func testDefaultsAndInvalidDraftsRemainRecoverable() throws {
        XCTAssertNil(draft())
        preferences.set(Data("invalid".utf8), forKey: "explorer-profile"); XCTAssertNil(draft())
        for object: [String: Any] in [
            ["displayName": "AJ"], ["displayName": "AJ", "age": 4], ["displayName": "AJ", "age": 19],
            ["displayName": " ", "age": 8], ["displayName": "AJ", "age": 8, "avatar": "unknown"],
            ["displayName": String(repeating: "a", count: 25), "age": 8]
        ] {
            let source = try save(object); XCTAssertNil(draft())
            XCTAssertEqual(preferences.data(forKey: "explorer-profile"), source)
        }
        _ = try save(["displayName": "AJ", "age": 8])
        XCTAssertEqual(draft()?.avatar, "mimi"); XCTAssertEqual(draft()?.interests, [])
        _ = try save(["displayName": "AJ", "age": 18, "avatar": "aj"])
        XCTAssertEqual(draft()?.avatar, "aj")
        XCTAssertNil(LegacyProfileMigration.draft(from: preferences, language: "unknown"))
        XCTAssertNil(LegacyProfileMigration.draft(from: preferences, timeZone: "invalid"))
        XCTAssertNotNil(LegacyProfileMigration.preferences)
    }
    func testOlderTripLocationsContributeAndExplicitDiscoveryLocationsTakePrecedence() {
        let old = JournalState.examples(language: .english)
        XCTAssertTrue(old.discoveries.allSatisfy { $0.place == nil })
        let metric = ExplorerProfileMetrics(discoveries: old.discoveries, trips: old.trips)
        XCTAssertEqual(metric.discoveries, 4); XCTAssertEqual(metric.places, 3)
        var pair = Array(old.discoveries.prefix(2))
        XCTAssertEqual(ExplorerProfileMetrics(discoveries: pair, trips: old.trips).places, 1)
        pair[0].place = .melbourne
        XCTAssertEqual(ExplorerProfileMetrics(discoveries: pair, trips: old.trips).places, 2)
        pair[0].unlockRequired = true
        XCTAssertEqual(ExplorerProfileMetrics(discoveries: pair, trips: old.trips).places, 1)
        XCTAssertEqual(ExplorerProfileMetrics(discoveries: [], trips: old.trips).places, 0)
    }
    func testStatisticsExcludePendingAndDeduplicateEvolvingCardsAndPlaces() {
        var first = Discovery(id: UUID(), tripID: UUID(), subject: .leaf, question: "Leaves?", observation: "Green", explanation: "Chlorophyll", createdAt: .now)
        first.place = .sydney; first.tier = .rare
        var next = first; next.id = UUID(); next.evolvesFrom = first.collectionID; next.tier = .epic
        var pending = first; pending.id = UUID(); pending.unlockRequired = true; pending.place = .brisbane
        var another = first; another.id = UUID(); another.place = .melbourne; another.tier = .common
        var unlocated = first; unlocated.id = UUID(); unlocated.place = nil; unlocated.tier = nil
        let metrics = ExplorerProfileMetrics(discoveries: [first, next, pending, another, unlocated])
        XCTAssertEqual(metrics.discoveries, 3); XCTAssertEqual(metrics.places, 2); XCTAssertEqual(metrics.rare, 1)
        XCTAssertEqual(ExplorerProfileMetrics(discoveries: []).discoveries, 0)
        next.collectible = KnowledgeCard(id: next.collectionID, style: .forest, createdAt: 1, updatedAt: 1, tier: .common, versions: [])
        XCTAssertEqual(ExplorerProfileMetrics(discoveries: [next]).rare, 0)
    }
}
