import XCTest

final class PhotoFlowTests: XCTestCase {
    private let app = XCUIApplication()
    func testARealPhotoSelectionCanBeRemovedWithoutLosingTheQuestion() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = FixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap(); app.buttons["home-question"].tap()
        let input = app.textFields["exploration-input"].exists ? app.textFields["exploration-input"] : app.textViews["exploration-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.typeText("What did I find in this photo?")
        app.buttons["Choose a photo"].tap()
        let photo = app.images.matching(identifier: "PXGGridLayout-Info").firstMatch
        XCTAssertTrue(photo.waitForExistence(timeout: 10))
        capture("system-photo-picker")
        let hierarchy = XCTAttachment(string: app.debugDescription); hierarchy.name = "photo-picker-hierarchy"; hierarchy.lifetime = .keepAlways; add(hierarchy)
        photo.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let remove = app.buttons["Remove photo"]
        XCTAssertTrue(remove.waitForExistence(timeout: 10))
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.images["exploration-photo"].exists)
        XCTAssertEqual(input.value as? String, "What did I find in this photo?")
        if !remove.isHittable { app.swipeUp() }
        XCTAssertTrue(remove.isHittable)
        capture("selected-photo")
        remove.tap()
        XCTAssertTrue(app.images["exploration-photo"].waitForNonExistence(timeout: 5))
        XCTAssertEqual(input.value as? String, "What did I find in this photo?")
        XCTAssertTrue(app.buttons["ask-button"].isEnabled)
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    func testBrokenRestoredPhotoResumesTheOriginalQuestionAndShowsItsError() throws {
        continueAfterFailure = false
        let id = UUID().uuidString.lowercased()
        let question = "Why is this saved leaf green?"
        let seeded = expectation(description: "The original answer already exists on the server")
        var request = URLRequest(url: URL(string: (FixtureServer.base + "/api/explorations"))!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: ["id": id, "question": question, "language": "en", "age": 7])
        URLSession.shared.dataTask(with: request) { _, response, error in
            XCTAssertNil(error); XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200); seeded.fulfill()
        }.resume()
        wait(for: [seeded], timeout: 5)
        let record: [String: Any] = ["id": id, "question": question, "language": "en", "age": 7, "createdAt": 800000000, "photoFilename": "broken.jpg"]
        let journal: [String: Any] = ["version": 1, "trips": [], "discoveries": [], "explorations": [record]]
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = FixtureServer.base
        app.launchEnvironment["POCKET_TEST_JOURNAL"] = String(data: try JSONSerialization.data(withJSONObject: journal), encoding: .utf8)
        app.launchEnvironment["POCKET_TEST_MEDIA"] = "{\"broken.jpg\":\"YnJva2Vu\"}"
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.buttons["question-history"].tap()
        let saved = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", question)).firstMatch
        XCTAssertTrue(saved.waitForExistence(timeout: 8)); saved.tap()
        let savedQuestion = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history-question-")).firstMatch
        XCTAssertTrue(savedQuestion.waitForExistence(timeout: 5)); savedQuestion.tap()
        XCTAssertTrue(app.staticTexts["photo-error"].waitForExistence(timeout: 8))
        app.buttons["retry-answer"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 8))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["photo-error"].exists)
        capture("restored-answer-photo-error")
        app.buttons["Close"].tap()
        app.buttons["navigation-home"].tap()
        app.buttons["question-history"].tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'Blue sky'")).firstMatch.waitForExistence(timeout: 8))
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", question)).count, 0, "The same question must be updated, not duplicated after a failed photo restore.")
    }
}
