import XCTest

final class LiveShareTests: XCTestCase {
    private let app = XCUIApplication()
    private var created = false

    override func tearDown() {
        if created, app.buttons["Stop sharing this story"].exists {
            app.buttons["Stop sharing this story"].tap()
        }
    }

    func testNativeQuestionUsesTheLiveWorkerWithoutGeneratingAnotherImage() throws {
        guard let base = ProcessInfo.processInfo.environment["POCKET_LIVE_AI_BASE_URL"] else {
            throw XCTSkip("Enable only for authorized live AI verification.")
        }
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap(); app.buttons["home-ask"].tap()
        let field = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        field.tap(); field.typeText("Why do shadows get longer in the evening?")
        app.buttons["ask-button"].tap()
        let answer = app.staticTexts["live-answer"]
        XCTAssertTrue(answer.waitForExistence(timeout: 105))
        XCTAssertGreaterThan(answer.label.count, 40)
        XCTAssertTrue(app.buttons["save-discovery"].isHittable)
        let text = XCTAttachment(string: answer.label)
        text.name = "live-worker-answer"; text.lifetime = .keepAlways; add(text)
        let screen = XCTAttachment(screenshot: app.screenshot())
        screen.name = "native-live-worker"; screen.lifetime = .keepAlways; add(screen)
    }

    func testNativeSharingUsesTheDeployedServiceAndCanBeRevoked() throws {
        guard ProcessInfo.processInfo.environment["POCKET_RUN_LIVE_SHARE"] == "1" else { throw XCTSkip("Enable only for authorized live deployment verification.") }
        continueAfterFailure = false
        let base = ProcessInfo.processInfo.environment["POCKET_SHARE_BASE_URL"] ?? "https://pocket.changhai.me"
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15)); app.buttons["language-continue"].tap()
        app.tabBars.buttons["Map"].tap(); app.buttons["trip-10000000-0000-4000-8000-000000000001"].tap()
        let share = app.buttons["share-trip"]
        for _ in 0..<10 where !share.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(share.isHittable); share.tap()
        app.buttons["create-share"].tap()
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 20))
        created = true
        let url = try XCTUnwrap(URL(string: app.staticTexts["share-url"].label))
        let apiURL = try XCTUnwrap(URL(string: base + "/api/shares/" + url.lastPathComponent))
        let read = expectation(description: "Independent deployed read")
        URLSession.shared.dataTask(with: apiURL) { data, response, error in
            XCTAssertNil(error); XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            let object = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
            XCTAssertEqual(object?["title"] as? String, "The day we met the ducks")
            XCTAssertNil(object?["firstName"]); XCTAssertNil(object?["city"])
            read.fulfill()
        }.resume()
        wait(for: [read], timeout: 15)
        let attachment = XCTAttachment(string: url.absoluteString); attachment.name = "deployed-native-share"; attachment.lifetime = .keepAlways; add(attachment)
        app.buttons["Stop sharing this story"].tap()
        let stopped = expectation(for: NSPredicate(format: "label == %@", "This link is no longer shared."), evaluatedWith: app.staticTexts["share-message"])
        wait(for: [stopped], timeout: 15)
        created = false
        let revoked = expectation(description: "Independent deployed revocation")
        URLSession.shared.dataTask(with: apiURL) { _, response, _ in
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 410); revoked.fulfill()
        }.resume()
        wait(for: [revoked], timeout: 15)
    }
}
