import Foundation

enum CardStyle: String, Codable, CaseIterable, Identifiable {
    case forest, ocean, cosmos
    var id: String { rawValue }
    var title: String { L10n.text(rawValue.capitalized) }
}

struct KnowledgeVersion: Codable, Equatable, Identifiable {
    var version: Int
    var explorationID: String
    var question: String
    var language: String
    var reply: AIReply
    var awardedAt: Double
    var artworkID: String?
    var audience: String
    var id: Int { version }
}

struct CardOrigin: Codable, Equatable {
    var kind: String
    var sourceID: String
    var label: String
    var displayLabel: String { label.isEmpty ? L10n.text(kind == "exchange" ? "A card exchange" : "A discovery gift") : label }
}

struct KnowledgeCard: Codable, Equatable, Identifiable {
    var id: String
    var style: CardStyle
    var createdAt: Double
    var updatedAt: Double
    var tier: CardTier
    var versions: [KnowledgeVersion]
    var origin: CardOrigin? = nil
    var isValid: Bool {
        (origin == nil || ["event", "gift", "exchange"].contains(origin!.kind) && UUID(uuidString: origin!.sourceID) != nil) &&
        UUID(uuidString: id) != nil && !versions.isEmpty && versions.count <= 30 &&
        tier != .fieldFind && Set(versions.map(\.explorationID)).count == versions.count &&
        versions.enumerated().allSatisfy { index, value in
            value.version == index + 1 && UUID(uuidString: value.explorationID) != nil && value.reply.quiz.isValid &&
            AppLanguage(rawValue: value.language) != nil && ["public", "demo"].contains(value.audience) &&
            (value.artworkID == nil || UUID(uuidString: value.artworkID!) != nil)
        }
    }
}

struct RecallAttempt: Codable, Equatable, Identifiable {
    var id = UUID()
    var discoveryID: UUID
    var explorationID: UUID
    var choice: Int
    var createdAt: Date
    var failure: String?
}

struct RecallReceipt: Codable, Equatable {
    var correct: Bool
    var explanation: String
    var correctIndex: Int
    var collectible: KnowledgeCard?
}

enum CollectibleError: String, Error, LocalizedError {
    case unavailable, invalidResponse, pending, newDiscovery, versionLimit, requestConflict
    var errorDescription: String? {
        switch self {
        case .unavailable: L10n.text("Your answer is saved. We will sync your card when you are online.")
        case .invalidResponse: L10n.text("The card could not be verified. Please try again.")
        case .pending: L10n.text("Answer the little recall question to unlock this card.")
        case .newDiscovery: L10n.text("Try a new question about this card to help it grow.")
        case .versionLimit: L10n.text("This card has a full story. Start a new discovery next.")
        case .requestConflict: L10n.text("This answer has changed. Please try the question again.")
        }
    }
}
