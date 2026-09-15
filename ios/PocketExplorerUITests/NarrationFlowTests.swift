import XCTest

final class NarrationFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let base = FixtureServer.base
    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }
    func testCloudNarrationCanStopReplayFromCacheAndKeepTheDiscovery() {
        let question = "cloud narration " + UUID().uuidString
        ask(question)
        let listen = app.buttons["listen-answer"]
        XCTAssertTrue(listen.waitForExistence(timeout: 8))
        XCTAssertGreaterThanOrEqual(listen.frame.height, 44)
        XCTAssertEqual(listen.label, "Stop reply")
        expectRequests(question, 1)
        listen.tap(); XCTAssertEqual(listen.label, "Listen")
        listen.tap(); XCTAssertEqual(listen.label, "Stop reply")
        expectRequests(question, 1)
        let transition = expectation(description: "Capture playback after the label transition settles")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { transition.fulfill() }
        wait(for: [transition], timeout: 3)
        XCTAssertEqual(listen.label, "Stop reply")
        let screenshot = XCTAttachment(screenshot: app.screenshot()); screenshot.name = "cloud-narration-playback"; screenshot.lifetime = .keepAlways; add(screenshot)
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
    }
    func testCancelledSlowNarrationNeverRestartsAfterAnotherQuestion() {
        ask("slow narration " + UUID().uuidString)
        app.buttons["listen-answer"].tap()
        XCTAssertEqual(app.buttons["listen-answer"].label, "Listen")
        let another = app.buttons["ask-another"]
        for _ in 0..<5 where another.frame.maxY >= app.buttons["save-discovery"].frame.minY - 8 { app.swipeUp() }
        XCTAssertLessThan(another.frame.maxY, app.buttons["save-discovery"].frame.minY)
        another.tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        let stable = expectation(description: "Remain in the new question after the old response arrives")
        DispatchQueue.main.asyncAfter(deadline: .now() + 16) { stable.fulfill() }
        wait(for: [stable], timeout: 18)
        XCTAssertFalse(app.buttons["listen-answer"].exists)
        XCTAssertFalse(app.staticTexts["exploration-error"].exists)
        XCTAssertTrue(input.isEnabled)
    }
    func testUnavailableCloudVoiceFallsBackWithoutBlockingReadingOrSaving() {
        ask("unavailable narration " + UUID().uuidString)
        XCTAssertTrue(app.buttons["listen-answer"].waitForExistence(timeout: 8))
        XCTAssertEqual(app.buttons["listen-answer"].label, "Stop reply")
        XCTAssertFalse(app.staticTexts["exploration-error"].exists)
        app.buttons["listen-answer"].tap()
        XCTAssertEqual(app.buttons["listen-answer"].label, "Listen")
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
    }
    private var input: XCUIElement {
        if app.textViews["exploration-input"].exists { return app.textViews["exploration-input"] }
        return app.textFields["exploration-input"]
    }
    private func ask(_ question: String) {
        app.buttons["home-question"].tap()
        let field = input
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        field.tap(); field.typeText(question)
        app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 12))
    }
    private func expectRequests(_ question: String, _ count: Int) {
        let read = expectation(description: "Independent narration request count")
        var url = URLComponents(string: base + "/__fixture/narration-count")!
        url.queryItems = [URLQueryItem(name: "question", value: question)]
        URLSession.shared.dataTask(with: url.url!) { data, _, error in
            XCTAssertNil(error)
            let object = try? JSONSerialization.jsonObject(with: data!) as? [String: Int]
            XCTAssertEqual(object?["count"], count)
            read.fulfill()
        }.resume()
        wait(for: [read], timeout: 5)
    }
}
