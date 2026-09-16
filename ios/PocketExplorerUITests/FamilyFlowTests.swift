import XCTest

@MainActor final class FamilyFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private var base: String { PitchFixtureServer.base }

    override func setUp() async throws {
        continueAfterFailure = false
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/reset?privacy=required")!)
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
        func visible() -> Bool {
            guard element.exists, element.isHittable else { return false }
            let viewport = app.frame.insetBy(dx: 0, dy: 1)
            return viewport.contains(CGPoint(x: element.frame.midX, y: element.frame.midY))
        }
        for _ in 0..<12 {
            if visible() { break }
            app.swipeUp()
        }
        if !visible() { capture("unreachable-\(element.identifier)") }
        XCTAssertTrue(visible(), "Element frame \(element.frame), application frame \(app.frame)")
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
    func testAccountDeletionRequiresParentConfirmationAndRevokesTheInstallation() async throws {
        launch(); _ = create()
        reach(app.buttons["delete-account"]); app.buttons["delete-account"].tap()
        let cancel = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        cancel.tap()
        XCTAssertTrue(app.buttons["delete-account"].isHittable)
        XCTAssertFalse(app.staticTexts["Account deleted"].exists)
        app.buttons["family-done"].tap()
        reach(app.buttons["open-family-settings"]); app.buttons["open-family-settings"].tap()
        XCTAssertFalse(app.buttons["delete-account"].exists)
        enterPIN("926418"); app.buttons["family-unlock"].tap()
        reach(app.buttons["delete-account"]); app.buttons["delete-account"].tap()
        app.buttons.matching(identifier: "confirm-delete-account").firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Account deleted"].waitForExistence(timeout: 20))
        capture("account-deletion-completed-English")
        let (data, _) = try await URLSession.shared.data(from: URL(string: base + "/__fixture/account/status")!)
        let result = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(result["completed"] as? Bool, true)
        XCTAssertEqual(result["familiesRemaining"] as? Int, 0)
        XCTAssertEqual(result["retiredCredentialStatus"] as? Int, 410)
        app.terminate(); launch(reset: false)
        settings()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 5))
        reach(app.buttons["family-create"])
        XCTAssertFalse(app.buttons["family-unlock"].exists)
        enterPIN("173926"); enterPIN("173926", confirm: true)
        reach(app.buttons["family-create"]); app.buttons["family-create"].tap()
        XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 10))
        capture("new-family-after-account-deletion")
    }

    func testAccountDeletionCanRetryAfterAnOfflineFailure() async throws {
        launch(); settings()
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/offline")!)
        reach(app.buttons["delete-account"]); app.buttons["delete-account"].tap()
        app.buttons.matching(identifier: "confirm-delete-account").firstMatch.tap()
        XCTAssertTrue(app.buttons["account-deletion-retry"].waitForExistence(timeout: 20))
        XCTAssertFalse(app.staticTexts["Account deleted"].exists)
        capture("account-deletion-offline-English")
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/online")!)
        app.buttons["account-deletion-retry"].tap()
        XCTAssertTrue(app.staticTexts["Account deleted"].waitForExistence(timeout: 20))
    }

    private func privacyState() async throws -> [String: Any] {
        let (data, _) = try await URLSession.shared.data(from: URL(string: base + "/__fixture/privacy/status")!)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }
    private func allowAI() {
        let allow = app.buttons["allow-ai-data"]
        reach(allow); capture("cloud-AI-disclosure")
        allow.tap()
        XCTAssertTrue(app.buttons["withdraw-ai-data"].waitForExistence(timeout: 15))
    }
    func testAIDataPermissionRequiresParentAndCanBeWithdrawnWhileLocked() async throws {
        launch(); _ = create(); allowAI()
        let accepted = try await privacyState()
        XCTAssertEqual((accepted["permission"] as? [String: Any])?["granted"] as? Int, 1)
        app.terminate(); launch(reset: false); settings()
        reach(app.buttons["withdraw-ai-data"])
        XCTAssertFalse(app.buttons["allow-ai-data"].exists)
        app.buttons["withdraw-ai-data"].tap()
        XCTAssertTrue(app.staticTexts["Cloud AI is off"].waitForExistence(timeout: 10))
        let withdrawn = try await privacyState()
        XCTAssertEqual((withdrawn["permission"] as? [String: Any])?["granted"] as? Int, 0)
        capture("cloud-AI-withdrawn-without-unlock")
    }
    func testAIWithdrawalSurvivesOfflineAndResumesAfterRelaunchInChinese() async throws {
        launch("zh-Hans"); _ = create(); allowAI()
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/offline")!)
        app.buttons["withdraw-ai-data"].tap()
        let pending = app.staticTexts["ai-withdrawal-pending"]
        XCTAssertTrue(pending.waitForExistence(timeout: 15))
        reach(pending); capture("cloud-AI-offline-withdrawal-Chinese")
        XCTAssertFalse(app.buttons["allow-ai-data"].exists)
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/online")!)
        app.terminate(); launch("zh-Hans", reset: false); settings()
        reach(app.staticTexts["ai-permission-status"])
        XCTAssertFalse(app.buttons["withdraw-ai-data"].exists)
        let withdrawn = try await privacyState()
        XCTAssertEqual((withdrawn["permission"] as? [String: Any])?["granted"] as? Int, 0)
    }
    func testUnapprovedQuestionStaysLocalAndReturnsToItsDraft() async throws {
        launch()
        app.buttons["home-question"].tap()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5)); input.tap(); input.typeText("Why do leaves change colour?")
        app.buttons["ask-button"].tap()
        XCTAssertTrue(app.textFields["family-nickname"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["allow-ai-data"].exists)
        let state = try await privacyState()
        XCTAssertEqual(state["questions"] as? Int, 0)
        app.buttons["family-done"].tap()
        XCTAssertEqual(input.value as? String, "Why do leaves change colour?")
        XCTAssertTrue(app.buttons["navigation-home"].isHittable)
        capture("cloud-AI-declined-draft-preserved")
    }

}
