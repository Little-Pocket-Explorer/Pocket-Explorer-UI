import XCTest

@MainActor final class ChildProfileFlowTests: XCTestCase {
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
        for _ in 0..<20 where !element.isHittable {
            let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            origin.press(forDuration: 0.05, thenDragTo: origin.withOffset(CGVector(dx: 0, dy: -140)))
        }
        XCTAssertTrue(element.isHittable)
    }
    func testProfileUsesProtectedServerDetailsAndKeepsLanguageChoice() {
        app.buttons["open-profile"].tap()
        XCTAssertTrue(app.staticTexts["profile-nickname-display"].waitForExistence(timeout: 5))
        let age = app.steppers["profile-age"]; reach(age)
        age.buttons.element(boundBy: 1).tap()
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "connected-profile-before-setup"; shot.lifetime = .keepAlways; add(shot)
        reach(app.buttons["open-family-settings"]); app.buttons["open-family-settings"].tap()
        let name = app.textFields["family-nickname"]; reach(name); name.tap()
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 24) + "Sky Explorer\n")
        let nature = app.switches["Nature"]; reach(nature)
        nature.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(nature.value as? String, "1")
        for id in ["family-pin", "family-confirm-pin"] {
            let input = app.secureTextFields[id]; reach(input); input.tap(); input.typeText("926418")
        }
        reach(app.buttons["family-create"]); app.buttons["family-create"].tap()
        XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 15))
        app.buttons["family-recovery-saved"].tap(); app.buttons["family-done"].tap()
        for _ in 0..<12 where !app.staticTexts["profile-nickname-display"].isHittable { app.swipeDown() }
        XCTAssertEqual(app.staticTexts["profile-nickname-display"].label, "Sky Explorer")
        XCTAssertFalse(app.steppers["profile-age"].exists)
        reach(app.buttons["choose-language"]); app.buttons["choose-language"].tap()
        XCTAssertTrue(app.buttons["language-chinese"].waitForExistence(timeout: 10))
        app.buttons["language-chinese"].tap(); app.buttons["language-continue"].tap()
        XCTAssertTrue(app.buttons["open-profile"].waitForExistence(timeout: 10)); app.buttons["open-profile"].tap()
        XCTAssertTrue(app.staticTexts["profile-nickname-display"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["profile-nickname-display"].label, "Sky Explorer")
        let final = XCTAttachment(screenshot: app.screenshot()); final.name = "connected-profile-Chinese"; final.lifetime = .keepAlways; add(final)
    }
}
