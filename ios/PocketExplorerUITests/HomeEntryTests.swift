import XCTest

final class HomeEntryTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = "http://127.0.0.1:4197"
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    func testSuggestedQuestionAnswersInOneTapAndTheNextComposerStartsEmpty() {
        let question = app.buttons["Why is the sky blue?"]
        for _ in 0..<4 where !question.isHittable { app.swipeUp() }
        question.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 10))
        capture("home-suggestion-one-tap-answer")
        app.buttons["Close"].tap()
        app.buttons["home-question"].tap()
        let input = app.textFields["exploration-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        XCTAssertEqual(input.value as? String, "Ask anything…")
        XCTAssertTrue(app.keyboards.firstMatch.exists)
        XCTAssertFalse(app.buttons["ask-button"].isEnabled)
    }

    func testHomeCameraOpensTheCameraPathDirectly() {
        app.buttons["home-camera"].tap()
        if app.buttons["PhotoCapture"].waitForExistence(timeout: 5) {
            capture("home-camera-open")
            app.buttons["DismissImagePickerButton"].tap()
        } else {
            XCTAssertTrue(app.staticTexts["exploration-error"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["exploration-error"].label.contains("camera"))
            capture("home-camera-unavailable-on-simulator")
        }
        XCTAssertTrue(app.buttons["speak-button"].exists)
    }

    func testHomeMicrophoneRequestsAccessAndDenialKeepsTypingAvailable() {
        app.resetAuthorizationStatus(for: .microphone)
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.buttons["home-ask"].tap()
        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = app.alerts.firstMatch.waitForExistence(timeout: 3) ? app.alerts.firstMatch : system.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 8), "The home microphone must actually request recording access.")
        alert.buttons.matching(NSPredicate(format: "label BEGINSWITH[c] 'Don'")).firstMatch.tap()
        let error = app.staticTexts["exploration-error"]
        XCTAssertTrue(error.waitForExistence(timeout: 8))
        XCTAssertTrue(error.label.contains("Microphone access is off"))
        let input = app.textFields["exploration-input"]
        XCTAssertTrue(input.isEnabled)
        input.tap(); input.typeText("Why is the sky blue?")
        app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 8))
        capture("microphone-denied-typing-still-works")
    }

    func testMicrophonePermissionStartsCaptureAndFinishingReturnsToTyping() throws {
        guard ProcessInfo.processInfo.environment["POCKET_RUN_LIVE_MICROPHONE"] == "1" else {
            throw XCTSkip("Requires working host microphone input. The released baseline also aborts in AudioUnit initialization on this Mac.")
        }
        app.resetAuthorizationStatus(for: .microphone)
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.buttons["home-ask"].tap()
        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for _ in 0..<2 {
            let alert = app.alerts.firstMatch.waitForExistence(timeout: 2) ? app.alerts.firstMatch : system.alerts.firstMatch
            if alert.waitForExistence(timeout: 3) {
                let allow = alert.buttons.matching(NSPredicate(format: "label == 'Allow' OR label == 'OK'")).firstMatch
                XCTAssertTrue(allow.exists, "Only the microphone and speech permission dialogs are expected.")
                allow.tap()
            }
        }
        XCTAssertTrue(app.staticTexts["I'm listening…"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.textFields["exploration-input"].isEnabled)
        capture("microphone-listening-after-permission")
        app.buttons["speak-button"].tap()
        let editable = expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: app.textFields["exploration-input"])
        wait(for: [editable], timeout: 6)
        XCTAssertEqual(app.buttons["speak-button"].label, "Speak your question")
        app.buttons["Close"].tap()
        app.buttons["home-question"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 8))
        XCTAssertFalse(app.staticTexts["I'm listening…"].exists)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
