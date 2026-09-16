import XCTest

@MainActor final class ProfilePrivacyFlowTests: XCTestCase {
    private let app = XCUIApplication()
    override func setUp() async throws {
        continueAfterFailure = false
        _ = try await URLSession.shared.data(from: URL(string: PitchFixtureServer.base + "/__fixture/family/reset")!)
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = PitchFixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15)); app.buttons["language-continue"].tap()
    }
    private func reach(_ element: XCUIElement) {
        _ = element.waitForExistence(timeout: 2)
        for _ in 0..<15 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }
    func testFriendsAndRemindersRoutesAreUsableWithoutLocalPrivacyOverrides() {
        app.buttons["open-profile"].tap()
        reach(app.buttons["profile-friends"]); app.buttons["profile-friends"].tap()
        XCTAssertTrue(app.buttons["Family settings"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.textFields["friend-code-input"].exists)
        app.tabBars.buttons["Chat"].tap()
        reach(app.buttons["profile-reminders"]); app.buttons["profile-reminders"].tap()
        XCTAssertTrue(app.staticTexts["A little look back"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        reach(app.buttons["open-family-settings"]); app.buttons["open-family-settings"].tap()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.switches["family-mapSharing"].exists)
        XCTAssertFalse(app.switches["family-social"].exists)
        app.buttons["family-done"].tap()
        XCTAssertFalse(app.buttons["signup-google-option"].exists)
        XCTAssertFalse(app.buttons["privacy-save"].exists)
    }

    func testProfileIncludesWebAlignedSettingsAndSocialEntries() {
        app.buttons["open-profile"].tap()
        for identifier in ["open-family-settings", "profile-preferences", "profile-reminders", "profile-privacy", "choose-language", "profile-friends", "profile-location", "profile-parent-controls", "profile-account"] {
            reach(app.buttons[identifier])
        }
        app.buttons["profile-account"].tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 5))
    }
}
