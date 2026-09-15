import XCTest
@testable import PocketExplorer

@MainActor final class CollectibleTests: XCTestCase {
    var directory: URL!
    var session: URLSession!
    var store: TripStore!
    let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Look away from the sun.", category: "science", artworkPrompt: "Blue sky", quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "The moon"], correctIndex: 0, explanation: "Air scatters blue light."))
    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [DiscoveryHTTPProtocol.self]
        session = URLSession(configuration: config)
    }
    override func tearDown() async throws {
        session.invalidateAndCancel(); DiscoveryHTTPProtocol.respond = nil
        try? FileManager.default.removeItem(at: directory)
    }
    func discovery(question: String = "Why is the sky blue?", parent: UUID? = nil, evolve: String? = nil, advances: Bool? = nil) throws -> Discovery {
        let record = try store.beginQuestion(question, age: 7, photo: nil, parentID: parent, evolveFrom: evolve)
        var answer = reply; answer.advancesCard = advances
        try store.saveAnswer(answer, for: record.id)
        return try store.keepQuestion(record.id)
    }
    func version(_ discovery: Discovery, number: Int = 1) -> KnowledgeVersion {
        KnowledgeVersion(version: number, explorationID: discovery.explorationID!.uuidString.lowercased(), question: discovery.question, language: discovery.language!, reply: discovery.ai!, awardedAt: 1_800_000_000_000, artworkID: nil, audience: "public")
    }
    func card(_ discovery: Discovery) -> KnowledgeCard {
        KnowledgeCard(id: discovery.collectionID, style: .forest, createdAt: 1_800_000_000_000, updatedAt: 1_800_000_000_000, tier: .common, versions: [version(discovery)])
    }
    func receipt(_ discovery: Discovery, correct: Bool = true) -> RecallReceipt {
        RecallReceipt(correct: correct, explanation: reply.quiz.explanation, correctIndex: 0, collectible: correct ? card(discovery) : nil)
    }
    func respond<T: Encodable>(_ value: T, status: Int = 200) throws {
        let bytes = try JSONEncoder().encode(value)
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            return (status, [:], bytes)
        }
    }
    func testWrongAndCorrectOutboxPersistenceLegacyCompatibilityAndShareFiltering() throws {
        let found = try discovery(), trip = store.state.trips[0]
        XCTAssertFalse(found.isUnlocked); XCTAssertFalse(found.isVerified); XCTAssertEqual(found.cardVersion, 1)
        XCTAssertTrue(PublicStory.make(trip: trip, discoveries: [found]).cards.isEmpty)
        let attemptID = UUID()
        try store.answerQuiz(discoveryID: found.id, choice: 1, attemptID: attemptID)
        try store.answerQuiz(discoveryID: found.id, choice: 1, attemptID: attemptID)
        XCTAssertThrowsError(try store.answerQuiz(discoveryID: found.id, choice: 2, attemptID: attemptID))
        XCTAssertEqual(store.state.recallAttempts?.count, 1); XCTAssertNil(store.state.discoveries[0].quizAnsweredAt)
        try store.answerQuiz(discoveryID: found.id, choice: 0)
        try store.answerQuiz(discoveryID: found.id, choice: 0)
        let restored = try TripStore(fileURL: store.fileURL)
        XCTAssertEqual(restored.state.recallAttempts?.count, 2); XCTAssertTrue(restored.state.discoveries[0].isUnlocked)
        XCTAssertFalse(restored.state.discoveries[0].isVerified)
        XCTAssertEqual(PublicStory.make(trip: trip, discoveries: restored.state.discoveries).cards.count, 1)
        var legacy = found; legacy.unlockRequired = nil
        XCTAssertTrue(legacy.isUnlocked); XCTAssertTrue(legacy.isVerified)
        let old = try TripStore(fileURL: directory.appendingPathComponent("old.json"), initial: JournalState(trips: [trip], discoveries: [legacy]))
        try old.answerQuiz(discoveryID: legacy.id, choice: 1)
        XCTAssertTrue(old.state.discoveries[0].isUnlocked); XCTAssertNotNil(old.state.discoveries[0].quizAnsweredAt); XCTAssertNil(old.state.recallAttempts)
    }
    func testVerifiedReceiptAndStyleAreReadBackAndUnrelatedVersionsAreRejected() throws {
        let found = try discovery()
        try store.answerQuiz(discoveryID: found.id, choice: 0)
        let attempt = try XCTUnwrap(store.state.recallAttempts?.first)
        var invalid = receipt(found); invalid.correctIndex = 1
        XCTAssertThrowsError(try store.applyRecall(invalid, attemptID: attempt.id))
        invalid = receipt(found); invalid.collectible?.id = UUID().uuidString
        XCTAssertThrowsError(try store.applyRecall(invalid, attemptID: attempt.id))
        invalid = receipt(found); invalid.collectible = nil
        XCTAssertThrowsError(try store.applyRecall(invalid, attemptID: attempt.id))
        try store.applyRecall(receipt(found), attemptID: attempt.id)
        try store.applyRecall(receipt(found), attemptID: attempt.id)
        XCTAssertTrue(store.state.recallAttempts!.isEmpty)
        var updated = card(found); updated.style = .ocean
        try store.saveCardStyle(updated)
        let restored = try TripStore(fileURL: store.fileURL)
        XCTAssertTrue(restored.state.discoveries[0].isVerified); XCTAssertEqual(restored.state.discoveries[0].collectible?.style, .ocean)
        updated.id = UUID().uuidString; XCTAssertThrowsError(try store.saveCardStyle(updated))
        XCTAssertFalse(CollectibleError.pending.localizedDescription.isEmpty)
        for style in CardStyle.allCases { XCTAssertEqual(style.id, style.rawValue); XCTAssertFalse(style.title.isEmpty) }
        for tier in [CardTier.fieldFind, .common, .rare, .epic] { XCTAssertFalse(tier.title.isEmpty) }
    }
    func testFollowupsKeepConversationAndOldCardsWhileNewUnderstandingEvolves() throws {
        let first = try discovery()
        try store.answerQuiz(discoveryID: first.id, choice: 0)
        try store.applyRecall(receipt(first), attemptID: store.state.recallAttempts![0].id)
        let next = try discovery(question: "Why is sunset red?", parent: first.explorationID, evolve: first.collectionID, advances: true)
        XCTAssertEqual(store.questions.first?.conversationID, first.explorationID); XCTAssertEqual(next.collectionID, first.collectionID)
        XCTAssertTrue(store.state.discoveries[0].isUnlocked); XCTAssertFalse(next.isUnlocked)
        try store.answerQuiz(discoveryID: next.id, choice: 0)
        var evolved = card(first); evolved.versions.append(version(next, number: 2)); evolved.tier = .rare
        try store.applyRecall(RecallReceipt(correct: true, explanation: reply.quiz.explanation, correctIndex: 0, collectible: evolved), attemptID: store.state.recallAttempts![0].id)
        XCTAssertEqual(store.state.discoveries.map(\.cardVersion), [1, 2]); XCTAssertEqual(store.state.discoveries.map(\.tier), [.rare, .rare])
        XCTAssertEqual(store.state.discoveries[0].question, first.question)
        let unrelated = try discovery(question: "Tell me something unrelated", parent: next.explorationID, evolve: first.collectionID, advances: false)
        try store.answerQuiz(discoveryID: unrelated.id, choice: 0)
        XCTAssertFalse(store.state.discoveries.last!.isUnlocked)
        XCTAssertEqual(store.questions.first?.conversationID, first.explorationID)
        XCTAssertThrowsError(try store.beginQuestion("Missing parent", age: 7, photo: nil, parentID: UUID()))
    }
    func testCoordinatorRetriesOfflineAndAppliesOnlyVerifiedResults() async throws {
        let found = try discovery(); try store.answerQuiz(discoveryID: found.id, choice: 1)
        let coordinator = store.recall; coordinator.client.session = session
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await coordinator.synchronize(store: store, connection: connection)
        XCTAssertNotNil(coordinator.error); XCTAssertEqual(store.state.recallAttempts?.count, 1)
        try respond(receipt(found, correct: false)); await coordinator.synchronize(store: store, connection: connection)
        XCTAssertTrue(store.state.recallAttempts!.isEmpty); XCTAssertFalse(store.state.discoveries[0].isUnlocked)
        try store.answerQuiz(discoveryID: found.id, choice: 0)
        try respond(receipt(found)); await coordinator.synchronize(store: store, connection: connection)
        XCTAssertTrue(store.state.discoveries[0].isVerified); XCTAssertFalse(coordinator.busy); XCTAssertNil(coordinator.error)
        let second = try discovery(question: "Another discovery"); try store.answerQuiz(discoveryID: second.id, choice: 0)
        try respond(["error": "card_needs_new_discovery"], status: 409)
        await coordinator.synchronize(store: store, connection: connection)
        XCTAssertEqual(store.state.recallAttempts?.first?.failure, CollectibleError.newDiscovery.rawValue)
        XCTAssertNotNil(coordinator.error)
        XCTAssertFalse(store.state.discoveries.last!.isUnlocked)
        XCTAssertNil(store.state.discoveries.last!.quizAnsweredAt)
        XCTAssertTrue(store.state.discoveries.first!.isVerified)
        try store.failRecall(UUID(), code: "unused")
        await coordinator.synchronize(store: store, connection: connection)
        XCTAssertEqual(store.state.recallAttempts?.count, 1)
    }
    func testConversationGroupingAndConcurrentRecallCallers() async throws {
        let first = try discovery()
        let next = try discovery(question: "Why does the colour change?", parent: first.explorationID)
        _ = try discovery(question: "What is a fossil?")
        let groups = ExplorationConversation.groups(store.questions)
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups.last?.records.map(\.id), [first.explorationID!, next.explorationID!])
        XCTAssertEqual(groups.last?.title, first.title)
        XCTAssertTrue(ExplorationConversation.groups([]).isEmpty)
        var unfinished = store.questions[0]; unfinished.reply = nil
        XCTAssertEqual(ExplorationConversation.groups([unfinished])[0].title, unfinished.question)
        try store.answerQuiz(discoveryID: first.id, choice: 0)
        let coordinator = store.recall; coordinator.client.session = session
        try respond(receipt(first))
        async let one: Void = coordinator.synchronize(store: store, connection: connection)
        async let two: Void = coordinator.synchronize(store: store, connection: connection)
        _ = await (one, two)
        XCTAssertTrue(store.state.discoveries[0].isVerified)
        XCTAssertTrue(store.state.recallAttempts!.isEmpty)
    }
    func testClientResponseValidationErrorsReadbackAndStyles() async throws {
        let found = try discovery(), client = CollectibleClient(session: session)
        let attempt = RecallAttempt(discoveryID: found.id, explorationID: found.explorationID!, choice: 0, createdAt: .now)
        var value = receipt(found); value.correct = false
        try respond(value)
        do { _ = try await client.recall(attempt, connection: connection); XCTFail("Incorrect receipt") } catch { XCTAssertEqual(error as? CollectibleError, .invalidResponse) }
        struct Envelope: Encodable { var collectible: KnowledgeCard }
        try respond(Envelope(collectible: card(found)))
        let fetched = try await client.read(found.collectionID, connection: connection)
        let styled = try await client.style(.forest, id: found.collectionID, connection: connection)
        XCTAssertEqual(fetched, card(found))
        XCTAssertEqual(styled, card(found))
        do { _ = try await client.style(.ocean, id: found.collectionID, connection: connection); XCTFail("Incorrect style") } catch {}
        for code in ["card_version_limit", "quiz_request_conflict", "card_not_unlocked", "family_feature_disabled", "unknown"] {
            try respond(["error": code], status: 409)
            do { _ = try await client.recall(attempt, connection: connection); XCTFail("Must fail") } catch { XCTAssertFalse(error.localizedDescription.isEmpty) }
        }
        for id in ["bad", "../family"] {
            do { _ = try await client.read(id, connection: connection); XCTFail("Invalid ID") } catch {}
            do { _ = try await client.style(.forest, id: id, connection: connection); XCTFail("Invalid ID") } catch {}
        }
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data("bad".utf8)) }
        do { _ = try await client.recall(attempt, connection: connection); XCTFail("Invalid body") } catch {}
        do { _ = try await client.read(found.collectionID, connection: ShareConnection(baseURL: "http://bad.example", ownerKey: connection.ownerKey)); XCTFail("Invalid origin") } catch {}
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.cancelled) }
        do { _ = try await client.recall(attempt, connection: connection); XCTFail("Cancelled") } catch { XCTAssertTrue(error is CancellationError) }
        var badCard = card(found); badCard.versions[0].audience = "unknown"; XCTAssertFalse(badCard.isValid)
        badCard = card(found); badCard.versions[0].artworkID = "bad"; XCTAssertFalse(badCard.isValid)
    }
}

@MainActor extension TripStore {
    func verifyTestCard(_ discovery: Discovery) throws -> Discovery {
        let reply = try XCTUnwrap(discovery.ai), exploration = try XCTUnwrap(discovery.explorationID)
        let attempt = UUID(), now = Date()
        try answerQuiz(discoveryID: discovery.id, choice: reply.quiz.correctIndex, now: now, attemptID: attempt)
        let version = KnowledgeVersion(version: 1, explorationID: exploration.uuidString.lowercased(), question: discovery.question,
                                       language: discovery.language ?? "en", reply: reply, awardedAt: now.timeIntervalSince1970 * 1000,
                                       artworkID: discovery.artwork?.id, audience: "public")
        let card = KnowledgeCard(id: discovery.collectionID, style: .forest, createdAt: version.awardedAt, updatedAt: version.awardedAt, tier: .common, versions: [version])
        try applyRecall(RecallReceipt(correct: true, explanation: reply.quiz.explanation, correctIndex: reply.quiz.correctIndex, collectible: card), attemptID: attempt)
        return try XCTUnwrap(state.discoveries.first { $0.id == discovery.id })
    }
}
