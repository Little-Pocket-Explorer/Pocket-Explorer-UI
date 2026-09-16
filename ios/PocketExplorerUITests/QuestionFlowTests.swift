import XCTest

final class QuestionFlowTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = FixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    func testAWaitingQuestionCanBePausedAndResumedWithoutLosingTheQuestion() {
        ask("slow answer about the sky")
        let pause = app.buttons["pause-question"]
        XCTAssertTrue(pause.waitForExistence(timeout: 8))
        XCTAssertTrue(pause.isHittable)
        XCTAssertGreaterThanOrEqual(pause.frame.height, 44)
        capture("question-wait-can-be-paused")
        pause.tap()
        let error = app.staticTexts["exploration-error"]
        XCTAssertTrue(error.waitForExistence(timeout: 5))
        XCTAssertEqual(error.label, "Your question is saved. Check the answer whenever you're ready.")
        XCTAssertEqual(input.value as? String, "slow answer about the sky")
        XCTAssertEqual(app.buttons["retry-answer"].label, "Check answer")
        completePendingAnswer()
        app.buttons["retry-answer"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["save-discovery"].isHittable)
        capture("question-resumed-answer")
    }

    func testSpeechPermissionDenialKeepsTypingAvailable() {
        app.buttons["home-ask"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let deny = springboard.buttons.matching(NSPredicate(format: "label IN %@", ["Don't Allow", "Don’t Allow"])).firstMatch
        if deny.waitForExistence(timeout: 10) { deny.tap() }
        let error = app.staticTexts["exploration-error"]
        XCTAssertTrue(error.waitForExistence(timeout: 10))
        XCTAssertTrue(error.label.contains("Speech recognition is off"))
        input.tap(); input.typeText("Why is the Moon bright?")
        XCTAssertEqual(input.value as? String, "Why is the Moon bright?")
        capture("speech-permission-denied-typing-available")
    }

    private func completePendingAnswer() {
        let complete = expectation(description: "The answer finishes while the child is away")
        var request = URLRequest(url: URL(string: (FixtureServer.base + "/__fixture/answers/complete"))!)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"question\":\"slow answer about the sky\"}".utf8)
        URLSession.shared.dataTask(with: request) { _, response, error in
            XCTAssertNil(error)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            complete.fulfill()
        }.resume()
        wait(for: [complete], timeout: 5)
    }

    func testFailedAnswerUsesAnHonestMessageAndCanRecover() {
        ask("failed answer about the sky")
        let error = app.staticTexts["exploration-error"]
        XCTAssertTrue(error.waitForExistence(timeout: 8))
        XCTAssertEqual(error.label, "Your guide couldn't finish this answer. Your question is saved, and you can ask again.")
        XCTAssertTrue(app.buttons["retry-answer"].isHittable)
        capture("question-failure-recovery")
        app.buttons["retry-answer"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 8))
    }

    func testExhaustedDemoAllowanceDoesNotPromiseAQuickRetry() {
        ask("demo allowance question")
        let error = app.staticTexts["exploration-error"]
        XCTAssertTrue(error.waitForExistence(timeout: 8))
        XCTAssertEqual(error.label, "This demo's AI allowance is used. You can still enjoy your saved discoveries.")
        XCTAssertFalse(app.buttons["retry-answer"].exists)
        XCTAssertEqual(input.value as? String, "demo allowance question")
        capture("question-demo-allowance")
    }

    private var input: XCUIElement {
        app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
    }

    private func ask(_ question: String) {
        app.buttons["home-question"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap(); input.typeText(question)
        app.buttons["ask-button"].tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
