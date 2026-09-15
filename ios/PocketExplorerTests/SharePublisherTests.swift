import XCTest
@testable import PocketExplorer

@MainActor
final class SharePublisherTests: XCTestCase {
    private var story: PublicStory {
        let state = JournalState.examples(language: .english)
        return .make(trip: state.trips[0], discoveries: [state.discoveries[0]])
    }

    private func publisher(_ preferences: UserDefaults) -> SharePublisher {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockShareProtocol.self]
        return SharePublisher(preferences: preferences, client: ShareClient(session: URLSession(configuration: configuration)),
                              connection: { ShareConnection(baseURL: "https://stories.example", ownerKey: String(repeating: "x", count: 40)) })
    }

    private func response(_ letter: String = "a") throws -> Data {
        let token = String(repeating: letter, count: 32)
        return try JSONEncoder().encode(ShareReceipt(token: token, url: URL(string: "https://stories.example/s/\(token)")!))
    }

    func testOverlappingViewsShareOneRequestAndPersistTheFirstSnapshot() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        var count = 0
        let data = try response()
        MockShareProtocol.reply = { _ in count += 1; return (201, data) }
        let original = story
        var changed = original; changed.firstName = "Ari"
        let first = publisher.publish(original, key: "trip")
        XCTAssertNotNil(publisher.pending(for: "trip"))
        let second = publisher.publish(changed, key: "trip")
        XCTAssertEqual(second.story, original)
        let firstResult = try await first.task.value
        let secondResult = try await second.task.value
        XCTAssertEqual(firstResult, secondResult)
        XCTAssertEqual(firstResult.story, original)
        XCTAssertEqual(count, 1)
        XCTAssertNil(publisher.pending(for: "trip"))
        let stored = try XCTUnwrap(preferences.data(forKey: "trip"))
        XCTAssertEqual(try JSONDecoder().decode(PublishedShare.self, from: stored), firstResult)
        let restored = self.publisher(preferences)
        XCTAssertEqual(restored.saved(for: "trip"), firstResult)
        let cached = try await restored.publish(changed, key: "trip").task.value
        XCTAssertEqual(cached, firstResult)
        XCTAssertEqual(count, 1)
    }

    func testLeavingAWaitingViewDoesNotCancelReceiptPersistence() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        let data = try response()
        MockShareProtocol.reply = { _ in (201, data) }
        let request = publisher.publish(story, key: "trip")
        let waiter = Task { try await request.task.value }
        waiter.cancel()
        let saved = try await request.task.value
        XCTAssertEqual(publisher.saved(for: "trip"), saved)
        XCTAssertNil(publisher.pending(for: "trip"))
    }

    func testFailedRequestClearsProgressAndCanBeRetried() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        preferences.set(Data("broken receipt".utf8), forKey: "trip")
        XCTAssertNil(publisher.saved(for: "trip"))
        MockShareProtocol.reply = { _ in (503, Data()) }
        do { _ = try await publisher.publish(story, key: "trip").task.value; XCTFail("Expected failure") }
        catch { XCTAssertTrue(error is ShareError) }
        XCTAssertNil(publisher.pending(for: "trip"))
        XCTAssertNil(publisher.saved(for: "trip"))
        let data = try response()
        MockShareProtocol.reply = { _ in (201, data) }
        let saved = try await publisher.publish(story, key: "trip").task.value
        XCTAssertEqual(publisher.saved(for: "trip"), saved)
    }

    func testDifferentCardsAndARevokedShareCanCreateTheirOwnLinks() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        let firstData = try response()
        MockShareProtocol.reply = { _ in (201, firstData) }
        let first = try await publisher.publish(story, key: "trip").task.value
        let secondData = try response("b")
        MockShareProtocol.reply = { _ in (201, secondData) }
        let second = try await publisher.publish(story, key: "card").task.value
        XCTAssertNotEqual(first.receipt, second.receipt)
        XCTAssertEqual(publisher.saved(for: "trip"), first)
        preferences.removeObject(forKey: "trip")
        XCTAssertNil(publisher.saved(for: "trip"))
        let replacement = try await publisher.publish(story, key: "trip").task.value
        XCTAssertEqual(replacement.receipt, second.receipt)
    }

    func testRevocationSurvivesNavigationAndCoalescesWaitingViews() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        let data = try response()
        MockShareProtocol.reply = { _ in (201, data) }
        let saved = try await publisher.publish(story, key: "trip").task.value
        var deletes = 0
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            deletes += 1
            return (204, Data())
        }
        let first = publisher.revoke(saved, key: "trip")
        XCTAssertNotNil(publisher.pendingRevocation(for: "trip"))
        let second = publisher.revoke(saved, key: "trip")
        let waiter = Task { try await first.value }
        waiter.cancel()
        try await first.value; try await second.value
        XCTAssertEqual(deletes, 1)
        XCTAssertNil(publisher.pendingRevocation(for: "trip"))
        XCTAssertNil(preferences.data(forKey: "trip"))
        XCTAssertNil(self.publisher(preferences).saved(for: "trip"))
    }

    func testFailedRevocationKeepsTheLinkAndAllowsAnExplicitRetry() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        let data = try response()
        MockShareProtocol.reply = { _ in (201, data) }
        let saved = try await publisher.publish(story, key: "trip").task.value
        MockShareProtocol.reply = { _ in (503, Data()) }
        do { try await publisher.revoke(saved, key: "trip").value; XCTFail("Expected failure") }
        catch { XCTAssertTrue(error is ShareError) }
        XCTAssertNil(publisher.pendingRevocation(for: "trip"))
        XCTAssertEqual(publisher.saved(for: "trip"), saved)
        MockShareProtocol.reply = { _ in (204, Data()) }
        try await publisher.revoke(saved, key: "trip").value
        XCTAssertNil(publisher.saved(for: "trip"))
    }
    func testDeferredPreparationPersistsTheResolvedImageAndDoesNotPublishOnPreparationFailure() async throws {
        let suite = UUID().uuidString
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let publisher = publisher(preferences)
        var ready = story; ready.cards[0].artworkID = UUID().uuidString.lowercased()
        let data = try response()
        var calls = 0
        MockShareProtocol.reply = { _ in calls += 1; return (201, data) }
        let failed = publisher.publish(story, key: "trip", prepare: { throw ShareError.unavailable })
        do { _ = try await failed.task.value; XCTFail() } catch {}
        XCTAssertEqual(calls, 0); XCTAssertNil(publisher.saved(for: "trip")); XCTAssertNil(publisher.pending(for: "trip"))
        var preparation: CheckedContinuation<PublicStory, Error>?
        let request = publisher.publish(story, key: "trip", prepare: { try await withCheckedThrowingContinuation { preparation = $0 } })
        while preparation == nil { await Task.yield() }
        let waiter = Task { try await request.task.value }; waiter.cancel()
        let duplicate = publisher.publish(story, key: "trip", prepare: { XCTFail("Must share the pending preparation"); return ready })
        preparation?.resume(returning: ready)
        let result = try await request.task.value
        let same = try await duplicate.task.value
        XCTAssertEqual(result, same); XCTAssertEqual(result.story, ready); XCTAssertEqual(calls, 1)
        XCTAssertEqual(self.publisher(preferences).saved(for: "trip")?.story, ready)
    }

}
