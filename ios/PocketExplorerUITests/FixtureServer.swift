import XCTest

enum FixtureServer {
    static var base: String {
        ProcessInfo.processInfo.environment["POCKET_AI_FIXTURE_URL"] ?? "http://127.0.0.1:4197"
    }
}

enum PitchFixtureServer {
    static var base: String {
        ProcessInfo.processInfo.environment["POCKET_PITCH_FIXTURE_URL"] ?? "http://127.0.0.1:4236"
    }
}

extension XCUIApplication {
    func unlockSavedObservation(choice: Int = 0) {
        func tapVisible(_ identifier: String) {
            let matches = buttons.matching(identifier: identifier)
            let button = matches.allElementsBoundByIndex.last ?? matches.firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 10), identifier)
            for _ in 0..<12 where !button.isHittable { swipeUp() }
            XCTAssertTrue(button.isHittable, identifier); button.tap()
        }
        XCTAssertFalse(buttons["reveal-card"].exists)
        tapVisible("pending-quiz")
        tapVisible("quiz-choice-\(choice)")
        tapVisible("quiz-check")
        tapVisible("quiz-reveal")
        XCTAssertTrue(buttons["reveal-card"].waitForExistence(timeout: 10))
    }
    func openLatestSavedQuestion() {
        let conversation = buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "conversation-")).firstMatch
        XCTAssertTrue(conversation.waitForExistence(timeout: 5)); conversation.tap()
        let question = buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history-question-")).firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 5)); question.tap()
    }
}
