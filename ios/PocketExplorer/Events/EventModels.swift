import Foundation

struct ExplorerCoordinate: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var isValid: Bool { latitude.isFinite && longitude.isFinite && (-90...90).contains(latitude) && (-180...180).contains(longitude) }
}

struct LocationReading: Equatable {
    var coordinate: ExplorerCoordinate
    var accuracy: Double
    var observedAt: Date
    func isFresh(now: Date = .now, radius: Double = 200) -> Bool {
        coordinate.isValid && accuracy >= 0 && accuracy <= min(100, radius / 2) &&
        now.timeIntervalSince(observedAt) <= 120 && observedAt.timeIntervalSince(now) <= 30
    }
}

struct ExplorerEvent: Codable, Equatable, Identifiable {
    struct Challenge: Codable, Equatable { var question: String; var choices: [String] }
    var id: String
    var revision: Int
    var title: String
    var description: String
    var language: String
    var organizer: String
    var place: String
    var location: ExplorerCoordinate
    var radius: Double
    var startsAt: Double
    var endsAt: Double
    var minAge: Int
    var maxAge: Int
    var background: String
    var demonstration: Bool
    var challenge: Challenge
    var artworkPath: String
    var distance: Double?
    var isValid: Bool {
        UUID(uuidString: id) != nil && revision > 0 && location.isValid && (50...1000).contains(radius) &&
        startsAt < endsAt && minAge >= 5 && maxAge <= 18 && minAge <= maxAge &&
        AppLanguage(rawValue: language) != nil && ["stargazing", "tidepool", "fossil"].contains(background) &&
        challenge.choices.count == 3 && artworkPath == "/api/events/\(id)/artwork?language=\(language)"
    }
    var meetingPlace: Place { Place(name: place, latitude: location.latitude, longitude: location.longitude) }
    func isActive(now: Date = .now) -> Bool { (startsAt..<endsAt).contains(now.timeIntervalSince1970 * 1000) }
}

struct NearbyEvents: Codable, Equatable { var items: [ExplorerEvent]; var truncated: Bool }
struct SharedMapCard: Codable, Equatable, Identifiable {
    var id: String
    var location: ExplorerCoordinate
    var publishedAt: Double
    var title: String
    var question: String
    var answer: String
    var category: String
    var language: String
    var version: Int
    var tier: CardTier
    var artworkPath: String?
    var isValid: Bool {
        UUID(uuidString: id) != nil && location.isValid && version > 0 && AppLanguage(rawValue: language) != nil &&
        (artworkPath == nil || artworkPath == "/api/map-discoveries/\(id)/artwork")
    }
}
struct NearbyCards: Codable { var items: [SharedMapCard]; var truncated: Bool }
struct MapPublication: Codable, Equatable, Identifiable {
    var id: String
    var collectibleID: String
    var latitude: Double
    var longitude: Double
    var revoked: Int
}
struct EventClaim: Codable {
    var correct: Bool
    var explanation: String?
    var correctIndex: Int?
    var collectible: KnowledgeCard?
}

enum EventError: Error, LocalizedError {
    case unavailable, invalidResponse, location, tooFar, changed, inactive, age, language
    var errorDescription: String? {
        switch self {
        case .unavailable: L10n.text("Events are offline. Your collected cards are safe. Try again when connected.")
        case .invalidResponse: L10n.text("This event could not be verified. Please refresh it.")
        case .location: L10n.text("Refresh your location before trying the event challenge.")
        case .tooFar: L10n.text("Visit the event location with a grown-up to collect this card.")
        case .changed: L10n.text("The event has changed. Refresh its details and try again.")
        case .inactive: L10n.text("This event is not open right now.")
        case .age: L10n.text("This event is for a different age group.")
        case .language: L10n.text("This event is not available in your language yet.")
        }
    }
    static func from(_ code: String) -> Error {
        switch code {
        case "event_location_stale": return Self.location
        case "event_too_far": return Self.tooFar
        case "event_changed", "event_request_conflict": return Self.changed
        case "event_not_active", "event_unavailable", "event_content_unavailable", "event_not_found": return Self.inactive
        case "event_age_restricted": return Self.age
        case "event_language_unavailable": return Self.language
        case "family_feature_disabled", "family_time_finished", "family_required": return FamilyError.from(code)
        default: return Self.unavailable
        }
    }
}
