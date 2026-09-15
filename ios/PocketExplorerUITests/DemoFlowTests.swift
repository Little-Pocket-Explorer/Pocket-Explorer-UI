import XCTest

final class DemoFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let base = FixtureServer.base

    override func setUpWithError() throws {
        continueAfterFailure = false
        _ = try control("/__fixture/demo/reset")
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
    }

    override func tearDownWithError() throws {
        app.terminate()
        _ = try control("/__fixture/demo/reset")
    }

    func testPrivateActivationOrderedOfflinePresentationAndRevocation() throws {
        let normal = questions()
        app.buttons["open-profile"].tap()
        XCTAssertFalse(app.switches["demo-mode-toggle"].exists)
        app.buttons["Done"].tap()
        XCTAssertEqual(try control("/__fixture/demo/status")["demoAccessReads"] as? Int, 0)
        app.open(URL(string: "pocketexplorer://demo/activate#" + String(repeating: "x", count: 43))!)
        XCTAssertTrue(app.buttons["activate-demo"].waitForExistence(timeout: 5))
        app.buttons["activate-demo"].tap()
        XCTAssertTrue(app.staticTexts["Demo access is ready"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        XCTAssertEqual(questions(), normal)
        app.buttons["open-profile"].tap()
        let toggle = app.switches["demo-mode-toggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "0")
        reach(toggle)
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(toggle.value as? String, "1")
        let ready = app.descendants(matching: .any).matching(identifier: "demo-readiness").firstMatch
        XCTAssertTrue(ready.waitForExistence(timeout: 10))
        XCTAssertTrue(ready.label.contains("Ready to present offline"))
        capture("private-demo-profile")
        app.buttons["Done"].tap()
        XCTAssertEqual(questions(), ["daily-question-demo-blue-sky", "daily-question-demo-moonlight", "daily-question-demo-ocean-salt"])
        capture("private-demo-ordered-home")
        let all = app.buttons["All demo discoveries"]
        for _ in 0..<3 where !all.isHittable { app.swipeUp() }
        all.tap()
        app.buttons["How does a prism make a rainbow?"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["listen-answer"].label, "Stop reply")
        app.buttons["exploration-close"].tap()
        _ = try control("/__fixture/daily/offline")
        app.terminate()
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
        app.launch()
        XCTAssertTrue(app.buttons["daily-question-demo-blue-sky"].waitForExistence(timeout: 8))
        app.buttons["daily-question-demo-blue-sky"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["listen-answer"].label, "Stop reply")
        app.buttons["exploration-close"].tap()
        app.buttons["open-profile"].tap()
        reach(toggle)
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(toggle.value as? String, "0")
        app.buttons["Done"].tap()
        XCTAssertEqual(questions(), normal)
        _ = try control("/__fixture/daily/reset")
        _ = try control("/__fixture/demo/revoke")
        XCUIDevice.shared.press(.home); app.activate()
        app.buttons["open-profile"].tap()
        XCTAssertFalse(toggle.exists)
        capture("revoked-demo-no-entry")
    }

    func testInvalidInvitationIsRecoverableAndCancellationDoesNotEnableAnything() throws {
        app.open(URL(string: "pocketexplorer://demo/activate#" + String(repeating: "y", count: 43))!)
        XCTAssertTrue(app.buttons["activate-demo"].waitForExistence(timeout: 5))
        app.buttons["activate-demo"].tap()
        XCTAssertTrue(app.staticTexts["demo-activation-error"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        app.open(URL(string: "pocketexplorer://demo/activate#" + String(repeating: "x", count: 43))!)
        XCTAssertTrue(app.buttons["activate-demo"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        app.buttons["open-profile"].tap()
        XCTAssertFalse(app.switches["demo-mode-toggle"].exists)
    }

    private func reach(_ element: XCUIElement) {
        for _ in 0..<12 where !element.isHittable {
            let origin = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
            origin.press(forDuration: 0.05, thenDragTo: origin.withOffset(CGVector(dx: 0, dy: -180)))
        }
        XCTAssertTrue(element.isHittable)
    }

    private func questions() -> [String] {
        let values = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-"))
        XCTAssertTrue(values.firstMatch.waitForExistence(timeout: 10))
        return values.allElementsBoundByIndex.map(\.identifier)
    }
    private func control(_ path: String) throws -> [String: Any] {
        let done = expectation(description: "Fixture control")
        var output: Result<Data, Error>?
        URLSession.shared.dataTask(with: URL(string: base + path)!) { data, response, error in
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            output = error.map(Result.failure) ?? .success(data ?? Data()); done.fulfill()
        }.resume()
        wait(for: [done], timeout: 5)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: output!.get()) as? [String: Any])
    }
    private func capture(_ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name; image.lifetime = .keepAlways; add(image)
    }
}
