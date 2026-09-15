import XCTest

@MainActor final class CollectibleFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private var base: String { PitchFixtureServer.base }
    override func setUp() async throws {
        continueAfterFailure = false
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/reset")!)
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(button("language-continue").waitForExistence(timeout: 15))
        button("language-continue").tap()
    }
    private func button(_ id: String) -> XCUIElement {
        let matches = app.buttons.matching(identifier: id)
        return matches.allElementsBoundByIndex.last ?? matches.firstMatch
    }
    private func reach(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        for _ in 0..<10 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    private func startPrepared() {
        let question = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-")).firstMatch
        reach(question); question.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 5))
        button("save-discovery").tap()
        reach(button("pending-quiz"))
        XCTAssertFalse(button("reveal-card").exists)
        capture("card-pending-observation")
        button("pending-quiz").tap()
    }
    private func correctAndReveal() {
        reach(button("quiz-choice-0")); button("quiz-choice-0").tap()
        reach(button("quiz-check")); button("quiz-check").tap()
        reach(button("quiz-reveal")); button("quiz-reveal").tap()
        reach(button("reveal-card")); capture("card-correct-reveal"); button("reveal-card").tap()
        XCTAssertTrue(button("discovery-card").waitForExistence(timeout: 10))
    }
    func testWrongAnswerRetryVerifiedCardEvolutionHistoryAndStyles() {
        startPrepared()
        button("quiz-choice-1").tap()
        reach(button("quiz-check")); button("quiz-check").tap()
        reach(button("quiz-retry"))
        XCTAssertFalse(button("quiz-reveal").exists)
        capture("card-wrong-answer-retry")
        button("quiz-retry").tap()
        correctAndReveal()
        reach(button("card-history")); button("card-history").tap()
        XCTAssertTrue(app.staticTexts["Growing knowledge"].waitForExistence(timeout: 5))
        capture("card-immutable-history-v1")
        app.navigationBars.buttons.firstMatch.tap()
        reach(button("evolve-card")); button("evolve-card").tap()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5)); input.tap(); input.typeText("Why does the colour change at sunset?")
        button("ask-button").tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 15))
        button("save-discovery").tap()
        reach(button("pending-quiz")); button("pending-quiz").tap()
        correctAndReveal()
        reach(button("card-history")); button("card-history").tap()
        XCTAssertTrue(app.staticTexts["V2"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["V1"].exists)
        capture("card-evolved-two-versions")
        app.navigationBars.buttons.firstMatch.tap()
        reach(button("card-style")); button("card-style").tap()
        button("Ocean").tap()
        capture("card-ocean-style")
        app.terminate()
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }; app.launch()
        XCTAssertTrue(button("question-history").waitForExistence(timeout: 10)); button("question-history").tap()
        let conversations = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "conversation-"))
        XCTAssertTrue(conversations.firstMatch.waitForExistence(timeout: 5)); XCTAssertEqual(conversations.count, 1)
        conversations.firstMatch.tap()
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history-question-")).count, 2)
        capture("conversation-group-after-relaunch")
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history-question-")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 5))
    }
}
