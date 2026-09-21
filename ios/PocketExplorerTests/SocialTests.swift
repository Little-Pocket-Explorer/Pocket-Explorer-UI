import XCTest
@testable import PocketExplorer

@MainActor final class SocialTests: XCTestCase {
    private let id = "11111111-1111-4111-8111-111111111111"
    private let requestID = "22222222-2222-4222-8222-222222222222"
    private let transferID = "33333333-3333-4333-8333-333333333333"
    private var folder: URL!
    private var session: URLSession!
    private var store: TripStore!
    private var client: SocialClient { SocialClient(session: session) }
    private let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    private var friend: ExplorerFriend { ExplorerFriend(id: id, profileID: requestID, nickname: "Nori", avatar: "aj", state: "accepted", available: true, blocked: false) }
    private var card: KnowledgeCard {
        let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Notice the sky.", category: "science", artworkPrompt: "Blue sky", quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air scatters light."))
        return KnowledgeCard(id: id, style: .forest, createdAt: 2000, updatedAt: 2000, tier: .common,
            versions: [KnowledgeVersion(version: 1, explorationID: requestID, question: "Why blue?", language: "en", reply: reply, awardedAt: 1000, artworkID: requestID, audience: "public")],
            origin: CardOrigin(kind: "gift", sourceID: transferID, label: ""))
    }
    private func transfer(_ kind: String = "gift", received: Bool = false) -> CardTransfer {
        CardTransfer(id: transferID, requestID: requestID, friendshipID: id, kind: kind, outgoing: !received, state: "accepted",
            offered: .init(id: id, title: "Blue sky", version: 1), wanted: kind == "exchange" ? .init(id: requestID, title: "Moon", version: 1) : nil,
            createdAt: 2000, receivedCardID: received ? id : nil)
    }
    override func setUp() async throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = try TripStore(fileURL: folder.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [DiscoveryHTTPProtocol.self]; session = URLSession(configuration: config)
        store.social.client = client
    }
    override func tearDown() async throws { session.invalidateAndCancel(); DiscoveryHTTPProtocol.respond = nil; try? FileManager.default.removeItem(at: folder) }
    private func respond<T: Encodable>(_ value: T, status: Int = 200) throws {
        let bytes = try JSONEncoder().encode(value)
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            return (status, [:], bytes)
        }
    }
    private func fails(_ operation: () async throws -> Void) async { do { try await operation(); XCTFail("Expected rejection") } catch {} }

    func testValidatesIdentitiesStatesAndGiftProvenance() throws {
        XCTAssertTrue(friend.isValid); XCTAssertTrue(friend.canInteract); XCTAssertEqual(friend.displayName, "Nori")
        var hidden = friend; hidden.nickname = nil; hidden.blocked = true; XCTAssertFalse(hidden.canInteract); XCTAssertFalse(hidden.displayName.isEmpty)
        hidden.id = "bad"; XCTAssertFalse(hidden.isValid)
        XCTAssertTrue(transfer().isValid); XCTAssertTrue(transfer("exchange").isValid)
        var invalid = transfer(); invalid.wanted = .init(id: "bad", title: "bad", version: 0); XCTAssertFalse(invalid.isValid)
        invalid = transfer(received: true); invalid.state = "pending"; XCTAssertFalse(invalid.isValid)
        var message = ExplorerMessage(sequence: 1, requestID: requestID, text: "Hello", createdAt: 2000, mine: true)
        XCTAssertTrue(message.isValid); XCTAssertEqual(message.id, 1); message.text = ""; XCTAssertFalse(message.isValid)
        let discovery = try store.receiveCard(card)
        XCTAssertEqual(discovery.createdAt.timeIntervalSince1970, 2); XCTAssertEqual(discovery.collectible?.versions.first?.awardedAt, 1000)
        XCTAssertFalse(card.origin!.displayLabel.isEmpty)
        var exchange = card.origin!; exchange.kind = "exchange"; XCTAssertFalse(exchange.displayLabel.isEmpty)
        for code in ["family_feature_disabled", "family_time_finished", "family_required", "friend_not_found", "friend_code_unavailable", "message_changed", "transfer_changed", "unknown"] { XCTAssertFalse(SocialError.from(code).localizedDescription.isEmpty) }
        for value in [SocialError.unavailable, .invalidResponse, .friendUnavailable, .code, .changed, .invalidText, .saveFailed] { XCTAssertFalse(value.localizedDescription.isEmpty) }
        XCTAssertNil(socialRefreshErrorMessage(CancellationError(), taskCancelled: false))
        XCTAssertNil(socialRefreshErrorMessage(SocialError.unavailable, taskCancelled: true))
        XCTAssertEqual(socialRefreshErrorMessage(SocialError.unavailable, taskCancelled: false), SocialError.unavailable.localizedDescription)
    }
    func testClientUsesAuthenticatedValidatedRoutesAndRejectsUnexpectedResponses() async throws {
        try respond(SocialPage(items: [friend], next: 50)); let friends = try await client.friends(connection: connection); XCTAssertEqual(friends.items, [friend])
        try respond(friend); let invited = try await client.invite(" abcdef123456 ", connection: connection); XCTAssertEqual(invited, friend)
        let changed = try await client.action("accept", friendID: id, connection: connection); XCTAssertEqual(changed, friend)
        let message = ExplorerMessage(sequence: 1, requestID: requestID, text: "Hello", createdAt: 1, mine: true)
        try respond(message); let sent = try await client.message(.init(id: requestID, text: " Hello "), friendID: id, connection: connection); XCTAssertEqual(sent, message)
        try respond(SocialPage(items: [message], next: 1)); let page = try await client.messages(id, connection: connection); XCTAssertEqual(page.next, 1)
        try respond(SocialPage(items: [card], next: 50)); let cards = try await client.cards(id, connection: connection); XCTAssertEqual(cards.items, [card])
        try respond(SocialPage(items: [transfer()], next: 30)); let gifts = try await client.transfers(id, connection: connection); XCTAssertEqual(gifts.items.count, 1)
        try respond(transfer()); let gift = try await client.transfer(.init(id: requestID, kind: "gift", offeredID: id), friendID: id, connection: connection); XCTAssertEqual(gift.kind, "gift")
        let accepted = try await client.decide("accept", transferID: transferID, connection: connection); XCTAssertEqual(accepted.id, transferID)
        try respond(["recorded": true]); try await client.report(UUID(), friendID: id, reason: "privacy", connection: connection)
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data([1, 2, 3])) }
        let art = try await client.artwork(card, friendID: id, connection: connection); XCTAssertEqual(art, Data([1, 2, 3]))
        var noArt = card; noArt.versions[0].artworkID = nil; let absent = try await client.artwork(noArt, friendID: id, connection: connection); XCTAssertNil(absent)
        await fails { _ = try await self.client.invite("bad", connection: self.connection) }
        await fails { _ = try await self.client.action("bad", friendID: self.id, connection: self.connection) }
        await fails { _ = try await self.client.messages("bad", connection: self.connection) }
        await fails { _ = try await self.client.message(.init(id: self.requestID, text: "  "), friendID: self.id, connection: self.connection) }
        await fails { _ = try await self.client.transfer(.init(id: self.requestID, kind: "exchange", offeredID: self.id), friendID: self.id, connection: self.connection) }
        await fails { _ = try await self.client.decide("bad", transferID: self.id, connection: self.connection) }
        await fails { try await self.client.report(UUID(), friendID: self.id, reason: "bad", connection: self.connection) }
        await fails { _ = try await self.client.friends(connection: self.connection) }
        try respond(SocialPage(items: [friend], next: 0)); await fails { _ = try await self.client.friends(connection: self.connection) }
        try respond(SocialPage(items: [message, message], next: nil)); await fails { _ = try await self.client.messages(self.id, connection: self.connection) }
        try respond(["recorded": false]); await fails { try await self.client.report(UUID(), friendID: self.id, reason: "other", connection: self.connection) }
        try respond(["error": "friend_unavailable"], status: 403); await fails { _ = try await self.client.friends(connection: self.connection) }
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.timedOut) }; await fails { _ = try await self.client.friends(connection: self.connection) }
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.cancelled) }
        do { _ = try await client.friends(connection: connection); XCTFail("Cancelled") } catch { XCTAssertTrue(error is CancellationError) }
        await fails { _ = try await self.client.friends(connection: ShareConnection(baseURL: "bad", ownerKey: "bad")) }
    }
    func testDurableDraftRetryAndUnreadMessagesCannotBeSkippedBySending() async throws {
        let social = store.social
        try social.saveDraft("Hello", friendID: id, connection: connection)
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await fails { try await social.send(self.id, connection: self.connection) }
        let restored = try SocialStore(file: folder.appendingPathComponent("social.json"), client: client)
        XCTAssertEqual(restored.draft(for: id), "Hello")
        var sentID = ""
        DiscoveryHTTPProtocol.respond = { request in
            let input = try JSONDecoder().decode(MessageDraft.self, from: request.httpBody ?? self.body(request))
            sentID = input.id
            return (200, [:], try JSONEncoder().encode(ExplorerMessage(sequence: 3, requestID: input.id, text: input.text, createdAt: 3, mine: true)))
        }
        try await restored.send(id, connection: connection); XCTAssertEqual(restored.draft(for: id), "")
        let incoming = ExplorerMessage(sequence: 2, requestID: sentID, text: "I saw a leaf!", createdAt: 2, mine: false)
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems?.first?.value, "0")
            return (200, [:], try JSONEncoder().encode(SocialPage(items: [incoming], next: nil)))
        }
        try await restored.refreshMessages(id, connection: connection)
        XCTAssertEqual(restored.messages[id]?.map(\.sequence), [2, 3])
        XCTAssertEqual(restored.unreadCount(for: id), 1)
        try restored.markRead(id); XCTAssertEqual(restored.unreadCount(for: id), 0)
        let readAgain = try SocialStore(file: folder.appendingPathComponent("social.json"), client: client)
        XCTAssertEqual(readAgain.unreadCount(for: id), 0)
        try respond(["error": "friend_unavailable"], status: 403); await fails { try await restored.refreshMessages(self.id, connection: self.connection) }
        XCTAssertNil(restored.messages[id])
        try restored.saveDraft("Another thought", friendID: id, connection: connection)
        try restored.bind(ShareConnection(baseURL: connection.baseURL, ownerKey: "pe1_" + String(repeating: "b", count: 64)))
        XCTAssertEqual(restored.draft(for: id), "")
        await fails { try await restored.send(self.id, connection: self.connection) }
        XCTAssertThrowsError(try restored.saveDraft(String(repeating: "a", count: 1001), friendID: id, connection: connection))
        let broken = try SocialStore(file: folder.appendingPathComponent("broken.json"), writer: { _, _ in throw SocialError.saveFailed })
        XCTAssertThrowsError(try broken.bind(connection))
        try Data("bad".utf8).write(to: folder.appendingPathComponent("corrupt.json"))
        XCTAssertThrowsError(try SocialStore(file: folder.appendingPathComponent("corrupt.json")))
    }
    func testFriendsCollectionTransfersAndReceiptPersistence() async throws {
        let social = store.social
        try respond(friend); try await social.invite("ABCDEF123456", connection: connection)
        try respond(SocialPage(items: [friend], next: 50)); try await social.refreshFriends(connection: connection)
        try respond(SocialPage(items: [friend], next: nil)); try await social.refreshFriends(connection: connection, more: true)
        XCTAssertEqual(social.friends.count, 1)
        try respond(SocialPage(items: [card], next: 50)); try await social.refreshCards(id, connection: connection)
        try respond(SocialPage(items: [card], next: nil)); try await social.refreshCards(id, connection: connection, more: true)
        XCTAssertEqual(social.cards[id]?.count, 1)
        var artworkRequests = 0
        DiscoveryHTTPProtocol.respond = { _ in artworkRequests += 1; return (200, [:], Data([1, 2, 3])) }
        XCTAssertEqual(try await social.artwork(card, friendID: id, connection: connection), Data([1, 2, 3]))
        XCTAssertEqual(try await social.artwork(card, friendID: id, connection: connection), Data([1, 2, 3]))
        XCTAssertEqual(artworkRequests, 1)
        try respond(["error": "friend_unavailable"], status: 403); await fails { try await social.refreshCards(self.id, connection: self.connection) }; XCTAssertNil(social.cards[id])
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await fails { _ = try await social.offer(friendID: self.id, offeredID: self.id, wantedID: nil, connection: self.connection) }
        let pending = try XCTUnwrap(social.pendingTransfer(for: id))
        await fails { _ = try await social.offer(friendID: self.id, offeredID: self.requestID, wantedID: nil, connection: self.connection) }
        var accepted = transfer(); accepted.requestID = pending.id
        try respond(accepted); _ = try await social.offer(friendID: id, offeredID: id, wantedID: nil, connection: connection)
        XCTAssertNil(social.pendingTransfer(for: id)); XCTAssertEqual(social.transfers[id]?.count, 1)
        let receipt = transfer(received: true), card = self.card
        DiscoveryHTTPProtocol.respond = { request in
            if request.url!.path.hasPrefix("/api/collectibles/") { return (200, [:], try JSONEncoder().encode(["collectible": card])) }
            return (200, [:], try JSONEncoder().encode(SocialPage(items: [receipt], next: 30)))
        }
        try await social.refreshTransfers(id, store: store, connection: connection)
        try respond(SocialPage(items: [receipt], next: nil))
        try await social.refreshTransfers(id, store: store, connection: connection, more: true)
        XCTAssertEqual(store.state.discoveries.count, 1); XCTAssertTrue(store.state.discoveries[0].isVerified)
        try respond(["error": "friend_unavailable"], status: 403)
        await fails { try await social.refreshTransfers(self.id, store: self.store, connection: self.connection) }
        XCTAssertNil(social.transfers[id])
        XCTAssertNil(social.transferCursors[id])
        let reload = try TripStore(fileURL: store.fileURL); XCTAssertEqual(reload.state.discoveries[0].collectible, card)
        try respond(receipt); try await social.decide("accept", transferID: transferID, store: store, connection: connection)
        var removed = friend; removed.state = "removed"; try respond(removed); try await social.action("remove", friendID: id, connection: connection)
        XCTAssertNil(social.cards[id]); XCTAssertNil(social.transfers[id]); social.clearAccess(); XCTAssertTrue(social.friends.isEmpty)
    }
    private func body(_ request: URLRequest) -> Data {
        guard let stream = request.httpBodyStream else { return Data() }; stream.open(); defer { stream.close() }
        var bytes = Data(), buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable { let count = stream.read(&buffer, maxLength: buffer.count); if count <= 0 { break }; bytes.append(buffer, count: count) }
        return bytes
    }
    private var event: ExplorerEvent {
        ExplorerEvent(id: transferID, revision: 1, title: "Sky watchers", description: "Look at the sky.", language: "en", organizer: "Nature club", place: "Park",
            location: .init(latitude: 0, longitude: 0), radius: 200, startsAt: 0, endsAt: 9999999999999, minAge: 5, maxAge: 18, background: "stargazing",
            demonstration: true, challenge: .init(question: "Why blue?", choices: ["Air", "Paint", "Moon"]), artworkPath: "/api/events/\(transferID)/artwork?language=en")
    }
    func testEventMessagesOnlyOpenCanonicalServiceLinks() throws {
        let base = try XCTUnwrap(connection.validatedURL), message = EventMessage(event: event, base: base)
        XCTAssertEqual(EventMessage(text: message.text, base: base), message)
        let prefix = "Sky watchers\n"
        for value in ["http://pocket.example/events/\(transferID)", "https://evil.example/events/\(transferID)",
            "https://pocket.example.evil/events/\(transferID)", "https://user@pocket.example/events/\(transferID)",
            "https://pocket.example:444/events/\(transferID)", "https://pocket.example/events/\(transferID)?x=1",
            "https://pocket.example/events/\(transferID)#x", "https://pocket.example/events/\(transferID)/extra",
            "https://pocket.example/events/nope", "https://pocket.example/discoveries/\(transferID)",
            "https://pocket.example/events/%33\(transferID.dropFirst())"] {
            XCTAssertNil(EventMessage(text: prefix + value, base: base), value)
        }
        XCTAssertNil(EventMessage(text: "\n" + message.url.absoluteString, base: base))
        XCTAssertNil(EventMessage(text: message.text + "\n", base: base))
        var multiline = event; multiline.title = "Sky\nwatchers"
        XCTAssertNotNil(EventMessage(text: EventMessage(event: multiline, base: base).text, base: base))
    }
    func testRecentActivityUsesDiscoveryOrVersionTimeAndExcludesPrivateContent() {
        var gift = card
        XCTAssertEqual(FriendActivity(card: gift).kind, .gift)
        XCTAssertEqual(FriendActivity(card: gift).date, Date(timeIntervalSince1970: 2))
        gift.updatedAt = 99999
        XCTAssertEqual(FriendActivity(card: gift).date, Date(timeIntervalSince1970: 2))
        gift.origin?.kind = "exchange"; XCTAssertEqual(FriendActivity(card: gift).kind, .exchange)
        gift.origin = nil; XCTAssertEqual(FriendActivity(card: gift).kind, .discovery); XCTAssertEqual(FriendActivity(card: gift).label, L10n.text("A new card"))
        var next = gift.versions[0]; next.version = 2; next.awardedAt = 5000; next.explorationID = transferID
        gift.versions.append(next)
        XCTAssertEqual(FriendActivity(card: gift).kind, .growth)
        XCTAssertFalse(FriendActivity(card: gift).label.isEmpty)
        var privateCard = gift; privateCard.versions[1].audience = "demo"
        var empty = gift; empty.versions = []
        XCTAssertEqual(FriendActivity.recent([card, privateCard, empty, gift]).map(\.date), [Date(timeIntervalSince1970: 5), Date(timeIntervalSince1970: 2)])
        var sameDate = card; sameDate.id = requestID
        XCTAssertEqual(FriendActivity.recent([sameDate, card]).map(\.id), [id, requestID])
        for item in [card, sameDate, gift] { XCTAssertFalse(FriendActivity(card: item).label.isEmpty) }
    }
    func testEventShareRetryIsDurableAndPreservesUnsentConversation() async throws {
        try store.social.saveDraft("My unfinished thought", friendID: id, connection: connection)
        var requestIDs: [String] = []
        DiscoveryHTTPProtocol.respond = { request in
            let draft = try JSONDecoder().decode(MessageDraft.self, from: self.body(request))
            requestIDs.append(draft.id)
            throw URLError(.notConnectedToInternet)
        }
        await fails { try await self.store.social.shareEvent(self.event, friendID: self.id, connection: self.connection) }
        let restored = try SocialStore(file: folder.appendingPathComponent("social.json"), client: client)
        DiscoveryHTTPProtocol.respond = { request in
            let draft = try JSONDecoder().decode(MessageDraft.self, from: self.body(request))
            requestIDs.append(draft.id)
            XCTAssertEqual(EventMessage(text: draft.text, base: self.connection.validatedURL!)?.eventID, self.event.id)
            return (200, [:], try JSONEncoder().encode(ExplorerMessage(sequence: 4, requestID: draft.id, text: draft.text, createdAt: 1000, mine: true)))
        }
        try await restored.shareEvent(event, friendID: id, connection: connection)
        XCTAssertEqual(requestIDs.count, 2); XCTAssertEqual(requestIDs[0], requestIDs[1])
        XCTAssertEqual(restored.draft(for: id), "My unfinished thought")
        XCTAssertEqual(restored.messages[id]?.count, 1)
        let reloaded = try SocialStore(file: folder.appendingPathComponent("social.json"), client: client)
        XCTAssertEqual(reloaded.draft(for: id), "My unfinished thought")
        try await reloaded.shareEvent(event, friendID: id, connection: connection)
        XCTAssertNotEqual(requestIDs[1], requestIDs[2], "A new deliberate share must receive a new request ID")
    }
    func testOwnedReceiptsRecoverWithoutFriendshipAndValidatePagination() async throws {
        let card = self.card
        var offsetReads: [Int] = []
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.url!.path, "/api/collectibles")
            let offset = Int(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.queryItems!.first!.value!)!
            offsetReads.append(offset)
            return (200, [:], try JSONEncoder().encode(CollectibleClient.Page(items: offset == 0 ? [card] : [], next: offset == 0 ? 30 : nil)))
        }
        try await store.social.synchronizeReceivedCards(store: store, connection: connection)
        XCTAssertEqual(offsetReads, [0, 30]); XCTAssertEqual(store.state.discoveries.count, 1)
        XCTAssertTrue(store.social.friends.isEmpty)
        try await store.social.synchronizeReceivedCards(store: store, connection: connection)
        XCTAssertEqual(store.state.discoveries.count, 1)
        let reload = try TripStore(fileURL: store.fileURL); XCTAssertEqual(reload.state.discoveries.first?.collectible, card)
        let catalog = CollectibleClient(session: session)
        try respond(CollectibleClient.Page(items: [], next: 0))
        await fails { _ = try await catalog.list(connection: self.connection) }
        await fails { _ = try await catalog.list(offset: -1, connection: self.connection) }
        try respond(CollectibleClient.Page(items: [card, card], next: nil))
        await fails { _ = try await catalog.list(connection: self.connection) }
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await fails { try await self.store.social.synchronizeReceivedCards(store: self.store, connection: self.connection) }
        XCTAssertEqual(store.state.discoveries.count, 1)
    }
    func testExchangeRetryRetainsCardTitleWithoutSendingItToTheAPI() async throws {
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await fails { _ = try await self.store.social.offer(friendID: self.id, offeredID: self.id, wantedID: self.requestID, wantedTitle: "Moon", connection: self.connection) }
        let reopened = try TripStore(fileURL: store.fileURL); reopened.social.client = client
        let pending = try XCTUnwrap(reopened.social.pendingTransfer(for: id)); XCTAssertEqual(pending.wantedTitle, "Moon")
        var reply = transfer("exchange"); reply.requestID = pending.id
        DiscoveryHTTPProtocol.respond = { request in
            let payload = try JSONSerialization.jsonObject(with: self.body(request)) as! [String: Any]
            XCTAssertNil(payload["wantedTitle"]); XCTAssertEqual(payload["wantedID"] as? String, self.requestID)
            return (200, [:], try JSONEncoder().encode(reply))
        }
        _ = try await reopened.social.offer(friendID: id, offeredID: id, wantedID: requestID, connection: connection)
        XCTAssertNil(reopened.social.pendingTransfer(for: id))
    }
}
