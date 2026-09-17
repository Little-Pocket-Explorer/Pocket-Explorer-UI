import XCTest
import UserNotifications
@testable import PocketExplorer

@MainActor final class RecallNotificationTests: XCTestCase {
    private var directory: URL!
    private var store: TripStore!
    private var preferences: UserDefaults!
    private var suite: String!
    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        suite = UUID().uuidString; preferences = UserDefaults(suiteName: suite)!
    }
    override func tearDown() async throws { preferences.removePersistentDomain(forName: suite); try? FileManager.default.removeItem(at: directory) }
    private func discovery(at date: Date) throws -> Discovery {
        let record = try store.beginQuestion("Why blue?", age: 7, photo: nil, now: date)
        let reply = AIReply(title: "Blue sky", answer: "Air scatters light.", invitation: "Look safely.", category: "science", artworkPrompt: "Sky",
            quiz: .init(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air scatters light."))
        try store.saveAnswer(reply, for: record.id)
        return try store.keepQuestion(record.id, now: date)
    }
    func testSystemClientStoresLocalizedPayloadAndRemovesItsRequest() async throws {
        let client = SystemRecallNotificationClient()
        guard await client.allowed() else {
            throw XCTSkip("Run the notification opt-in UI flow first on this isolated simulator.")
        }
        let date = try XCTUnwrap(Calendar.current.nextDate(after: .now, matching: DateComponents(hour: 17, minute: 0), matchingPolicy: .nextTime))
        let notice = RecallNotice(discoveryID: UUID(), date: date, language: .chinese)
        defer { client.remove([notice.id]) }
        try await client.add(notice)
        let actual = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let request = try XCTUnwrap(actual.first { $0.identifier == notice.id })
        XCTAssertEqual(request.content.title, L10n.text("A little look back", language: .chinese))
        XCTAssertEqual(request.content.body, L10n.text("A discovery has a little question for you. Ready to look back?", language: .chinese))
        XCTAssertEqual(request.content.userInfo["discoveryID"] as? String, notice.discoveryID.uuidString)
        XCTAssertNotNil(request.content.sound)
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertFalse(trigger.repeats)
        XCTAssertEqual(try XCTUnwrap(trigger.nextTriggerDate()).timeIntervalSince(date), 0, accuracy: 1)
        let identifiers = await client.pending()
        XCTAssertTrue(identifiers.contains(notice.id))
        client.remove([notice.id])
        let remaining = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertFalse(remaining.contains { $0.identifier == notice.id })
    }

    func testReviewPreservesAwardAndWaitsOneWeekAfterEveryAttempt() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000), card = try discovery(at: start)
        try store.answerQuiz(discoveryID: card.id, choice: 0, now: start)
        let awarded = store.state.discoveries[0], outbox = store.state.recallAttempts
        let later = start.addingTimeInterval(8 * 86400)
        XCTAssertTrue(ReminderPolicy.isEligible(awarded, now: later))
        try store.answerQuiz(discoveryID: card.id, choice: 1, now: later)
        let reviewed = store.state.discoveries[0]
        XCTAssertEqual(reviewed.unlockedAt, awarded.unlockedAt)
        XCTAssertEqual(reviewed.quizAnsweredAt, awarded.quizAnsweredAt)
        XCTAssertEqual(reviewed.recallReviewedAt, later)
        XCTAssertEqual(store.state.recallAttempts, outbox)
        XCTAssertFalse(ReminderPolicy.isEligible(reviewed, now: later.addingTimeInterval(6 * 86400)))
        XCTAssertTrue(ReminderPolicy.isEligible(reviewed, now: later.addingTimeInterval(7 * 86400)))
        XCTAssertEqual(try TripStore(fileURL: store.fileURL).state.discoveries[0].recallReviewedAt, later)
    }
    func testPracticeCandidateOffersNewestFreshCardWithoutChangingDueState() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var older = try discovery(at: now.addingTimeInterval(-120)); older.unlockRequired = false
        var newer = try discovery(at: now.addingTimeInterval(-60)); newer.unlockRequired = false
        XCTAssertFalse(ReminderPolicy.isEligible(newer, now: now))
        XCTAssertEqual(ReminderPolicy.practiceCandidate([older, newer], now: now)?.id, newer.id)
        var reviewed = newer; reviewed.recallReviewedAt = now
        XCTAssertEqual(ReminderPolicy.practiceCandidate([reviewed], now: now), nil)
        XCTAssertNil(ReminderPolicy.practiceCandidate([older], now: older.createdAt.addingTimeInterval(86400)))
    }
    func testPlansOnlyAfternoonsWithDailyCapAndSevenDayHorizon() throws {
        let now = ISO8601DateFormatter().date(from: "2026-09-16T08:00:00Z")!
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let cards = try (0..<5).map { _ in try discovery(at: now.addingTimeInterval(-2 * 86400)) }
        let plan = RecallNotice.plan(cards, now: now, calendar: calendar)
        XCTAssertEqual(plan.count, 3)
        XCTAssertEqual(Set(plan.map { calendar.startOfDay(for: $0.date) }).count, 3)
        XCTAssertTrue(plan.allSatisfy { calendar.component(.hour, from: $0.date) == 17 && $0.date > now })
        XCTAssertTrue(plan.allSatisfy { $0.id.hasPrefix(RecallNotice.prefix) })
        var later = cards[0]; later.recallReviewedAt = now.addingTimeInterval(2 * 86400)
        XCTAssertTrue(RecallNotice.plan([later], now: now, calendar: calendar).isEmpty)
        var noQuiz = cards[0]; noQuiz.ai = nil
        XCTAssertTrue(RecallNotice.plan([noQuiz], now: now, calendar: calendar).isEmpty)
        var demo = cards[0]
        demo.collectible = KnowledgeCard(id: UUID().uuidString, style: .forest, createdAt: 1, updatedAt: 1, tier: .common,
            versions: [.init(version: 1, explorationID: UUID().uuidString, question: "Why?", language: "en", reply: cards[0].ai!, awardedAt: 1, audience: "demo")])
        XCTAssertTrue(RecallNotice.plan([demo], now: now, calendar: calendar).isEmpty)
    }
    func testCancelledPermissionRequestCannotReenableOrPublishLate() async throws {
        let client = NoticeClient(), notifications = RecallNotifications(client: client, preferences: preferences)
        client.suspend = true
        let notice = RecallNotice(discoveryID: UUID(), date: .now.addingTimeInterval(86400), language: .english)
        await notifications.synchronize([notice])
        let first = Task { await notifications.setEnabled(true) }
        for _ in 0..<20 where client.permission == nil { await Task.yield() }
        XCTAssertTrue(notifications.requesting)
        XCTAssertNotNil(client.permission)
        await notifications.setEnabled(true)
        XCTAssertEqual(client.requestCount, 1, "Repeated taps must not open another authorization request")
        await notifications.setEnabled(false)
        XCTAssertFalse(notifications.requesting)
        client.granted = true
        client.permission?.resume(returning: true); client.permission = nil
        await first.value
        XCTAssertFalse(notifications.enabled)
        XCTAssertFalse(preferences.bool(forKey: "recall-notifications"))
        XCTAssertTrue(client.added.isEmpty)
        let second = Task { await notifications.setEnabled(true) }
        for _ in 0..<20 where client.permission == nil { await Task.yield() }
        await notifications.setEnabled(false)
        client.permission?.resume(throwing: URLError(.cancelled)); client.permission = nil
        await second.value
        XCTAssertNil(notifications.error, "An abandoned request must not overwrite the current UI")
    }

    func testOptInDenialDisableAndSchedulingFailureKeepOtherNotifications() async throws {
        let client = NoticeClient(), notifications = RecallNotifications(client: client, preferences: preferences)
        let notice = RecallNotice(discoveryID: UUID(), date: .now.addingTimeInterval(86400), language: .english)
        client.identifiers = ["unrelated", notice.id]
        await notifications.synchronize([notice])
        XCTAssertFalse(notifications.enabled); XCTAssertEqual(client.identifiers, ["unrelated"])
        await notifications.setEnabled(true)
        XCTAssertFalse(notifications.enabled)
        client.granted = true
        await notifications.setEnabled(true)
        XCTAssertTrue(notifications.enabled); XCTAssertTrue(notifications.allowed)
        XCTAssertEqual(client.added.last, notice)
        XCTAssertTrue(preferences.bool(forKey: "recall-notifications"))
        client.fail = true
        await notifications.synchronize([notice])
        XCTAssertNotNil(notifications.error)
        client.fail = false
        await notifications.synchronize([notice])
        XCTAssertNil(notifications.error)
        await notifications.setEnabled(false)
        XCTAssertEqual(client.identifiers, ["unrelated"])
        XCTAssertFalse(preferences.bool(forKey: "recall-notifications"))
        client.fail = true
        await notifications.setEnabled(true)
        XCTAssertNotNil(notifications.error); XCTAssertFalse(notifications.enabled)
        notifications.opening = notice.discoveryID
        XCTAssertEqual(notifications.opening, notice.discoveryID)
        XCTAssertTrue(notifications.open(URL(string: "pocketexplorer://recall/\(notice.discoveryID)")!))
        for value in ["https://recall/\(notice.discoveryID)", "pocketexplorer://recall/bad", "pocketexplorer://recall/\(notice.discoveryID)?x=1", "pocketexplorer://recall/\(notice.discoveryID)/extra"] {
            XCTAssertFalse(notifications.open(URL(string: value)!))
        }
    }
}

@MainActor private final class NoticeClient: RecallNotificationClient {
    var suspend = false
    var requestCount = 0
    var permission: CheckedContinuation<Bool, Error>?
    var granted = false
    var fail = false
    var identifiers: [String] = []
    var added: [RecallNotice] = []
    func allowed() async -> Bool { granted }
    func request() async throws -> Bool {
        requestCount += 1
        if suspend { return try await withCheckedThrowingContinuation { permission = $0 } }
        if fail { throw URLError(.unknown) }
        return granted
    }
    func pending() async -> [String] { identifiers }
    func remove(_ values: [String]) { identifiers.removeAll { values.contains($0) } }
    func add(_ notice: RecallNotice) async throws { if fail { throw URLError(.unknown) }; added.append(notice); identifiers.append(notice.id) }
}
