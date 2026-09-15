import Foundation

struct PreparedReference: Codable, Equatable, Hashable {
    var id: String
    var version: Int
    var key: String { "\(id.lowercased()):\(version)" }
}

struct PreparedAsset: Codable, Equatable, Hashable {
    var path: String
    var sha256: String
    var bytes: Int

    func isValid(extension kind: String) -> Bool {
        bytes > 0 && bytes <= 12_000_000 && sha256.range(of: "^[a-f0-9]{64}$", options: .regularExpression) != nil &&
            path == "/api/knowledge-assets/\(sha256).\(kind)"
    }
}

struct PreparedSource: Codable, Equatable {
    var url: String
    var sha256: String
}

struct PreparedContent: Codable, Equatable, Identifiable {
    var id: String
    var version: Int
    var topicID: String
    var language: String
    var minAge: Int
    var maxAge: Int
    var question: String
    var reply: AIReply
    var policy: String
    var verifiedAt: Double
    var reviewAt: Double
    var expiresAt: Double
    var artwork: PreparedAsset
    var narration: PreparedAsset?
    var speechRevision: String
    var sources: [PreparedSource]
    var bundledArtwork: String? = nil

    var reference: PreparedReference { PreparedReference(id: id.lowercased(), version: version) }
    var expiry: Date { Date(timeIntervalSince1970: expiresAt / 1000) }
    var isValid: Bool {
        UUID(uuidString: id) != nil && version > 0 && policy == "discovery-v1" &&
            topicID.range(of: "^[a-z][a-z0-9-]{2,79}$", options: .regularExpression) != nil &&
            AppLanguage(rawValue: language) != nil && minAge >= 5 && maxAge <= 18 && minAge <= maxAge &&
            !question.isEmpty && question.count <= 240 && !reply.answer.isEmpty && reply.answer.count <= 1600 && reply.quiz.isValid &&
            verifiedAt.isFinite && verifiedAt > 0 && reviewAt >= verifiedAt && expiresAt > reviewAt &&
            artwork.isValid(extension: "png") && (narration?.isValid(extension: "wav") ?? true) && !sources.isEmpty
    }

    func isEligible(language: String, age: Int, at date: Date) -> Bool {
        isValid && self.language == language && age >= minAge && age <= maxAge && expiry > date
    }
}

struct ContentWithdrawal: Codable, Equatable {
    var id: String
    var version: Int
    var reason: String
    var reference: PreparedReference { PreparedReference(id: id, version: version) }
}

struct RecommendationCatalog: Codable, Equatable {
    var schemaVersion: Int
    var revision: String
    var serverTime: Double
    var refreshAfterSeconds: Int
    var items: [PreparedContent]
    var withdrawals: [ContentWithdrawal]
}

enum RecommendationError: Error {
    case invalidCatalog, invalidAsset, unavailable
    case retryAfter(TimeInterval)
}
