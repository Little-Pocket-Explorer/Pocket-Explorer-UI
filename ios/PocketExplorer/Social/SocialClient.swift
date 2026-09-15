import Foundation

struct SocialClient {
    var session: URLSession = .shared
    private struct Failure: Decodable { var error: String }
    func friends(offset: Int = 0, connection: ShareConnection) async throws -> SocialPage<ExplorerFriend> {
        let page: SocialPage<ExplorerFriend> = try await send("api/social/friends?offset=\(offset)", connection: connection)
        guard page.items.allSatisfy(\.isValid), page.next == nil || page.next! > offset else { throw SocialError.invalidResponse }; return page
    }
    func invite(_ code: String, connection: ShareConnection) async throws -> ExplorerFriend {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalized.range(of: "^[A-F0-9]{12}$", options: .regularExpression) != nil else { throw SocialError.code }
        let friend: ExplorerFriend = try await send("api/social/friends", body: JSONEncoder().encode(["code": normalized]), connection: connection)
        guard friend.isValid else { throw SocialError.invalidResponse }; return friend
    }
    func action(_ action: String, friendID: String, connection: ShareConnection) async throws -> ExplorerFriend {
        guard ["accept", "remove", "block", "unblock"].contains(action) else { throw SocialError.invalidResponse }
        let friend: ExplorerFriend = try await send(try path(friendID, "actions"), body: JSONEncoder().encode(["action": action]), connection: connection)
        guard friend.isValid, friend.id == friendID else { throw SocialError.invalidResponse }; return friend
    }
    func messages(_ id: String, after: Int = 0, connection: ShareConnection) async throws -> SocialPage<ExplorerMessage> {
        let page: SocialPage<ExplorerMessage> = try await send(try path(id, "messages?after=\(after)"), connection: connection)
        guard page.items.allSatisfy({ $0.isValid && $0.sequence > after }), page.items.map(\.sequence) == page.items.map(\.sequence).sorted(),
              Set(page.items.map(\.sequence)).count == page.items.count, page.next == nil || page.next == page.items.last?.sequence else { throw SocialError.invalidResponse }
        return page
    }
    func message(_ draft: MessageDraft, friendID: String, connection: ShareConnection) async throws -> ExplorerMessage {
        guard UUID(uuidString: draft.id) != nil, !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              draft.text.utf16.count <= 1000 else { throw SocialError.invalidText }
        let value: ExplorerMessage = try await send(try path(friendID, "messages"), body: JSONEncoder().encode(draft), connection: connection)
        guard value.isValid, value.mine, value.requestID == draft.id, value.text == draft.text.trimmingCharacters(in: .whitespacesAndNewlines) else { throw SocialError.invalidResponse }; return value
    }
    func cards(_ id: String, offset: Int = 0, connection: ShareConnection) async throws -> SocialPage<KnowledgeCard> {
        let page: SocialPage<KnowledgeCard> = try await send(try path(id, "collection?offset=\(offset)"), connection: connection)
        guard page.items.allSatisfy({ $0.isValid && $0.versions.allSatisfy { $0.audience == "public" } }), page.next == nil || page.next! > offset else { throw SocialError.invalidResponse }; return page
    }
    func transfers(_ id: String, offset: Int = 0, connection: ShareConnection) async throws -> SocialPage<CardTransfer> {
        let page: SocialPage<CardTransfer> = try await send(try path(id, "transfers?offset=\(offset)"), connection: connection)
        guard page.items.allSatisfy({ $0.isValid && $0.friendshipID == id }), page.next == nil || page.next! > offset else { throw SocialError.invalidResponse }; return page
    }
    func transfer(_ draft: TransferDraft, friendID: String, connection: ShareConnection) async throws -> CardTransfer {
        guard UUID(uuidString: draft.id) != nil, UUID(uuidString: draft.offeredID) != nil, ["gift", "exchange"].contains(draft.kind),
              (draft.kind == "exchange") == (draft.wantedID != nil), draft.wantedID == nil || UUID(uuidString: draft.wantedID!) != nil else { throw SocialError.invalidResponse }
        struct Request: Encodable { var id: String; var kind: String; var offeredID: String; var wantedID: String? }
        let body = try JSONEncoder().encode(Request(id: draft.id, kind: draft.kind, offeredID: draft.offeredID, wantedID: draft.wantedID))
        let value: CardTransfer = try await send(try path(friendID, "transfers"), body: body, connection: connection)
        guard value.isValid, value.friendshipID == friendID, value.requestID == draft.id else { throw SocialError.invalidResponse }; return value
    }
    func decide(_ decision: String, transferID: String, connection: ShareConnection) async throws -> CardTransfer {
        guard UUID(uuidString: transferID) != nil, ["accept", "decline", "cancel"].contains(decision) else { throw SocialError.invalidResponse }
        let value: CardTransfer = try await send("api/social/transfers/\(transferID)/actions", body: JSONEncoder().encode(["decision": decision]), connection: connection)
        guard value.isValid, value.id == transferID else { throw SocialError.invalidResponse }; return value
    }
    func report(_ id: UUID, friendID: String, messageID: String? = nil, reason: String, connection: ShareConnection) async throws {
        guard ["unkind", "privacy", "unsafe", "other"].contains(reason), messageID == nil || UUID(uuidString: messageID!) != nil else { throw SocialError.invalidResponse }
        struct Input: Encodable { var id: String; var messageID: String?; var reason: String; var details = "" }
        let result: [String: Bool] = try await send(try path(friendID, "reports"), body: JSONEncoder().encode(Input(id: id.uuidString.lowercased(), messageID: messageID, reason: reason)), connection: connection)
        guard result["recorded"] == true else { throw SocialError.invalidResponse }
    }
    func artwork(_ card: KnowledgeCard, friendID: String, connection: ShareConnection) async throws -> Data? {
        guard card.isValid else { throw SocialError.invalidResponse }
        guard let artwork = card.versions.last?.artworkID else { return nil }
        let bytes = try await data(try path(friendID, "collection/\(card.id)/artwork/\(artwork)"), connection: connection)
        guard bytes.count < 6_000_000 else { throw SocialError.invalidResponse }; return bytes
    }
    private func path(_ id: String, _ suffix: String) throws -> String {
        guard UUID(uuidString: id) != nil else { throw SocialError.invalidResponse }; return "api/social/friends/\(id)/\(suffix)"
    }
    private func send<T: Decodable>(_ path: String, body: Data? = nil, connection: ShareConnection) async throws -> T {
        let bytes = try await data(path, body: body, connection: connection)
        guard let value = try? JSONDecoder().decode(T.self, from: bytes) else { throw SocialError.invalidResponse }; return value
    }
    private func data(_ path: String, body: Data? = nil, connection: ShareConnection) async throws -> Data {
        guard let base = connection.validatedURL, let url = URL(string: path, relativeTo: base.appendingPathComponent("/"))?.absoluteURL else { throw SocialError.unavailable }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = body == nil ? "GET" : "POST"; request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bytes: Data, response: URLResponse
        do { (bytes, response) = try await session.data(for: request) }
        catch {
            if Task.isCancelled || (error as? URLError)?.code == .cancelled { throw CancellationError() }; throw SocialError.unavailable
        }
        guard let http = response as? HTTPURLResponse else { throw SocialError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw SocialError.from((try? JSONDecoder().decode(Failure.self, from: bytes).error) ?? "unknown") }; return bytes
    }
}
