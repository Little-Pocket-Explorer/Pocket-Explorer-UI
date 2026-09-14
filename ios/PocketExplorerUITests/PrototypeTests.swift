import XCTest

final class PrototypeTests: XCTestCase {
    private let app = XCUIApplication()
    private let pond = "10000000-0000-4000-8000-000000000001"
    private let shell = "20000000-0000-4000-8000-000000000004"

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = "http://127.0.0.1:4197"
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    func testLanguageChoiceIsRememberedAndCardsRemainAvailable() {
        app.buttons["open-profile"].tap()
        app.buttons["choose-language"].tap()
        XCTAssertTrue(app.buttons["language-chinese"].waitForExistence(timeout: 6))
        app.buttons["language-chinese"].tap(); app.buttons["language-continue"].tap()
        XCTAssertTrue(app.tabBars.buttons["地图"].waitForExistence(timeout: 6))
        capture("home-zh")
        app.buttons["home-question"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 6))
        XCTAssertEqual(app.buttons["speak-button"].label, "说出你的问题")
        capture("ask-zh")
        app.buttons["关闭"].tap()
        relaunch()
        XCTAssertTrue(app.tabBars.buttons["地图"].waitForExistence(timeout: 10))
        app.tabBars.buttons["地图"].tap(); app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("4 个小发现"))
        app.tabBars.buttons["探索"].tap(); app.buttons["open-profile"].tap(); app.buttons["choose-language"].tap()
        let english = app.buttons["language-english"]
        scrollTo(english); english.tap()
        let selected = expectation(for: NSPredicate(format: "selected == true"), evaluatedWith: english)
        wait(for: [selected], timeout: 5)
        capture("language-selected-english")
        app.buttons["language-continue"].tap()
        XCTAssertTrue(app.tabBars.buttons["Map"].waitForExistence(timeout: 6))
    }

    func testCollectionSearchSortCardDetailsAndEditingPersist() {
        openCollection()
        app.buttons["Animals"].tap()
        XCTAssertTrue(app.buttons["collection-card-\(shell)"].exists)
        XCTAssertFalse(app.buttons["collection-card-20000000-0000-4000-8000-000000000002"].exists)
        app.buttons["All"].tap()
        app.buttons["Reverse sort order"].tap()
        let search = app.textFields["collection-search"]
        search.tap(); search.typeText("shell")
        let card = app.buttons["collection-card-\(shell)"]
        XCTAssertTrue(card.waitForExistence(timeout: 5)); card.tap()
        app.buttons["discovery-card"].tap()
        XCTAssertTrue(app.staticTexts["card-observation"].exists)
        app.buttons["discovery-card"].tap()
        scrollTo(app.buttons["Add to my story"]); app.buttons["Add to my story"].tap()
        let editor = app.textViews["edit-observation"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5)); editor.tap(); editor.typeText(" I noticed a ridge.")
        app.buttons["Save"].tap()
        scrollTo(app.buttons["Knowledge"]); app.buttons["Knowledge"].tap()
        XCTAssertTrue(app.staticTexts["Many molluscs grow shells that protect their soft bodies."].exists)
        app.buttons["Location"].tap(); XCTAssertTrue(app.staticTexts["Exact coordinates stay in your journal."].exists)
        capture("card-location")
        relaunch(); openCollection(); scrollTo(app.buttons["collection-card-\(shell)"]); app.buttons["collection-card-\(shell)"].tap()
        app.buttons["discovery-card"].tap()
        XCTAssertTrue(app.staticTexts["card-observation"].label.contains("I noticed a ridge."))
    }

    func testTripMemoryPlaybackAndPublicShareCanBeReadAndRevoked() {
        openTrip()
        scrollTo(app.buttons["make-memory"]); app.buttons["make-memory"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 6))
        app.buttons["memory-play-pause"].tap(); app.buttons["memory-play-pause"].tap()
        app.buttons["Next chapter"].tap(); app.buttons["Previous chapter"].tap(); app.buttons["memory-replay"].tap()
        capture("trip-memory")
        app.buttons["Done"].tap(); scrollTo(app.buttons["share-trip"]); app.buttons["share-trip"].tap()
        XCTAssertEqual(app.switches["Include a first name"].value as? String, "0")
        XCTAssertEqual(app.switches["Include the city"].value as? String, "0")
        XCTAssertFalse(app.secureTextFields["Family owner key"].exists)
        app.switches["Include a first name"].tap()
        app.textFields["First name"].tap(); app.textFields["First name"].typeText("Ari")
        app.switches["Include the city"].tap()
        app.buttons["create-share"].tap()
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 15))
        let url = app.staticTexts["share-url"].label
        verifyShare(url, status: 200)
        relaunch(); openTrip(); scrollTo(app.buttons["share-trip"]); app.buttons["share-trip"].tap()
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 6))
        XCTAssertEqual(app.staticTexts["share-url"].label, url)
        app.buttons["Copy link"].tap(); XCTAssertEqual(app.staticTexts["share-message"].label, "Link copied.")
        app.buttons["Stop sharing this story"].tap()
        let stopped = expectation(for: NSPredicate(format: "label == %@", "This link is no longer shared."), evaluatedWith: app.staticTexts["share-message"])
        wait(for: [stopped], timeout: 10); verifyShare(url, status: 410)
    }

    func testEmptyCollectionAndRemindersOfferClearNextActions() {
        app.terminate(); app.launchArguments += ["--empty-journal"]; app.launch()
        app.buttons["language-continue"].tap(); openCollection()
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("0 discoveries"))
        capture("empty-collection")
        app.buttons["collection-reminders"].tap()
        XCTAssertTrue(app.staticTexts["Nothing to catch up on. Come back after your next discovery."].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        scrollTo(app.buttons["Find another wonder"]); app.buttons["Find another wonder"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 6))
        app.buttons["Take a photo"].tap()
        if app.buttons["PhotoCapture"].waitForExistence(timeout: 5) {
            capture("camera-entry")
            app.buttons["DismissImagePickerButton"].tap()
        } else {
            XCTAssertTrue(app.staticTexts["exploration-error"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["exploration-error"].label.contains("camera"))
        }
        XCTAssertTrue(app.textFields["exploration-input"].exists || app.textViews["exploration-input"].exists)
    }

    func testQuestionHistoryReopensTheSavedAnswer() {
        app.buttons["home-question"].tap()
        let input = app.textFields["exploration-input"].exists ? app.textFields["exploration-input"] : app.textViews["exploration-input"]
        input.tap(); input.typeText("Why is the sky blue?"); app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 10))
        app.buttons["Close"].tap(); app.buttons["question-history"].tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Blue sky'")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["save-discovery"].isHittable)
        app.buttons["ask-another"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 5))
    }

    func testLargeTextKeepsPrimaryActionsReachable() {
        app.terminate(); app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]; app.launch()
        scrollTo(app.buttons["language-continue"]); app.buttons["language-continue"].tap()
        XCTAssertTrue(app.buttons["home-ask"].waitForExistence(timeout: 10))
        app.buttons["home-question"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(app.buttons["speak-button"].frame.height, 44)
        let input = app.textFields["exploration-input"].exists ? app.textFields["exploration-input"] : app.textViews["exploration-input"]
        input.tap(); input.typeText("Why is the sky blue?"); app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["save-discovery"].isHittable)
        capture("large-text-answer")
    }

    func testMapMarkerOpensTheMatchingAdventure() {
        app.tabBars.buttons["Map"].tap()
        let marker = app.buttons["map-trip-\(pond)"]
        capture("map-markers")
        let hierarchy = XCTAttachment(string: app.debugDescription); hierarchy.name = "map-hierarchy"; hierarchy.lifetime = .keepAlways; add(hierarchy)
        XCTAssertTrue(marker.waitForExistence(timeout: 8))
        XCTAssertTrue(marker.isHittable)
        marker.tap()
        XCTAssertTrue(app.staticTexts["The day we met the ducks"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["My adventure"].exists)
    }

    private func relaunch() {
        app.terminate(); app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]; app.launch()
        XCTAssertTrue(app.buttons["home-ask"].waitForExistence(timeout: 10))
    }
    private func openCollection() {
        app.tabBars.buttons["Map"].tap(); app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 6))
    }
    private func openTrip() {
        app.tabBars.buttons["Map"].tap()
        app.buttons["trip-\(pond)"].tap()
        XCTAssertTrue(app.navigationBars["My adventure"].waitForExistence(timeout: 6))
    }
    private func verifyShare(_ url: String, status: Int) {
        let done = expectation(description: "Independent public read")
        URLSession.shared.dataTask(with: URL(string: "http://127.0.0.1:4197/api/shares/" + URL(string: url)!.lastPathComponent)!) { data, response, error in
            XCTAssertNil(error); XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, status)
            if status == 200 {
                let object = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
                XCTAssertEqual(object?["title"] as? String, "The day we met the ducks")
                XCTAssertEqual(object?["firstName"] as? String, "Ari")
                XCTAssertEqual(object?["city"] as? String, "Sydney")
            }
            done.fulfill()
        }.resume()
        wait(for: [done], timeout: 10)
    }
    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<10 where !element.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
