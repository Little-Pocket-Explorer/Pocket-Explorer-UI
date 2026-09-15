import Foundation

struct ExplorerProfile: Codable, Equatable {
    var email: String
    var displayName: String
    var avatar: ExplorerAvatar? = nil
    var age: Int? = nil
    var gender: ExplorerGender? = nil
    var interests: [ExplorerInterest]? = nil
    var privacy: ExplorerPrivacy = .privateDefault
}

enum DiscoveryAudience: String, Codable, CaseIterable, Identifiable {
    case onlyMe, friends, everyone
    var id: String { rawValue }
    var title: String { self == .onlyMe ? "Only me" : self == .friends ? "Friends" : "Everyone" }
}

struct ExplorerPrivacy: Codable, Equatable {
    var audience: DiscoveryAudience = .onlyMe
    var shareLocation = false
    var allowSocial = true
    var allowPublicSharing = false
    var allowFriendRequests = true
    var notifications = true
    var dailyMinutes = 45
    static let privateDefault = ExplorerPrivacy()
}

enum ExplorerAvatar: String, Codable, CaseIterable, Identifiable {
    case mimi, doudou, aj
    var id: String { rawValue }
    var title: String { self == .mimi ? "Mimi" : self == .doudou ? "Dou Dou" : "AJ" }
    var imageName: String { self == .mimi ? "explorer-avatar" : self == .doudou ? "duck" : "keepsake" }
}

enum ExplorerGender: String, Codable, CaseIterable, Identifiable {
    case preferNotToSay, girl, boy
    var id: String { rawValue }
    var title: String { self == .preferNotToSay ? "Prefer not to say" : self == .girl ? "Girl" : "Boy" }
}

enum ExplorerInterest: String, Codable, CaseIterable, Identifiable {
    case bugs, nature, space, history, animals
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var icon: String { self == .bugs ? "ladybug.fill" : self == .nature ? "leaf.fill" : self == .space ? "globe.americas.fill" : self == .history ? "building.columns.fill" : "pawprint.fill" }
}

enum ProfileSettings {
    private static let key = "explorer-profile"

    static var preferences: UserDefaults {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            return UserDefaults(suiteName: "PocketExplorerUITestProfile")!
        }
        #endif
        return .standard
    }

    static var profile: ExplorerProfile? {
        guard let data = preferences.data(forKey: key),
              let profile = try? JSONDecoder().decode(ExplorerProfile.self, from: data),
              isEmailAddress(profile.email), !profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return profile
    }

    static func save(email: String, to defaults: UserDefaults = preferences) throws -> ExplorerProfile {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isEmailAddress(normalized) else { throw ProfileError.invalidEmail }
        let localPart = normalized.split(separator: "@").first.map(String.init) ?? "Explorer"
        let profile = ExplorerProfile(email: normalized, displayName: localPart.prefix(1).uppercased() + String(localPart.dropFirst()))
        defaults.set(try JSONEncoder().encode(profile), forKey: key)
        return profile
    }

    static func complete(_ profile: ExplorerProfile, nickname: String, avatar: ExplorerAvatar, age: Int, gender: ExplorerGender?, interests: [ExplorerInterest], to defaults: UserDefaults = preferences) throws -> ExplorerProfile {
        let name = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, name.count <= 24 else { throw ProfileError.invalidNickname }
        guard (3...18).contains(age) else { throw ProfileError.invalidAge }
        let completed = ExplorerProfile(email: profile.email, displayName: name, avatar: avatar, age: age, gender: gender, interests: Array(Set(interests)).sorted { $0.rawValue < $1.rawValue }, privacy: profile.privacy)
        defaults.set(try JSONEncoder().encode(completed), forKey: key)
        return completed
    }

    static func savePrivacy(_ privacy: ExplorerPrivacy, for profile: ExplorerProfile, to defaults: UserDefaults = preferences) throws -> ExplorerProfile {
        let updated = ExplorerProfile(email: profile.email, displayName: profile.displayName, avatar: profile.avatar, age: profile.age, gender: profile.gender, interests: profile.interests, privacy: privacy)
        return try save(updated, to: defaults)
    }

    static func save(_ profile: ExplorerProfile, to defaults: UserDefaults = preferences) throws -> ExplorerProfile {
        defaults.set(try JSONEncoder().encode(profile), forKey: key)
        return profile
    }

    static func isComplete(_ profile: ExplorerProfile) -> Bool {
        profile.avatar != nil && (3...18).contains(profile.age ?? 0) && !profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func clear() { preferences.removeObject(forKey: key) }

    private static func isEmailAddress(_ value: String) -> Bool {
        value.range(of: "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", options: .regularExpression) != nil
    }
}

enum ProfileError: LocalizedError {
    case invalidEmail, invalidNickname, invalidAge

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return L10n.text("Enter a valid email address.")
        case .invalidNickname: return L10n.text("Choose a nickname up to 24 characters.")
        case .invalidAge: return L10n.text("Choose an age from 3 to 18.")
        }
    }
}