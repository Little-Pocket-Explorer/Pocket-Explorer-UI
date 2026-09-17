import CryptoKit
import Foundation
import Observation

@MainActor @Observable final class SocialStore {
    private struct State: Codable {
        var owner = ""
        var messages: [String: MessageDraft] = [:]
        var transfers: [String: TransferDraft] = [:]
        var eventMessages: [String: MessageDraft]? = nil
        var readSequences: [String: Int]? = nil
    }
    private var state: State
    private let file: URL
    private let write: (Data, URL) throws -> Void
    var client: SocialClient
    private(set) var friends: [ExplorerFriend] = []
    private(set) var friendCursor: Int?
    private(set) var messages: [String: [ExplorerMessage]] = [:]
    private(set) var messageCursors: [String: Int] = [:]
    private var fetchedSequences: [String: Int] = [:]
    private(set) var cards: [String: [KnowledgeCard]] = [:]
    private(set) var cardCursors: [String: Int] = [:]
    private(set) var transfers: [String: [CardTransfer]] = [:]
    private(set) var transferCursors: [String: Int] = [:]
    private(set) var busy = false
    private var receiving = false

    init(file: URL, client: SocialClient = SocialClient(), writer: ((Data, URL) throws -> Void)? = nil) throws {
        self.file = file; self.client = client; self.write = writer ?? { try $0.write(to: $1, options: .atomic) }
        if FileManager.default.fileExists(atPath: file.path) {
            guard let bytes = try? Data(contentsOf: file), bytes.count < 2_000_000, let saved = try? JSONDecoder().decode(State.self, from: bytes) else { throw SocialError.saveFailed }
            state = saved
        } else { state = State() }
    }
    func draft(for id: String) -> String { state.messages[id]?.text ?? "" }
    func pendingTransfer(for id: String) -> TransferDraft? { state.transfers[id] }
    func unreadCount(for id: String) -> Int {
        let lastRead = state.readSequences?[id] ?? 0
        return messages[id, default: []].filter { !$0.mine && $0.sequence > lastRead }.count
    }
    func markRead(_ id: String) throws {
        guard let sequence = messages[id]?.last?.sequence, sequence > (state.readSequences?[id] ?? 0) else { return }
        var next = state; var reads = next.readSequences ?? [:]; reads[id] = sequence; next.readSequences = reads; try persist(next)
    }
    func clearAccess() { friends = []; friendCursor = nil; messages = [:]; messageCursors = [:]; fetchedSequences = [:]; cards = [:]; cardCursors = [:]; transfers = [:]; transferCursors = [:] }
    func bind(_ connection: ShareConnection) throws {
        let owner = SHA256.hash(data: Data("\(connection.baseURL):\(connection.ownerKey)".utf8)).map { String(format: "%02x", $0) }.joined()
        guard state.owner != owner else { return }; var next = State(); next.owner = owner; try persist(next); clearAccess()
    }
    func saveDraft(_ text: String, friendID: String, connection: ShareConnection) throws {
        try bind(connection)
        guard text.utf16.count <= 1000 else { throw SocialError.invalidText }
        var next = state
        if next.messages[friendID]?.text == text { return }
        next.messages[friendID] = text.isEmpty ? nil : MessageDraft(id: UUID().uuidString.lowercased(), text: text)
        try persist(next)
    }
    func refreshFriends(connection: ShareConnection, more: Bool = false) async throws {
        try bind(connection)
        let result = try await client.friends(offset: more ? friendCursor ?? 0 : 0, connection: connection)
        friends = more ? merge(friends, result.items) : result.items; friendCursor = result.next
    }
    func invite(_ code: String, connection: ShareConnection) async throws {
        try bind(connection); let friend = try await client.invite(code, connection: connection); friends = merge(friends, [friend])
    }
    func action(_ action: String, friendID: String, connection: ShareConnection) async throws {
        try bind(connection)
        let friend = try await client.action(action, friendID: friendID, connection: connection)
        friends = merge(friends, [friend])
        if !friend.canInteract {
            messages[friendID] = nil; fetchedSequences[friendID] = nil; cards[friendID] = nil; transfers[friendID] = nil
            var next = state; next.readSequences?[friendID] = nil; try persist(next)
        }
    }
    func refreshMessages(_ id: String, connection: ShareConnection) async throws {
        try bind(connection)
        do {
            let page = try await client.messages(id, after: fetchedSequences[id] ?? 0, connection: connection)
            messages[id] = merge(messages[id] ?? [], page.items).sorted { $0.sequence < $1.sequence }; messageCursors[id] = page.next
            if let sequence = page.items.last?.sequence { fetchedSequences[id] = sequence }
        } catch { if error is FamilyError || (error as? SocialError) == .friendUnavailable { messages[id] = nil; fetchedSequences[id] = nil }; throw error }
    }
    func send(_ id: String, connection: ShareConnection) async throws {
        try bind(connection)
        guard !busy, let draft = state.messages[id] else { throw SocialError.invalidText }
        busy = true; defer { busy = false }
        let sent = try await client.message(draft, friendID: id, connection: connection)
        messages[id] = merge(messages[id] ?? [], [sent]).sorted { $0.sequence < $1.sequence }
        if state.messages[id] == draft { var next = state; next.messages[id] = nil; try persist(next) }
    }
    func shareEvent(_ event: ExplorerEvent, friendID: String, connection: ShareConnection) async throws {
        try bind(connection)
        guard let base = connection.validatedURL else { throw ShareError.configuration }
        guard !busy else { throw SocialError.changed }
        let owner = state.owner
        busy = true; defer { busy = false }
        let key = "\(friendID):\(event.id)"
        if state.eventMessages?[key] == nil {
            var next = state
            var drafts = next.eventMessages ?? [:]
            drafts[key] = MessageDraft(id: UUID().uuidString.lowercased(), text: EventMessage(event: event, base: base).text)
            next.eventMessages = drafts
            try persist(next)
        }
        guard let draft = state.eventMessages?[key] else { throw SocialError.saveFailed }
        let sent = try await client.message(draft, friendID: friendID, connection: connection)
        guard state.owner == owner else { throw SocialError.changed }
        messages[friendID] = merge(messages[friendID] ?? [], [sent]).sorted { $0.sequence < $1.sequence }
        var next = state; next.eventMessages?[key] = nil; try persist(next)
    }

