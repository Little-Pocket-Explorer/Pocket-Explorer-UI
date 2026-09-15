import XCTest

final class ProfilePrivacyFlowTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--reset-profile", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 10))
        app.buttons["language-continue"].tap()
    }

    func testProfileOpensPrivateSettingsAndSavesAnExplicitLocationChoice() {
        XCTAssertTrue(app.buttons["open-profile"].waitForExistence(timeout: 10))
        app.buttons["open-profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Age 7"].exists)
        app.buttons["open-privacy"].tap()
        XCTAssertTrue(app.staticTexts["Privacy & controls"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.segmentedControls["privacy-audience"].value as? String, "Only me")
        XCTAssertEqual(app.switches["privacy-location"].value as? String, "0")
        XCTAssertEqual(app.switches["privacy-public-sharing"].value as? String, "0")
        app.switches["privacy-location"].tap()
        app.buttons["privacy-save"].tap()
        XCTAssertFalse(app.staticTexts["Privacy & controls"].exists)
        app.buttons["open-profile"].tap()
        app.buttons["open-privacy"].tap()
        XCTAssertEqual(app.switches["privacy-location"].value as? String, "1")
    }

    func testProfileMenuOpensAllAvailableLocalDetailScreens() {
        app.buttons["open-profile"].tap()
        let routes: [(String, String)] = [
            ("open-child-profile", "Child profile"),
            ("open-preferences", "Discovery preferences"),
            ("open-notifications", "Notifications"),
            ("open-location", "Location"),
            ("open-parent-controls", "Parent controls"),
            ("open-account", "Account")
        ]
        for (button, title) in routes {
            app.buttons[button].tap()
            XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 5))
            app.buttons["profile-detail-save"].tap()
            XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 5))
        }
        XCTAssertFalse(app.buttons["Friends & Family"].isEnabled)
    }
}