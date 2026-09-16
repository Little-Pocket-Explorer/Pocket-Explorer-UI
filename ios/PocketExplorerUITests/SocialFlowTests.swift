import XCTest

@MainActor final class SocialFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private var base: String { PitchFixtureServer.base }
    private struct Seed: Decodable { var key: String; var code: String; var cardID: String }
    private struct Page<T: Decodable>: Decodable { var items: [T] }
    private struct Friend: Decodable { var id: String }
    private struct Transfer: Decodable { var id: String; var receivedCardID: String?; var kind: String; var state: String }
    private var seed: Seed!
    override func setUp() async throws {
        continueAfterFailure = false
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/reset")!)
        let (data, _) = try await URLSession.shared.data(from: URL(string: base + "/__fixture/social/seed")!); seed = try JSONDecoder().decode(Seed.self, from: data)
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base; app.launch()
        XCTAssertTrue(button("language-continue").waitForExistence(timeout: 15)); button("language-continue").tap()
    }
    private func button(_ id: String) -> XCUIElement {
        let matches = app.buttons.matching(identifier: id); return matches.allElementsBoundByIndex.last ?? matches.firstMatch
    }
    private func reach(_ element: XCUIElement) {
        _ = element.waitForExistence(timeout: 2)
        for _ in 0..<12 where !element.isHittable { app.swipeUp() }; XCTAssertTrue(element.isHittable)
    }
    private func tap(_ id: String) { let target = button(id); reach(target); target.tap() }
    private func capture(_ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
    }
    private func peer<T: Decodable>(_ path: String, body: [String: Any]? = nil) async throws -> T {
        var request = URLRequest(url: URL(string: base + path)!); request.setValue("Bearer \(seed.key)", forHTTPHeaderField: "Authorization")
        if let body { request.httpMethod = "POST"; request.httpBody = try JSONSerialization.data(withJSONObject: body) }
        let (data, response) = try await URLSession.shared.data(for: request)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200, String(data: data, encoding: .utf8) ?? "")
        return try JSONDecoder().decode(T.self, from: data)
    }
    private func waitForTransfer(_ transferID: String, friendID: String, state: String) async throws {
        let deadline = Date().addingTimeInterval(8)
        var actual: String?
        repeat {
            let page: Page<Transfer> = try await peer("/api/social/friends/\(friendID)/transfers")
            actual = page.items.first { $0.id == transferID }?.state
            if actual == state { break }
            try await Task.sleep(for: .milliseconds(200))
        } while Date() < deadline
        XCTAssertEqual(actual, state)
    }
    private func enableFriends(mapSharing: Bool = false) {
        app.tabBars.buttons["Social"].tap(); tap("friends-family-settings")
        for id in ["family-pin", "family-confirm-pin"] { let input = app.secureTextFields[id]; reach(input); input.tap(); input.typeText("926418") }
        tap("family-create"); XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 15)); tap("family-recovery-saved")
        let social = app.switches["family-social"]; reach(social); social.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        if mapSharing {
            let map = app.switches["family-mapSharing"]; reach(map); map.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }
        tap("family-save"); XCTAssertTrue(app.staticTexts["Family settings saved"].waitForExistence(timeout: 10)); tap("family-done")
    }
    private func section(_ name: String) {
        for _ in 0..<10 where !app.segmentedControls["friend-pages"].buttons[name].isHittable { app.swipeDown() }
        let target = app.segmentedControls["friend-pages"].buttons[name]; reach(target); target.tap()
    }
    func testJackyJourneyContinuesFromAIThroughMapEventProfileAndExchange() async throws {
        enableFriends(mapSharing: true)
        tap("social-add-friend")
        let input = app.textFields["friend-code-input"]; reach(input); input.tap(); input.typeText(seed.code); tap("friend-invite")
        XCTAssertTrue(app.staticTexts["Waiting for your friend"].waitForExistence(timeout: 15))
        let requests: Page<Friend> = try await peer("/api/social/friends"), id = try XCTUnwrap(requests.items.first?.id)
        let _: Friend = try await peer("/api/social/friends/\(id)/actions", body: ["action": "accept"])
        tap("friends-refresh")
        app.tabBars.buttons["Chat"].tap()
        tap("daily-question-blue-sky")
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 10))
        tap("save-discovery"); app.unlockSavedObservation(); tap("reveal-card")
        XCTAssertTrue(app.tabBars.buttons["Map"].isHittable)
        tap("new-card-map"); tap("map-share-location")
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            let allow = app.alerts.buttons.matching(NSPredicate(format: "label CONTAINS %@", "While Using")).firstMatch
            if allow.exists { allow.tap() }
        }
        tap("publish-map-card")
        XCTAssertTrue(app.staticTexts["map-published"].waitForExistence(timeout: 15) || app.otherElements["map-published"].exists)
        let (bytes, response) = try await URLSession.shared.data(from: URL(string: base + "/api/map-discoveries?latitude=-33.87&longitude=151.21")!)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        let result = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? [String: Any])
        let published = try XCTUnwrap(result["items"] as? [[String: Any]])
        XCTAssertTrue(published.contains { $0["title"] as? String == "Blue sky" })
        capture("jacky-card-map-publication")
        tap("map-continue-nearby")
        XCTAssertTrue(app.tabBars.buttons["Map"].isSelected)
        tap("find-events"); tap("nearby-event-77777777-7777-4777-8777-777777777777")
        tap("event-share-friend"); tap("event-recipient-\(id)"); tap("event-share-send")
        XCTAssertTrue(button("conversation-profile").waitForExistence(timeout: 15))
        XCTAssertTrue(app.tabBars.buttons["Social"].isSelected)
        struct Message: Decodable { var text: String }
        let messages: Page<Message> = try await peer("/api/social/friends/\(id)/messages")
        XCTAssertEqual(messages.items.map(\.text), ["Sky watchers\n\(base)/events/77777777-7777-4777-8777-777777777777"])
        capture("jacky-event-shared-in-conversation")
        for _ in 0..<8 where !button("conversation-profile").isHittable { app.swipeDown() }
        tap("conversation-profile")
        tap("friend-activity-\(seed.cardID)")
        XCTAssertTrue(app.staticTexts["Moon neighbour"].waitForExistence(timeout: 10))
        tap("friend-exchange"); tap("gift-send")
        XCTAssertTrue(app.staticTexts["transfer-sent"].waitForExistence(timeout: 15) || app.otherElements["transfer-sent"].exists)
        let offers: Page<Transfer> = try await peer("/api/social/friends/\(id)/transfers")
        let offer = try XCTUnwrap(offers.items.first { $0.kind == "exchange" && $0.state == "pending" })
        let _: Transfer = try await peer("/api/social/transfers/\(offer.id)/actions", body: ["decision": "accept"])
        tap("transfer-open-conversation"); tap("friend-refresh")
        XCTAssertTrue(app.staticTexts["Accepted"].waitForExistence(timeout: 15))
        capture("jacky-exchange-received")
        tap("navigation-home")
        XCTAssertTrue(button("home-question").waitForExistence(timeout: 5))
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(button("event-share-send").exists, "Map keeps its last browsing position after Home")
        tap("navigation-home")
    }
    func testPrivateFriendshipTextChatGiftExchangeAndBlock() async throws {
        enableFriends()
        tap("social-add-friend")
        let input = app.textFields["friend-code-input"]; reach(input); input.tap(); input.typeText(seed.code); tap("friend-invite")
        XCTAssertTrue(app.staticTexts["Waiting for your friend"].waitForExistence(timeout: 15)); capture("friend-private-code-and-outgoing-request")
        let requests: Page<Friend> = try await peer("/api/social/friends"), id = try XCTUnwrap(requests.items.first?.id)
        let _: Friend = try await peer("/api/social/friends/\(id)/actions", body: ["action": "accept"])
        tap("friends-refresh"); tap("friend-open-\(id)"); tap("friend-profile-message")
        let message = app.textFields["friend-message-input"].exists ? app.textFields["friend-message-input"] : app.textViews["friend-message-input"]
        reach(message); message.tap(); message.typeText("I found a green leaf!"); tap("friend-message-send")
        let thread: Page<[String: AnyDecodable]> = try await peer("/api/social/friends/\(id)/messages")
        XCTAssertEqual(thread.items.count, 1)
        let _: [String: AnyDecodable] = try await peer("/api/social/friends/\(id)/messages", body: ["id": UUID().uuidString.lowercased(), "text": "I saw the moon!"])
        tap("friend-refresh"); XCTAssertTrue(app.staticTexts["I saw the moon!"].waitForExistence(timeout: 15)); capture("friend-text-conversation")
        let received: Transfer = try await peer("/api/social/friends/\(id)/transfers", body: ["id": UUID().uuidString.lowercased(), "kind": "gift", "offeredID": seed.cardID])
        XCTAssertEqual(received.state, "accepted")
        section("Gifts"); XCTAssertTrue(app.staticTexts["Moon neighbour"].waitForExistence(timeout: 15)); capture("friend-received-gift")
        tap("friend-give"); tap("gift-send"); XCTAssertTrue(app.staticTexts["transfer-sent"].waitForExistence(timeout: 15) || app.otherElements["transfer-sent"].exists)
        capture("friend-gift-copy-confirmed"); tap("Done")
        let gifts: Page<Transfer> = try await peer("/api/social/friends/\(id)/transfers"); XCTAssertEqual(gifts.items.count, 2)
        section("Cards"); tap("friend-card-\(seed.cardID)"); XCTAssertTrue(app.staticTexts["Moon neighbour"].waitForExistence(timeout: 10)); capture("friend-card-original-artwork")
        tap("friend-exchange"); tap("gift-send"); XCTAssertTrue(app.staticTexts["transfer-sent"].waitForExistence(timeout: 15) || app.otherElements["transfer-sent"].exists)
        tap("Done"); tap("Done")
        let offers: Page<Transfer> = try await peer("/api/social/friends/\(id)/transfers")
        let offer = try XCTUnwrap(offers.items.first { $0.kind == "exchange" && $0.state == "pending" })
        let _: Transfer = try await peer("/api/social/transfers/\(offer.id)/actions", body: ["decision": "accept"])
        section("Gifts"); tap("friend-refresh"); XCTAssertTrue(app.staticTexts["A card exchange"].waitForExistence(timeout: 15)); capture("friend-exchange-accepted-both-copies")
        for _ in 0..<5 where !app.segmentedControls["social-tabs"].exists { app.navigationBars.buttons["BackButton"].tap() }
        let socialTabs = app.segmentedControls["social-tabs"]
        socialTabs.buttons["Messages"].tap()
        XCTAssertTrue(app.staticTexts["I saw the moon!"].waitForExistence(timeout: 5))
        capture("social-message-overview")
        socialTabs.buttons["Shared with Me"].tap()
        let sharedCard = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Moon neighbour")).firstMatch
        XCTAssertTrue(sharedCard.waitForExistence(timeout: 5)); capture("social-shared-card-overview")
        sharedCard.tap(); XCTAssertTrue(button("friend-exchange").waitForExistence(timeout: 5))
        app.navigationBars.buttons["BackButton"].tap()
        socialTabs.buttons["Friends"].tap(); tap("friend-open-\(id)"); tap("friend-profile-message")
        tap("Friendship options"); tap("Report a concern"); tap("Privacy")
        XCTAssertTrue(app.staticTexts["social-reported"].waitForExistence(timeout: 15))
        tap("Friendship options"); tap("Block friend")
        XCTAssertTrue(app.staticTexts["This friendship is unavailable. Ask a grown-up to check your settings."].waitForExistence(timeout: 10)); capture("friend-blocked-access-revoked")
    }
    func testIncomingFriendshipExchangeDecisionsAndOfflineMessageRetry() async throws {
        enableFriends()
        let code = app.staticTexts["friend-code"]; reach(code)
        let request: Friend = try await peer("/api/social/friends", body: ["code": code.label]), id = request.id
        tap("friends-refresh"); tap("friend-accept-\(id)"); tap("friend-open-\(id)"); tap("friend-profile-message")
        let _: Transfer = try await peer("/api/social/friends/\(id)/transfers", body: ["id": UUID().uuidString.lowercased(), "kind": "gift", "offeredID": seed.cardID])
        section("Gifts"); tap("friend-refresh"); XCTAssertTrue(app.staticTexts["Moon neighbour"].waitForExistence(timeout: 10))
        struct Card: Decodable { var id: String }
        let cards: Page<Card> = try await peer("/api/social/friends/\(id)/collection"), wanted = try XCTUnwrap(cards.items.first?.id)
        let offer: Transfer = try await peer("/api/social/friends/\(id)/transfers", body: ["id": UUID().uuidString.lowercased(), "kind": "exchange", "offeredID": seed.cardID, "wantedID": wanted])
        tap("friend-refresh"); tap("exchange-accept")
        try await waitForTransfer(offer.id, friendID: id, state: "accepted")
        let completed = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: button("exchange-accept"))
        await fulfillment(of: [completed], timeout: 8)
        capture("incoming-exchange-explicitly-accepted")
        let second: Transfer = try await peer("/api/social/friends/\(id)/transfers", body: ["id": UUID().uuidString.lowercased(), "kind": "exchange", "offeredID": seed.cardID, "wantedID": wanted])
        tap("friend-refresh"); tap("Decline exchange")
        try await waitForTransfer(second.id, friendID: id, state: "declined")
        section("Messages")
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/offline")!)
        let message = app.textFields["friend-message-input"].exists ? app.textFields["friend-message-input"] : app.textViews["friend-message-input"]
        reach(message); message.tap(); message.typeText("My discovery is saved while offline."); tap("friend-message-send")
        XCTAssertTrue(app.staticTexts["social-error"].waitForExistence(timeout: 15)); capture("message-offline-draft-kept")
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/online")!)
        tap("friend-message-send")
        let delivered: Page<[String: AnyDecodable]> = try await peer("/api/social/friends/\(id)/messages")
        XCTAssertEqual(delivered.items.count, 1)
        let _: Friend = try await peer("/api/social/friends/\(id)/actions", body: ["action": "remove"])
        tap("friend-refresh")
        XCTAssertTrue(app.staticTexts["This friendship is unavailable. Ask a grown-up to check your settings."].waitForExistence(timeout: 10))
    }
}

private struct AnyDecodable: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { return }
        if (try? container.decode(String.self)) != nil || (try? container.decode(Double.self)) != nil || (try? container.decode(Bool.self)) != nil { return }
        _ = try container.decode([String: AnyDecodable].self)
    }
}
