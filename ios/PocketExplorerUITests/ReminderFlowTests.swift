import XCTest

final class ReminderFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let card = "20000000-0000-4000-8000-000000000009"
    private let trip = "10000000-0000-4000-8000-000000000009"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = "http://127.0.0.1:4197"
        let date = Date().timeIntervalSinceReferenceDate - 172800
        let quiz: [String: Any] = ["question": "What scatters sunlight?", "choices": ["Air", "Paint", "The Moon"], "correctIndex": 0, "explanation": "Air scatters the blue part of sunlight."]
        let reply: [String: Any] = ["title": "Blue sky", "answer": "Air scatters blue light.", "invitation": "What colour do you see?", "category": "science", "artworkPrompt": "Blue sky and clouds", "quiz": quiz]
        let journal: [String: Any] = ["version": 1,
            "trips": [["id": trip, "title": "A sky discovery", "startedAt": date, "isExample": false]],
            "discoveries": [["id": card, "tripID": trip, "subject": "discovery", "question": "Why is the sky blue?", "observation": "I saw pale blue.", "explanation": "Air scatters blue light.", "createdAt": date, "ai": reply,
                "explorationID": "60000000-0000-4000-8000-000000000009",
                "artwork": ["id": "70000000-0000-4000-8000-000000000009", "status": "failed", "attempts": 1]]]]
        app.launchEnvironment["POCKET_TEST_JOURNAL"] = String(data: try JSONSerialization.data(withJSONObject: journal), encoding: .utf8)
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15)); app.buttons["language-continue"].tap()
    }

    func testWrongAnswerExplainsTheIdeaAndKeepsTheCardAfterRelaunch() {
        openQuiz()
        app.buttons["quiz-choice-1"].tap(); scrollTo(app.buttons["quiz-check"]); app.buttons["quiz-check"].tap()
        XCTAssertTrue(app.otherElements["quiz-feedback"].exists || app.staticTexts["Your card is yours to keep."].exists)
        XCTAssertTrue(app.staticTexts["Air scatters the blue part of sunlight."].exists)
        capture("quiz-wrong-answer")
        relaunch(); app.tabBars.buttons["Map"].tap(); app.buttons["open-reminders"].tap()
        XCTAssertTrue(app.staticTexts["Nothing to catch up on. Come back after your next discovery."].exists)
        app.buttons["Done"].tap(); app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("Discoveries: 1"))
        XCTAssertTrue(app.buttons["collection-card-\(card)"].exists)
    }

    func testCorrectAnswerOpensTheSavedCardAndFailedArtworkOffersAnExplicitRetry() {
        openQuiz(); app.buttons["quiz-choice-0"].tap(); scrollTo(app.buttons["quiz-check"]); app.buttons["quiz-check"].tap()
        XCTAssertTrue(app.staticTexts["You remembered!"].exists)
        scrollTo(app.buttons["View my card"]); app.buttons["View my card"].tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 5))
        scrollTo(app.buttons["retry-artwork"])
        capture("artwork-retry")
        app.buttons["retry-artwork"].tap()
        let retried = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.buttons["retry-artwork"])
        wait(for: [retried], timeout: 12)
        app.buttons["Location"].tap()
        XCTAssertTrue(app.staticTexts["No location saved"].exists)
        capture("quiz-earned-card")
    }

    private func openQuiz() {
        app.tabBars.buttons["Map"].tap(); app.buttons["open-reminders"].tap()
        let quiz = app.buttons.matching(NSPredicate(format: "label CONTAINS 'What scatters sunlight?'")).firstMatch
        XCTAssertTrue(quiz.waitForExistence(timeout: 5)); quiz.tap()
        XCTAssertTrue(app.buttons["quiz-choice-0"].waitForExistence(timeout: 5))
    }
    private func relaunch() {
        app.terminate(); app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)"]; app.launch()
        XCTAssertTrue(app.buttons["home-ask"].waitForExistence(timeout: 10))
    }
    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<8 where !element.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
