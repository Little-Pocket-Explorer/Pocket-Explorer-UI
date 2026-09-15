import XCTest

final class AnswerPresentationFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let base = FixtureServer.base

    override func setUpWithError() throws {
        continueAfterFailure = false
        try control("reset")
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    override func tearDownWithError() throws {
        app.terminate()
        try control("reset")
    }

    func testPreparedQuestionStartsNarrationAndOffersProgressiveText() throws {
        let question = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-")).firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 10))
        question.tap()
        let listen = app.buttons["listen-answer"]
        XCTAssertTrue(listen.waitForExistence(timeout: 3))
        XCTAssertEqual(listen.label, "Stop reply", "A newly opened prepared question should narrate like a live answer.")
        let showAll = app.buttons["show-full-answer"]
        XCTAssertTrue(showAll.exists, "Prepared answers should use the same text reveal as live answers.")
        showAll.tap()
        XCTAssertFalse(showAll.exists)
        XCTAssertEqual(listen.label, "Stop reply", "Showing the full text must not interrupt narration.")
        capture("prepared-answer-full-text-with-narration")
        listen.tap()
        XCTAssertEqual(listen.label, "Listen")
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["pending-quiz"].waitForExistence(timeout: 8))
    }

    func testCachedOfflinePlaybackStopsInBackgroundAndHistoryDoesNotAutoplay() throws {
        let question = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-")).firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 10))
        question.tap()
        XCTAssertTrue(app.buttons["listen-answer"].waitForExistence(timeout: 3))
        app.buttons["listen-answer"].tap()
        app.buttons["exploration-close"].tap()
        try control("offline")
        question.tap()
        let listen = app.buttons["listen-answer"]
        XCTAssertTrue(listen.waitForExistence(timeout: 3))
        XCTAssertEqual(listen.label, "Stop reply")
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(listen.waitForExistence(timeout: 5))
        XCTAssertEqual(listen.label, "Listen")
        XCTAssertFalse(app.buttons["show-full-answer"].exists)
        capture("cached-answer-after-background")
        app.buttons["exploration-close"].tap()
        app.buttons["question-history"].tap()
        app.openLatestSavedQuestion()
        XCTAssertTrue(listen.waitForExistence(timeout: 5))
        XCTAssertEqual(listen.label, "Listen")
        XCTAssertFalse(app.buttons["show-full-answer"].exists)
        listen.tap()
        XCTAssertEqual(listen.label, "Stop reply")
    }

    private func control(_ action: String) throws {
        let done = expectation(description: "Fixture control")
        var failure: Error?
        URLSession.shared.dataTask(with: URL(string: base + "/__fixture/daily/" + action)!) { _, response, error in
            failure = error
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            done.fulfill()
        }.resume()
        wait(for: [done], timeout: 5)
        if let failure { throw failure }
    }

    private func capture(_ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
}
