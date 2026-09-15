import XCTest

final class SavedQuestionFlowTests: XCTestCase {
    private let app = XCUIApplication()

    func testSavedAnswerKeepsItsObservationAndOpensTheExistingCardDirectly() {
        continueAfterFailure = true
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = FixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.buttons["home-question"].tap()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        input.tap(); input.typeText("Why is the sky blue?"); app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 10))
        let observation = app.textViews["observation-input"].exists ? app.textViews["observation-input"] : app.textFields["observation-input"]
        scrollTo(observation)
        observation.tap(); observation.typeText("The sky is lighter near the clouds.")
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8), "A new card should still receive its first reveal.")
        app.buttons["reveal-card"].tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 8))
        app.buttons["exploration-close"].tap()
        app.buttons["question-history"].tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Blue sky'")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 8))
        XCTAssertEqual(app.buttons["save-discovery"].label, "View my card")
        capture("saved-answer-reopened")
        XCTAssertFalse(app.textFields["observation-input"].exists || app.textViews["observation-input"].exists,
                       "Already saved cards must not offer a draft editor whose input keepQuestion discards.")
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 5), "Viewing an existing card must open its details directly.")
        capture("existing-card-opened")
        if app.buttons["reveal-card"].exists { app.buttons["reveal-card"].tap() }
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 8))
        app.buttons["discovery-card"].tap()
        XCTAssertEqual(app.staticTexts["card-observation"].label, "The sky is lighter near the clouds.")
        capture("saved-observation-preserved")
    }

    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<10 {
            if element.exists && element.frame.minY >= app.navigationBars.firstMatch.frame.maxY && element.frame.maxY < app.buttons["save-discovery"].frame.minY { break }
            app.swipeUp(velocity: .slow)
        }
        XCTAssertTrue(element.isHittable)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
