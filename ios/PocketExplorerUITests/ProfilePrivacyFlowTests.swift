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
        for attempt in 0..<20 where !element.isHittable {
            if element.exists && element.frame.maxY < app.navigationBars.firstMatch.frame.maxY + 10 {
                app.swipeDown()
            } else if !element.exists && attempt >= 5 && attempt < 15 {
                app.swipeDown()
            } else { app.swipeUp() }
        }
        XCTAssertTrue(element.isHittable)
    }
    func testFriendsAndRemindersRoutesAreUsableWithoutLocalPrivacyOverrides() {
        app.buttons["open-profile"].tap()
        reach(app.buttons["profile-friends"]); app.buttons["profile-friends"].tap()
        XCTAssertTrue(app.buttons["Family settings"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.textFields["friend-code-input"].exists)
        app.tabBars.buttons["Chat"].tap()
        reach(app.buttons["profile-reminders"]); app.buttons["profile-reminders"].tap()
        XCTAssertTrue(app.staticTexts["Discovery Quizzes"].waitForExistence(timeout: 5))
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
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = "profile-new-background"; image.lifetime = .keepAlways; add(image)
        for destination in [("profile-child", "Child profile"), ("profile-preferences", "Discovery preferences"), ("profile-privacy", "Privacy"), ("profile-location", "Location"), ("profile-parent-controls", "Parent controls")] {
            reach(app.buttons[destination.0]); app.buttons[destination.0].tap()
            XCTAssertTrue(app.navigationBars[destination.1].waitForExistence(timeout: 5))
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        reach(app.buttons["profile-account"])
        app.buttons["profile-account"].tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["choose-language"].exists)
    }

    func testDistinctProfileSettingsRequireUnlockAndPersistTheirOwnChanges() async throws {
        func tap(_ id: String) { let button = app.buttons[id]; reach(button); button.tap() }
        func enterPIN(_ value: String) {
            let field = app.secureTextFields["profile-settings-pin"]; reach(field); field.tap()
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8) + value)
            tap("profile-settings-unlock")
        }
        func open(_ id: String) {
            tap(id)
            XCTAssertTrue(app.secureTextFields["profile-settings-pin"].waitForExistence(timeout: 5))
            enterPIN("926418")
            XCTAssertTrue(app.buttons["profile-settings-unlock"].waitForNonExistence(timeout: 10))
        }
        func toggle(_ label: String) {
            let control = app.switches[label]; reach(control)
            control.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }
        func saveAndBack() {
            tap("profile-settings-save")
            XCTAssertTrue(app.staticTexts["Family settings saved"].waitForExistence(timeout: 10))
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        func fixture(_ action: String) async throws {
            let (_, response) = try await URLSession.shared.data(from: URL(string: PitchFixtureServer.base + "/__fixture/family/" + action)!)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
        }

        tap("open-profile"); tap("profile-child"); tap("profile-create-family")
        for id in ["family-pin", "family-confirm-pin"] {
            let field = app.secureTextFields[id]; reach(field); field.tap(); field.typeText("926418")
        }
        tap("family-create")
        XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 15))
        tap("family-recovery-saved"); tap("family-done")
        XCTAssertTrue(app.secureTextFields["profile-settings-pin"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.textFields["profile-child-nickname"].isEnabled)
        enterPIN("111111")
        XCTAssertTrue(app.staticTexts["profile-settings-error"].waitForExistence(timeout: 10))
        enterPIN("926418")
        let name = app.textFields["profile-child-nickname"]; reach(name); name.tap()
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 30) + "Nova Explorer\n")
        try await fixture("offline"); tap("profile-settings-save")
        XCTAssertTrue(app.staticTexts["profile-settings-error"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Family settings saved"].exists)
        try await fixture("online"); saveAndBack()

        open("profile-preferences")
        tap("profile-learning-level"); tap("A little more detail")
        toggle("Nature"); saveAndBack()
        open("profile-privacy"); toggle("Include a nickname in links"); saveAndBack()
        open("profile-location"); toggle("Publish discoveries on the map"); saveAndBack()
        open("profile-parent-controls"); toggle("Nearby events"); saveAndBack()

        app.terminate()
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
        app.launch(); tap("open-profile")
        XCTAssertEqual(app.staticTexts["profile-nickname-display"].label, "Nova Explorer")
        open("profile-preferences")
        let learningStyle = app.buttons["profile-learning-level"]
        XCTAssertTrue(learningStyle.label.contains("A little more detail") || learningStyle.staticTexts["A little more detail"].exists,
                      "The saved explanation style must remain selected after relaunch: \(learningStyle.debugDescription)")
        XCTAssertEqual(app.switches["Nature"].value as? String, "1")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        open("profile-privacy")
        XCTAssertEqual(app.switches["Include a nickname in links"].value as? String, "1")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        open("profile-location")
        XCTAssertEqual(app.switches["Publish discoveries on the map"].value as? String, "1")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        open("profile-parent-controls")
        XCTAssertEqual(app.switches["Nearby events"].value as? String, "0")
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = "profile-settings-persisted"; image.lifetime = .keepAlways; add(image)
    }
}
