import Foundation

enum LegacyProfileMigration {
    static var preferences: UserDefaults {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            return UserDefaults(suiteName: "PocketExplorerUITestProfile")!
        }
        #endif
        return .standard
    }

    static func draft(from preferences: UserDefaults = preferences, language: String = AppLanguage.current.rawValue,
                      timeZone: String = TimeZone.current.identifier) -> ExplorerProfile? {
        guard let data = preferences.data(forKey: "explorer-profile"),
              let saved = try? JSONDecoder().decode(LocalProfile.self, from: data),
              let age = saved.age, (5...18).contains(age) else { return nil }
        let name = saved.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let avatar = saved.avatar == "doudou" ? "dou-dou" : saved.avatar ?? "mimi"
        let interests = Set((saved.interests ?? []).map { $0 == "bugs" ? "nature" : $0 })
        let profile = ExplorerProfile(nickname: name, avatar: avatar, age: age, language: language,
                                      interests: interests.filter { ExplorerProfile.interestChoices.contains($0) }.sorted(),
                                      learningLevel: 1, timeZone: timeZone)
        return profile.isValid ? profile : nil
    }

    private struct LocalProfile: Decodable {
        let displayName: String
        let avatar: String?
        let age: Int?
        let interests: [String]?
    }
}

struct ExplorerProfileMetrics: Equatable {
    let discoveries: Int
    let places: Int
    let rare: Int
    init(discoveries: [Discovery], trips: [Trip] = []) {
        let unlocked = discoveries.filter(\.isUnlocked)
        self.discoveries = Set(unlocked.map(\.collectionID)).count
        let tripPlaces = Dictionary(uniqueKeysWithValues: trips.compactMap { trip in trip.place.map { (trip.id, $0) } })
        places = Set(unlocked.compactMap { ($0.place ?? tripPlaces[$0.tripID])?.id }).count
        rare = Set(unlocked.filter { [.rare, .epic].contains($0.collectible?.tier ?? $0.tier ?? .fieldFind) }.map(\.collectionID)).count
    }
}
