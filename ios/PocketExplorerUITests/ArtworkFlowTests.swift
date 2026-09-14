import XCTest

final class ArtworkFlowTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = "http://127.0.0.1:4197"
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    func testSlowArtworkKeepsTheCardUsableAndOffersAStatusCheck() {
        makeCard("slow illustration of the sky")
        let title = app.staticTexts["artwork-status-title"]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertEqual(title.label, "A little more time for the picture")
        let check = app.buttons["retry-artwork"]
        scrollTo(check)
        XCTAssertEqual(check.label, "Check illustration")
        capture("slow-artwork-card-is-saved")
        check.tap()
        XCTAssertEqual(title.label, "A little more time for the picture")
        let reveal = app.buttons["reveal-card"]
        scrollTo(reveal); reveal.tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 8))
        scrollTo(app.buttons["new-card-memory"])
        app.buttons["new-card-memory"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 8))
        capture("memory-works-while-artwork-is-pending")
        app.buttons["memory-share-preview"].tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["create-share"].isHittable)
        app.swipeUp(velocity: .slow)
        capture("share-preview-while-artwork-is-pending")
    }

    func testFailedArtworkCanRecoverWithoutLosingTheCard() {
        makeCard("failed illustration of the sky")
        let retry = app.buttons["retry-artwork"]
        XCTAssertTrue(retry.waitForExistence(timeout: 10))
        scrollTo(retry)
        XCTAssertEqual(retry.label, "Try illustration again")
        capture("failed-artwork-recovery")
        retry.tap()
        let recovered = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: retry)
        XCTAssertEqual(XCTWaiter.wait(for: [recovered], timeout: 10), .completed)
        XCTAssertTrue(app.buttons["reveal-card"].exists)
    }

    func testExhaustedArtworkHasNoImpossibleRetryAndStillAllowsReading() {
        makeCard("exhausted illustration of the sky")
        let title = app.staticTexts["artwork-status-title"]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertEqual(title.label, "Keep exploring with this card")
        XCTAssertFalse(app.buttons["retry-artwork"].exists)
        capture("exhausted-artwork-no-dead-end")
        let reveal = app.buttons["reveal-card"]
        scrollTo(reveal); reveal.tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 8))
    }

    func testMissingSavedPictureShowsAReadableFallbackAndKeepsTheDiscovery() throws {
        app.terminate()
        let card = "20000000-0000-4000-8000-000000000011"
        let trip = "10000000-0000-4000-8000-000000000011"
        let journal: [String: Any] = ["version": 1,
            "trips": [["id": trip, "title": "A leaf discovery", "startedAt": 810000000, "isExample": false]],
            "discoveries": [["id": card, "tripID": trip, "subject": "leaf", "question": "Why is this leaf green?", "observation": "I found a tiny green leaf.", "explanation": "Leaves catch sunlight.", "createdAt": 810000000,
                "photoFilename": "missing-photo.jpg", "artworkFilename": "missing-picture.png"]]]
        app.launchEnvironment["POCKET_TEST_JOURNAL"] = String(data: try JSONSerialization.data(withJSONObject: journal), encoding: .utf8)
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.tabBars.buttons["Map"].tap()
        app.buttons["open-collection"].tap()
        app.buttons["collection-card-\(card)"].tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 8))
        let fallback = app.staticTexts["Picture unavailable"]
        for _ in 0..<4 where !fallback.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(fallback.waitForExistence(timeout: 8))
        capture("missing-picture-readable-card")
        for _ in 0..<4 where !app.buttons["discovery-card"].isHittable { app.swipeDown(velocity: .slow) }
        app.buttons["discovery-card"].tap()
        XCTAssertEqual(app.staticTexts["card-observation"].label, "I found a tiny green leaf.")
    }

    private func makeCard(_ question: String) {
        app.buttons["home-question"].tap()
        let field = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        XCTAssertTrue(field.waitForExistence(timeout: 8))
        field.tap(); field.typeText(question)
        app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 12))
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["reveal-card"].isHittable, "The primary card action must be visible without scrolling, even while artwork is pending.")
        capture("card-unlock-primary-action-visible")
    }

    private func scrollTo(_ element: XCUIElement) {
        func fullyVisible() -> Bool {
            let footer = app.buttons["reveal-card"].exists ? app.buttons["reveal-card"] : app.buttons["new-card-memory"]
            let bottom = footer.exists && footer.identifier != element.identifier ? footer.frame.minY - 12 : app.frame.maxY - 8
            return element.exists && element.isHittable && element.frame.minY >= 100 && element.frame.maxY <= bottom
        }
        for _ in 0..<7 where !fullyVisible() { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(fullyVisible(), "The whole action must be visible above the fixed footer before tapping it.")
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
