import XCTest
import Darwin

@MainActor final class RecallRouteFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let card = "20000000-0000-4000-8000-000000000019"
    private let trip = "10000000-0000-4000-8000-000000000019"
    private let exploration = "60000000-0000-4000-8000-000000000019"

    override func setUpWithError() throws {
        continueAfterFailure = false
        let date = Date().addingTimeInterval(-10 * 86400)
        let quiz: [String: Any] = ["question": "What scatters sunlight?", "choices": ["Air", "Paint", "Moon"], "correctIndex": 0, "explanation": "Air scatters the blue part of sunlight."]
        let reply: [String: Any] = ["title": "Blue sky", "answer": "Air scatters blue light.", "invitation": "What colour do you see?", "category": "science", "artworkPrompt": "Blue sky", "quiz": quiz]
        let version: [String: Any] = ["version": 1, "explorationID": exploration, "question": "Why is the sky blue?", "language": "en", "reply": reply, "awardedAt": date.timeIntervalSince1970 * 1000, "audience": "public"]
        let collectible: [String: Any] = ["id": exploration, "style": "forest", "createdAt": date.timeIntervalSince1970 * 1000, "updatedAt": date.timeIntervalSince1970 * 1000, "tier": "common", "versions": [version]]
        let journal: [String: Any] = ["version": 1,
            "trips": [["id": trip, "title": "A sky discovery", "startedAt": date.timeIntervalSinceReferenceDate, "isExample": false]],
            "discoveries": [["id": card, "tripID": trip, "subject": "discovery", "question": "Why is the sky blue?", "observation": "I saw pale blue.", "explanation": "Air scatters blue light.",
                "createdAt": date.timeIntervalSinceReferenceDate, "unlockedAt": date.timeIntervalSinceReferenceDate, "quizAnsweredAt": date.timeIntervalSinceReferenceDate,
                "ai": reply, "explorationID": exploration, "unlockRequired": true, "collectible": collectible]],
            "explorations": [["id": exploration, "question": "Why is the sky blue?", "language": "en", "age": 7, "createdAt": date.timeIntervalSinceReferenceDate, "reply": reply, "cardID": card]]]
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)"]
        app.launchEnvironment["POCKET_TEST_JOURNAL"] = String(data: try JSONSerialization.data(withJSONObject: journal), encoding: .utf8)
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = PitchFixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15)); app.buttons["language-continue"].tap()
    }

    func testReminderSystemOptInAndDisable() {
        app.tabBars.buttons["Map"].tap(); app.buttons["open-reminders"].tap()
        let notifications = app.buttons["recall-notifications"]
        XCTAssertTrue(notifications.waitForExistence(timeout: 5)); notifications.tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.alerts.firstMatch.waitForExistence(timeout: 5) {
            let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            screenshot.name = "system-notification-permission"; screenshot.lifetime = .keepAlways; add(screenshot)
            XCTAssertTrue(springboard.alerts.buttons["Allow"].exists)
            springboard.alerts.buttons["Allow"].tap()
        }
        let enabled = expectation(for: NSPredicate(format: "label == %@", "Turn off reminders"), evaluatedWith: notifications)
        wait(for: [enabled], timeout: 10)
        capture("reminder-system-opt-in-enabled")
        notifications.tap()
        let disabled = expectation(for: NSPredicate(format: "label == %@", "Turn on reminders"), evaluatedWith: notifications)
        wait(for: [disabled], timeout: 5)
    }

    func testOriginalContextRecallAndColdLinksWithOneStepHome() {
        app.tabBars.buttons["Map"].tap(); app.buttons["open-reminders"].tap()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)"]
        app.buttons["recall-open-\(card.uppercased())"].tap()
        XCTAssertTrue(app.staticTexts["recall-original-question"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Chat"].isSelected)
        XCTAssertFalse(app.buttons["listen-answer"].exists, "Recall must not unexpectedly start answer playback")
        app.buttons["Our earlier discovery"].tap()
        XCTAssertTrue(app.staticTexts["Air scatters blue light."].exists)
        reach(app.buttons["quiz-choice-1"]); app.buttons["quiz-choice-1"].tap()
        reach(app.buttons["quiz-check"]); app.buttons["quiz-check"].tap()
        reach(app.buttons["View my card"]); app.buttons["View my card"].tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 5))
        capture("recall-original-card-kept-after-review")
        app.buttons["navigation-home"].tap()
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.staticTexts["Nothing to catch up on. Come back after your next discovery."].exists)
        app.terminate(); app.open(URL(string: "pocketexplorer://recall/\(card)")!)
        XCTAssertTrue(app.staticTexts["recall-original-question"].waitForExistence(timeout: 15))
        capture("recall-cold-open-in-chat")
        app.open(URL(string: "pocketexplorer://recall/00000000-0000-4000-8000-000000000000")!)
        XCTAssertTrue(app.staticTexts["Nothing to catch up on. Come back after your next discovery."].waitForExistence(timeout: 10))
        app.buttons["navigation-home"].tap()
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 5))
    }
    func testWarmSystemLinkPreservesMapContext() throws {
        guard ProcessInfo.processInfo.environment["POCKET_WARM_RECALL_DRIVER"] == "1" else {
            throw XCTSkip("Run with the host simctl link driver to test a real warm system URL delivery.")
        }
        app.tabBars.buttons["Map"].tap(); app.buttons["open-reminders"].tap()
        XCTAssertTrue(app.buttons["recall-open-\(card.uppercased())"].exists)
        print("POCKET_WARM_RECALL_READY \(card)"); fflush(stdout)
        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if system.alerts.firstMatch.waitForExistence(timeout: 10), system.alerts.buttons["Open"].exists {
            system.alerts.buttons["Open"].tap()
        }
        XCTAssertTrue(app.staticTexts["recall-original-question"].waitForExistence(timeout: 40))
        XCTAssertTrue(app.tabBars.buttons["Chat"].isSelected)
        app.buttons["navigation-home"].tap(); app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.buttons["recall-open-\(card.uppercased())"].exists)
        capture("warm-system-recall-preserves-map-context")
    }

    private func reach(_ element: XCUIElement) {
        for _ in 0..<8 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
