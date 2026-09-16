import XCTest

@MainActor final class NavigationFlowTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = PitchFixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    func testSharePreviewKeepsGlobalHomeAndReturnsToItsAdventure() {
        app.tabBars.buttons["Map"].tap()
        let trip = app.buttons["trip-10000000-0000-4000-8000-000000000001"]
        XCTAssertTrue(trip.waitForExistence(timeout: 5)); trip.tap()
        let share = app.buttons["share-trip"]
        for _ in 0..<10 where !share.isHittable { app.swipeUp() }
        XCTAssertTrue(share.isHittable); share.tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "share-preview-global-navigation"; screenshot.lifetime = .keepAlways; add(screenshot)
        XCTAssertTrue(app.buttons["navigation-home"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["Friends"].isHittable)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["make-memory"].waitForExistence(timeout: 5))
        for _ in 0..<5 where !share.isHittable { app.swipeUp() }
        share.tap(); app.buttons["navigation-home"].tap()
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 5))
    }

    func testExplorationKeepsGlobalNavigationAndDraftAcrossDetour() {
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 10))
        app.buttons["home-question"].tap()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap(); input.typeText("Why do leaves change colour?")
        app.buttons["hide-exploration-keyboard"].tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        let evidence = XCTAttachment(screenshot: app.screenshot())
        evidence.name = "exploration-global-navigation"; evidence.lifetime = .keepAlways; add(evidence)
        XCTAssertTrue(app.tabBars.buttons["Map"].isHittable, "Exploration must not cover global navigation")
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.buttons["open-collection"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Chat"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertEqual(input.value as? String, "Why do leaves change colour?")
        app.buttons["navigation-home"].tap()
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 5))
        app.buttons["home-question"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertEqual(input.value as? String, "Why do leaves change colour?")
        app.terminate()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 10))
        app.buttons["home-question"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertEqual(input.value as? String, "Why do leaves change colour?")
    }
}
