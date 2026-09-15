import XCTest

final class ChildProfileFlowTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--reset-profile", "--profile-onboarding", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
    }

    func testEmailRegistrationLeadsToAnEditableChildProfileBeforeHome() {
        XCTAssertTrue(app.buttons["signup-email-option"].waitForExistence(timeout: 10))
        app.buttons["signup-email-option"].tap()
        let email = app.textFields["signup-email"]
        XCTAssertTrue(email.waitForExistence(timeout: 5))
        email.tap(); email.typeText("family@example.com")
        app.buttons["signup-continue"].tap()
        XCTAssertTrue(app.staticTexts["Create a child profile"].waitForExistence(timeout: 5))
        app.buttons["profile-avatar-aj"].tap()
        let nickname = app.textFields["profile-nickname"]
        nickname.tap(); nickname.typeText("AJ")
        app.buttons["profile-interest-space"].tap()
        app.buttons["profile-start"].tap()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 5))
        app.buttons["language-continue"].tap()
        XCTAssertTrue(app.buttons["home-ask"].waitForExistence(timeout: 10))
    }
}