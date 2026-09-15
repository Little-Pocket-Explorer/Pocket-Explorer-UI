import Foundation

struct ExplorerProfile: Codable, Equatable {
    var email: String
    var displayName: String
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

    static func clear() { preferences.removeObject(forKey: key) }

    private static func isEmailAddress(_ value: String) -> Bool {
        value.range(of: "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", options: .regularExpression) != nil
    }
}

enum ProfileError: LocalizedError {
    case invalidEmail

    var errorDescription: String? { L10n.text("Enter a valid email address.") }
}