import Foundation

struct ExplorerProfile: Codable, Equatable {
    var nickname = "Explorer"
    var avatar = "mimi"
    var age = 7
    var language = "en"
    var interests: [String] = []
    var learningLevel = 1
    var timeZone = TimeZone.current.identifier

    static let interestChoices = ["nature", "science", "animals", "space", "history", "culture"]
    var isValid: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && nickname.count <= 24 &&
        ["mimi", "dou-dou", "aj"].contains(avatar) && (5...18).contains(age) &&
        AppLanguage(rawValue: language) != nil && (1...3).contains(learningLevel) &&
        Set(interests).count == interests.count && interests.allSatisfy { Self.interestChoices.contains($0) } &&
        TimeZone(identifier: timeZone) != nil
    }
}

struct FamilyPolicy: Codable, Equatable {
    var exploration = true
    var events = true
    var sharing = true
    var social = false
    var mapSharing = false
    var nameSharing = false
    var citySharing = false
    var dailyMinutes = 30
}

enum FamilyFeature: String { case exploration, events, sharing, social, mapSharing }

struct FamilyUsage: Codable, Equatable { var day: String; var seconds: Int; var serverTime: Double }
struct ExplorerFamily: Codable, Equatable {
    var id: String
    var friendCode: String
    var profile: ExplorerProfile
    var policy: FamilyPolicy
    var revision: Int
    var createdAt: Double
    var usage: FamilyUsage

    var isValid: Bool {
        UUID(uuidString: id) != nil && friendCode.range(of: "^[A-F0-9]{12}$", options: .regularExpression) != nil &&
        profile.isValid && revision > 0 && (0...240).contains(policy.dailyMinutes) && usage.seconds >= 0 &&
        usage.day.range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression) != nil
    }
    func permits(_ feature: FamilyFeature) -> Bool {
        switch feature {
        case .exploration: policy.exploration
        case .events: policy.events
        case .sharing: policy.sharing
        case .social: policy.social
        case .mapSharing: policy.mapSharing && policy.sharing
        }
    }
}

struct ParentSession: Codable { var token: String; var expiresAt: Double }
struct FamilyResponse: Decodable {
    var family: ExplorerFamily?
    var parent: ParentSession?
    var recoveryCode: String?
}
struct UsageEntry: Codable, Equatable, Identifiable {
    var id = UUID()
    var day: String
    var seconds: Int
}

enum FamilyError: String, Error, LocalizedError {
    case unavailable, invalidResponse, invalidProfile, saveFailed
    case parentRequired, incorrectPIN, incorrectRecovery, tryLater, changed, disabled, timeFinished
    var errorDescription: String? {
        let key: String
        switch self {
        case .unavailable: key = "Family settings are offline. Your saved settings still apply."
        case .invalidResponse: key = "Family settings could not be read. Please try again."
        case .invalidProfile: key = "Check the explorer profile and use a six-digit PIN."
        case .saveFailed: key = "Family settings could not be saved on this phone."
        case .parentRequired: key = "Ask a grown-up to unlock family settings."
        case .incorrectPIN: key = "That PIN does not match. Please try again."
        case .incorrectRecovery: key = "That recovery code does not match."
        case .tryLater: key = "Please wait 15 minutes before trying again."
        case .changed: key = "Settings changed. Review the latest settings and try again."
        case .disabled: key = "Your family has paused this feature."
        case .timeFinished: key = "Time for a screen break. Your discoveries will be here tomorrow."
        }
        return L10n.text(key)
    }
    static func from(_ code: String) -> Self {
        switch code {
        case "parent_required", "family_required": .parentRequired
        case "parent_pin_incorrect": .incorrectPIN
        case "parent_recovery_incorrect": .incorrectRecovery
        case "parent_try_later", "please_wait": .tryLater
        case "family_changed", "family_exists", "family_day_changed": .changed
        case "family_feature_disabled": .disabled
        case "family_time_finished": .timeFinished
        case "invalid_request", "invalid_input": .invalidProfile
        default: .unavailable
        }
    }
}