    func refreshCards(_ id: String, connection: ShareConnection, more: Bool = false) async throws {
        try bind(connection)
        do {
            let page = try await client.cards(id, offset: more ? cardCursors[id] ?? 0 : 0, connection: connection)
            cards[id] = more ? merge(cards[id] ?? [], page.items) : page.items; cardCursors[id] = page.next
        } catch { if error is FamilyError || (error as? SocialError) == .friendUnavailable { cards[id] = nil }; throw error }
    }
    func refreshTransfers(_ id: String, store: TripStore, connection: ShareConnection, more: Bool = false) async throws {
        try bind(connection)
        do {
            let page = try await client.transfers(id, offset: more ? transferCursors[id] ?? 0 : 0, connection: connection)
            for item in page.items { try await receive(item, store: store, connection: connection) }
            transfers[id] = more ? merge(transfers[id] ?? [], page.items) : page.items; transferCursors[id] = page.next
        } catch {
            if error is FamilyError || (error as? SocialError) == .friendUnavailable { transfers[id] = nil; transferCursors[id] = nil }
            throw error
        }
    }
    func synchronizeReceivedCards(store: TripStore, connection: ShareConnection) async throws {
        guard !receiving else { return }; receiving = true; defer { receiving = false }
        try bind(connection)
        let owner = state.owner, catalog = CollectibleClient(session: client.session)
        var offset = 0
        repeat {
            try Task.checkCancellation()
            let page = try await catalog.list(offset: offset, connection: connection)
            guard state.owner == owner else { throw SocialError.changed }
            for card in page.items where card.origin != nil && !store.state.discoveries.contains(where: { $0.collectionID == card.id }) {
                _ = try store.receiveCard(card)
            }
            guard let next = page.next else { return }; offset = next
        } while true
    }
    func offer(friendID: String, offeredID: String, wantedID: String?, wantedTitle: String? = nil, connection: ShareConnection) async throws -> CardTransfer {
        try bind(connection)
        guard !busy else { throw SocialError.changed }; busy = true; defer { busy = false }
        let kind = wantedID == nil ? "gift" : "exchange"
        var next = state
        if let pending = next.transfers[friendID] {
            guard pending.offeredID == offeredID, pending.wantedID == wantedID else { throw SocialError.changed }
        } else {
            next.transfers[friendID] = TransferDraft(id: UUID().uuidString.lowercased(), kind: kind, offeredID: offeredID, wantedID: wantedID, wantedTitle: wantedTitle); try persist(next)
        }
        let value = try await client.transfer(state.transfers[friendID]!, friendID: friendID, connection: connection)
        next = state; next.transfers[friendID] = nil; try persist(next)
        transfers[friendID] = merge(transfers[friendID] ?? [], [value]); return value
    }
    func decide(_ decision: String, transferID: String, store: TripStore, connection: ShareConnection) async throws {
        try bind(connection)
        let value = try await client.decide(decision, transferID: transferID, connection: connection)
        try await receive(value, store: store, connection: connection)
        transfers[value.friendshipID] = merge(transfers[value.friendshipID] ?? [], [value])
    }
    private func receive(_ transfer: CardTransfer, store: TripStore, connection: ShareConnection) async throws {
        guard let id = transfer.receivedCardID, !store.state.discoveries.contains(where: { $0.collectionID == id }) else { return }
        let card = try await CollectibleClient(session: client.session).read(id, connection: connection)
        _ = try store.receiveCard(card)
    }
    private func merge<T: Identifiable>(_ old: [T], _ new: [T]) -> [T] { old.filter { value in !new.contains { $0.id == value.id } } + new }
    private func persist(_ next: State) throws {
        do { try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true); try write(JSONEncoder().encode(next), file); state = next }
        catch { throw SocialError.saveFailed }
    }
}
