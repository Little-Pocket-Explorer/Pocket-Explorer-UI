import Foundation

struct ExplorerFriend: Codable, Equatable, Identifiable {
    var id: String
    var profileID: String
    var nickname: String?
    var avatar: String
    var state: String
    var available: Bool
    var blocked: Bool
    var displayName: String { nickname ?? L10n.text("Explorer friend") }
    var isValid: Bool {
        UUID(uuidString: id) != nil && UUID(uuidString: profileID) != nil &&
        ["mimi", "dou-dou", "aj"].contains(avatar) && ["incoming", "outgoing", "accepted", "removed"].contains(state)
    }
    var canInteract: Bool { state == "accepted" && available && !blocked }
}
struct ExplorerMessage: Codable, Equatable, Identifiable {
    var sequence: Int
    var requestID: String
    var text: String
    var createdAt: Double
    var mine: Bool
    var id: Int { sequence }
    enum CodingKeys: String, CodingKey { case sequence, requestID = "id", text, createdAt, mine }
    var isValid: Bool { sequence > 0 && UUID(uuidString: requestID) != nil && !text.isEmpty && text.utf16.count <= 1000 }
}
struct CardTransfer: Codable, Equatable, Identifiable {
    struct Card: Codable, Equatable { var id: String; var title: String; var version: Int }
    var id: String
    var requestID: String
    var friendshipID: String
    var kind: String
    var outgoing: Bool
    var state: String
    var offered: Card
    var wanted: Card?
    var createdAt: Double
    var receivedCardID: String?
    var isValid: Bool {
        [id, requestID, friendshipID, offered.id].allSatisfy { UUID(uuidString: $0) != nil } &&
        ["gift", "exchange"].contains(kind) && ["pending", "accepted", "declined", "cancelled"].contains(state) &&
        (1...30).contains(offered.version) && (kind == "exchange") == (wanted != nil) &&
        (wanted == nil || UUID(uuidString: wanted!.id) != nil && (1...30).contains(wanted!.version)) &&
        (receivedCardID == nil || state == "accepted" && UUID(uuidString: receivedCardID!) != nil)
    }
}
struct SocialPage<Item: Codable>: Codable { var items: [Item]; var next: Int? }
struct MessageDraft: Codable, Equatable { var id: String; var text: String }
struct TransferDraft: Codable, Equatable {
    var id: String
    var kind: String
    var offeredID: String
    var wantedID: String?
    var wantedTitle: String? = nil
}
enum SocialError: Error, LocalizedError, Equatable {
    case unavailable, invalidResponse, friendUnavailable, code, changed, invalidText, saveFailed
    var errorDescription: String? {
        switch self {
        case .unavailable: L10n.text("Friends are offline. Your draft is saved. Try again when connected.")
        case .invalidResponse: L10n.text("This update could not be verified. Please refresh.")
        case .friendUnavailable: L10n.text("This friendship is unavailable. Ask a grown-up to check your settings.")
        case .code: L10n.text("Check your friend's private code and try again.")
        case .changed: L10n.text("This request has changed. Refresh before trying again.")
        case .invalidText: L10n.text("Write a message of up to 1,000 characters.")
        case .saveFailed: L10n.text("Your draft could not be saved. Free some space and try again.")
        }
    }
    static func from(_ code: String) -> Error {
        switch code {
        case "family_feature_disabled", "family_time_finished", "family_required": FamilyError.from(code)
        case "friend_not_found", "friend_unavailable", "private_card", "artwork_not_found": Self.friendUnavailable
        case "friend_code_unavailable": Self.code
        case "friend_request_changed", "message_changed", "transfer_changed", "transfer_not_yours", "transfer_not_found", "report_changed": Self.changed
        default: Self.unavailable
        }
    }
}
