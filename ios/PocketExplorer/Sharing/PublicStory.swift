import Foundation

struct PublicCard: Codable, Equatable, Identifiable {
    var id: String
    var subject: DiscoverySubject
    var title: String
    var question: String
    var observation: String
    var explanation: String
    var artworkID: String? = nil
    var language: String? = nil
}

struct PublicStory: Codable, Equatable {
    var version = 1
    var title: String
    var firstName: String?
    var city: String?
    var cards: [PublicCard]
    var chapters: [MemoryChapter]
    var language: String? = nil

    static func make(trip: Trip, discoveries: [Discovery], firstName: String? = nil, includeCity: Bool = false) -> PublicStory {
        let selected = discoveries.filter { $0.tripID == trip.id && $0.isUnlocked }
        let cleanName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines)
        return PublicStory(title: trip.title, firstName: cleanName?.isEmpty == false ? cleanName : nil,
                           city: includeCity ? trip.place?.name : nil,
                           cards: selected.map { PublicCard(id: $0.id.uuidString, subject: $0.subject, title: $0.title, question: $0.question, observation: $0.observation, explanation: $0.explanation, artworkID: $0.artwork?.status == "ready" ? $0.artwork?.id : nil, language: $0.language) },
                           chapters: MemoryBuilder.build(tripID: trip.id, discoveries: selected).chapters, language: trip.language)
    }
}

struct ShareReceipt: Codable, Equatable {
    var token: String
    var url: URL
}

struct PublishedShare: Codable, Equatable {
    var receipt: ShareReceipt
    var story: PublicStory
}

struct ShareConnection: Codable, Equatable {
    var baseURL: String
    var ownerKey: String

    var validatedURL: URL? {
        guard let url = URL(string: baseURL), let host = url.host,
              url.user == nil, url.password == nil, url.query == nil, url.fragment == nil,
              url.path.isEmpty || url.path == "/", ownerKey.count >= 32 else { return nil }
        if url.scheme == "https" { return url }
        #if DEBUG
        if url.scheme == "http", host == "localhost" || host == "127.0.0.1" { return url }
        #endif
        return nil
    }
}

enum ShareError: LocalizedError {
    case configuration, unauthorized, unavailable, invalidResponse, rateLimited
    var errorDescription: String? {
        switch self {
        case .configuration: return L10n.text("This iPhone could not prepare sharing. Your story is safe. Please try again.")
        case .unauthorized: return L10n.text("Sharing could not verify this iPhone. Your story is safe. Please try again.")
        case .rateLimited: return L10n.text("A little pause. Please wait a minute before creating another link.")
        case .unavailable: return L10n.text("Your story is safe on this iPhone. Sharing could not finish. Please try again.")
        case .invalidResponse: return L10n.text("The sharing service returned an unexpected response. No link has been copied.")
        }
    }
}
