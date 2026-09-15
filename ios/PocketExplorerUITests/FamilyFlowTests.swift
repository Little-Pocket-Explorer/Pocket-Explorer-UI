import XCTest

@MainActor final class FamilyFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private var base: String { PitchFixtureServer.base }

    override func setUp() async throws {
        continueAfterFailure = false
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/reset")!)
    }
    private func launch(_ language: String = "en", reset: Bool = true) {
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(\(language))", "-AppleLocale", language]
        if reset { app.launchArguments += ["--reset-journal", "--reset-language"] }
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        if reset { XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15)); app.buttons["language-continue"].tap() }
        XCTAssertTrue(app.buttons["open-profile"].waitForExistence(timeout: 15))
    }
    private func reach(_ element: XCUIElement) {
        for _ in 0..<12 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }
    private func settings() {
        app.buttons["open-profile"].tap()
        reach(app.buttons["open-family-settings"]); app.buttons["open-family-settings"].tap()
    }
    private func enterPIN(_ value: String, confirm: Bool = false) {
        let input = app.secureTextFields[confirm ? "family-confirm-pin" : "family-pin"]
        reach(input); input.tap(); input.typeText(value)
    }
    private func create() -> String {
        settings()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 5))
        enterPIN("926418"); enterPIN("926418", confirm: true)
        reach(app.buttons["family-create"]); app.buttons["family-create"].tap()
        let recovery = app.staticTexts["family-recovery-code"]
        XCTAssertTrue(recovery.waitForExistence(timeout: 10))
        let code = recovery.label
        app.buttons["family-recovery-saved"].tap()
        return code
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    private func toggle(_ id: String, expected: String) {
        let control = app.switches[id]
        reach(control)
        control.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(control.value as? String, expected)
    }
    func testSetupPrivacyPermissionsPersistenceWrongPINAndRecovery() {
        launch(); let code = create()
        toggle("family-sharing", expected: "0")
        toggle("family-social", expected: "1")
        capture("family-permissions-English")
        reach(app.buttons["family-save"]); app.buttons["family-save"].tap()
        XCTAssertTrue(app.staticTexts["Family settings saved"].waitForExistence(timeout: 10))
        app.buttons["family-done"].tap()
        reach(app.buttons["open-family-settings"]); app.buttons["open-family-settings"].tap()
        enterPIN("000000"); app.buttons["family-unlock"].tap()
        XCTAssertTrue(app.staticTexts["family-error"].waitForExistence(timeout: 10))
        app.buttons["Forgot your PIN?"].tap()
        app.textFields["family-recovery-input"].tap(); app.textFields["family-recovery-input"].typeText(code)
        enterPIN("819273"); enterPIN("819273", confirm: true)
        reach(app.buttons["family-unlock"]); app.buttons["family-unlock"].tap()
        XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 10))
        XCTAssertNotEqual(app.staticTexts["family-recovery-code"].label, code)
        app.buttons["family-recovery-saved"].tap()
        reach(app.switches["family-sharing"]); XCTAssertEqual(app.switches["family-sharing"].value as? String, "0")
        app.terminate(); launch(reset: false); settings()
        XCTAssertTrue(app.secureTextFields["family-pin"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.textFields["family-nickname"].exists)
        enterPIN("819273"); app.buttons["family-unlock"].tap()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 10))
        capture("family-unlocked-after-relaunch")
    }
    func testScreenBreakAndChineseFamilySettingsRemainReachable() async throws {
        launch("zh-Hans"); _ = create(); capture("family-profile-Chinese")
        app.buttons["family-done"].tap()
        app.terminate()
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/expire")!)
        app.launchArguments.removeAll { $0 == "--reset-journal" || $0 == "--reset-language" }
        app.launch()
        XCTAssertTrue(app.buttons["pause-family-settings"].waitForExistence(timeout: 15))
        capture("family-screen-break-Chinese")
        app.buttons["pause-family-settings"].tap()
        XCTAssertTrue(app.secureTextFields["family-pin"].waitForExistence(timeout: 5))
        enterPIN("926418"); app.buttons["family-unlock"].tap()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 10))
    }
    func testScreenBreakCoversAnAlreadyPresentedSheet() async throws {
        launch(); _ = create(); app.buttons["family-done"].tap()
        XCTAssertTrue(app.buttons["open-family-settings"].exists)
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/expire")!)
        let pause = app.buttons["pause-family-settings"]
        XCTAssertTrue(pause.waitForExistence(timeout: 45))
        XCTAssertTrue(pause.isHittable)
        capture("screen-break-covers-profile-sheet")
        pause.tap(); enterPIN("926418"); app.buttons["family-unlock"].tap()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 10))
        let minutes = app.steppers["family-minutes"]
        reach(minutes); minutes.buttons["family-minutes-Decrement"].tap()
        reach(app.buttons["family-save"]); app.buttons["family-save"].tap()
        XCTAssertTrue(app.buttons["open-family-settings"].waitForExistence(timeout: 10))
        XCTAssertFalse(pause.exists)
        capture("parent-restores-original-profile-sheet")
    }
}
