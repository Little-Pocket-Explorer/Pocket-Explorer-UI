import XCTest

final class PrototypeTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: "Optional system password and account prompts") { alert in
            if alert.buttons["Not Now"].exists { alert.buttons["Not Now"].tap(); return true }
            return false
        }
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--reset-profile", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = "http://127.0.0.1:1"
        app.launch()
        dismissAccountReminder()
        let emailOption = app.buttons["signup-email-option"]
        XCTAssertTrue(emailOption.waitForExistence(timeout: 10))
        emailOption.tap()
        let email = app.textFields["signup-email"]
        XCTAssertTrue(email.waitForExistence(timeout: 10))
        email.tap(); email.typeText("explorer@example.com")
        app.buttons["signup-continue"].tap()
        XCTAssertTrue(app.buttons["start-exploring"].waitForExistence(timeout: 10))
    }

    func testFirstUseActionsAreVisibleWithoutScrolling() {
        let start = app.buttons["start-exploring"]
        XCTAssertTrue(start.waitForExistence(timeout: 20))
        XCTAssertLessThan(start.frame.maxY, app.frame.maxY, "The main purpose must be visible without scrolling.")
        XCTAssertTrue(start.isHittable)
        capture("first-use-home")
        start.tap()
        let speak = app.buttons["speak-button"]
        XCTAssertTrue(speak.waitForExistence(timeout: 5))
        XCTAssertTrue(speak.isHittable, "The child must not scroll to find the microphone.")
        XCTAssertLessThan(speak.frame.maxY, app.frame.maxY)
        capture("first-use-entry")
    }

    func testChatSuggestionPrefillsTheExplorationQuestion() {
        let suggestion = app.buttons["Why is the sky blue?"]
        XCTAssertTrue(suggestion.waitForExistence(timeout: 10))
        suggestion.tap()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertEqual(input.value as? String, "Why is the sky blue?")
    }

    func testNavigationCardsMemoriesAndPrivacyPreview() {
        XCTAssertTrue(app.buttons["start-exploring"].waitForExistence(timeout: 20))
        capture("world")
        app.tabBars.buttons["Collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("4 discoveries"))
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Tiny ocean homes")).firstMatch.tap()
        let card = app.buttons["discovery-card"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        capture("card-front")
        card.tap()
        XCTAssertTrue(app.staticTexts["card-observation"].exists)
        capture("card-reverse")
        app.buttons["Collection"].firstMatch.tap()
        app.tabBars.buttons["Social"].tap()
        app.buttons["memory-10000000-0000-4000-8000-000000000001"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 5))
        let first = app.staticTexts["memory-chapter"].label
        scrollTo(app.buttons["Next chapter"])
        app.buttons["Next chapter"].tap()
        XCTAssertNotEqual(app.staticTexts["memory-chapter"].label, first)
        app.buttons["memory-replay"].tap()
        XCTAssertEqual(app.staticTexts["memory-chapter"].label, first)
        app.buttons["memory-play-pause"].tap()
        XCTAssertEqual(app.buttons["memory-play-pause"].label, "Play")
        capture("memory")
    }

    func testTypedExplorationPersistsAfterRelaunch() {
        app.buttons["start-exploring"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 5))
        capture("voice-entry")
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        scrollTo(input)
        input.tap()
        input.typeText("How do ducks move through water?")
        scrollTo(app.buttons["ask-button"])
        app.buttons["ask-button"].tap()
        continueToObservation()
        let observation = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        scrollTo(observation)
        observation.tap()
        observation.typeText("I saw two feet pushing backwards.")
        scrollTo(app.buttons["save-discovery"])
        app.buttons["save-discovery"].tap()
        revealEarnedCard()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 10))
        app.buttons["discovery-card"].tap()
        XCTAssertEqual(app.staticTexts["card-observation"].label, "I saw two feet pushing backwards.")
        capture("earned-card")
        app.terminate()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
        app.tabBars.buttons["Collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("5 discoveries"))
    }

    func testUnmatchedQuestionKeepsInputAndShowsDemoScope() {
        app.buttons["start-exploring"].tap()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        scrollTo(input); input.tap(); input.typeText("Why is the moon bright?")
        scrollTo(app.buttons["ask-button"]); app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["exploration-error"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["exploration-error"].label.contains("ducks, leaves and shells"))
        XCTAssertEqual(input.value as? String, "Why is the moon bright?")
        capture("guide-error")
    }

    func testSampleToCardMemoryAndSharePreviewIsOneContinuousJourney() {
        app.buttons["start-exploring"].tap()
        app.buttons["sample-leaf"].tap()
        continueToObservation()
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        scrollTo(input); input.tap(); input.typeText("One leaf has a zigzag edge.")
        app.buttons["save-discovery"].tap()
        revealEarnedCard()
        let memory = app.buttons["new-card-memory"]
        XCTAssertTrue(memory.waitForExistence(timeout: 5))
        XCTAssertTrue(memory.isHittable, "The next step must be visible without finding the trip again.")
        capture("first-use-new-card")
        memory.tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 5))
        let share = app.buttons["memory-share-preview"]
        XCTAssertTrue(app.buttons["memory-play-pause"].isHittable, "Playback must be visible without scrolling past the illustration.")
        XCTAssertTrue(app.staticTexts["memory-chapter"].isHittable)
        XCTAssertTrue(share.isHittable)
        capture("first-use-memory")
        share.tap()
        XCTAssertTrue(app.switches["Include a first name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.switches["Include a first name"].value as? String, "0")
        scrollTo(app.staticTexts["One leaf has a zigzag edge."])
        XCTAssertTrue(app.staticTexts["One leaf has a zigzag edge."].exists)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 5))
    }

    func testChineseFirstUseShowsLocalizedQuestionsAndActions() {
        app.terminate()
        app.launchArguments = ["--ui-testing", "--reset-journal", "-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        let start = app.buttons["start-exploring"]
        XCTAssertTrue(start.waitForExistence(timeout: 15))
        XCTAssertEqual(start.label, "开始探索")
        XCTAssertTrue(app.tabBars.buttons["我的卡片"].exists)
        capture("first-use-home-zh")
        start.tap()
        XCTAssertEqual(app.buttons["speak-button"].label, "点一下，说出问题")
        capture("first-use-entry-zh")
        app.buttons["sample-duck"].tap()
        continueToObservation()
        XCTAssertTrue(app.staticTexts["鸭子是怎么游泳的？"].exists)
        XCTAssertEqual(app.buttons["speak-button"].label, "说说你的发现")
        let input = app.textViews["exploration-input"].exists ? app.textViews["exploration-input"] : app.textFields["exploration-input"]
        scrollTo(input); input.tap(); input.typeText("Two feet push water.")
        XCTAssertEqual(app.buttons["save-discovery"].label, "制作我的卡片")
        app.buttons["save-discovery"].tap()
        let reveal = app.buttons["reveal-card"]
        XCTAssertTrue(reveal.waitForExistence(timeout: 5))
        XCTAssertEqual(reveal.label, "揭晓我的卡片")
        reveal.tap()
        let memory = app.buttons["new-card-memory"]
        XCTAssertTrue(memory.waitForExistence(timeout: 5))
        XCTAssertEqual(memory.label, "制作这段回忆")
        memory.tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["memory-share-preview"].label, "预览并分享")
        app.buttons["memory-share-preview"].tap()
        let create = app.buttons["create-share"]
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        XCTAssertEqual(create.label, "生成分享链接")
        XCTAssertTrue(create.isHittable)
        XCTAssertTrue(app.staticTexts["分享我的探险"].exists)
        XCTAssertFalse(app.staticTexts["请家长操作"].exists)
        capture("sharing-preview-zh")
    }

    func testLanguageChoiceIsRememberedAndCanChangeWithoutLosingCards() {
        app.buttons["choose-language"].tap()
        capture("language-choice")
        app.buttons["language-chinese"].tap()
        app.buttons["language-continue"].tap()
        XCTAssertTrue(app.tabBars.buttons["我的卡片"].waitForExistence(timeout: 5))
        app.terminate()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
        let start = app.buttons["start-exploring"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        XCTAssertEqual(start.label, "开始探索", "Explicit choice overrides the device language after relaunch.")
        XCTAssertFalse(app.buttons["language-continue"].exists)
        app.tabBars.buttons["我的卡片"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("4 张卡片"))
        app.tabBars.buttons["聊天"].tap()
        app.buttons["choose-language"].tap()
        app.buttons["language-english"].tap()
        app.buttons["language-continue"].tap()
        XCTAssertTrue(app.tabBars.buttons["Collection"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("4 discoveries"))
    }

    func testTripMemorySharePreviewAndEdit() {
        let trip = app.buttons["trip-10000000-0000-4000-8000-000000000001"]
        scrollTo(trip); trip.tap()
        scrollTo(app.buttons["make-memory"]); app.buttons["make-memory"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        scrollTo(app.buttons["share-trip"]); app.buttons["share-trip"].tap()
        XCTAssertTrue(app.switches["Include a first name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.switches["Include a first name"].value as? String, "0")
        XCTAssertEqual(app.switches["Include the city"].value as? String, "0")
        capture("share-preview")
        scrollTo(app.buttons["create-share"]); app.buttons["create-share"].tap()
        XCTAssertTrue(app.staticTexts["share-error"].waitForExistence(timeout: 5))
        capture("share-error")
        XCTAssertFalse(app.buttons["Family sharing settings"].exists)
        XCTAssertFalse(app.secureTextFields["Family owner key"].exists)
        app.buttons["Done"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Collection"].tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Tiny ocean homes")).firstMatch.tap()
        scrollTo(app.buttons["Add to my story"]); app.buttons["Add to my story"].tap()
        let editor = app.textViews["edit-observation"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5)); editor.tap(); editor.typeText(" And a tiny ridge.")
        app.buttons["Save"].tap()
        for _ in 0..<5 { app.swipeDown() }
        app.buttons["discovery-card"].tap()
        XCTAssertTrue(app.staticTexts["card-observation"].label.contains("And a tiny ridge."))
    }

    func testLargeTextKeepsCoreActionsReachable() {
        app.terminate()
        app.launchArguments = ["--ui-testing", "--reset-journal", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        dismissAccountReminder()
        scrollTo(app.buttons["start-exploring"])
        let action = app.buttons["start-exploring"]
        XCTAssertGreaterThanOrEqual(action.frame.width, 44)
        XCTAssertGreaterThanOrEqual(action.frame.height, 44)
        action.tap()
        scrollTo(app.buttons["speak-button"])
        XCTAssertGreaterThanOrEqual(app.buttons["speak-button"].frame.height, 44)
        capture("large-text-voice")
        app.buttons["Close"].tap()
        app.tabBars.buttons["Collection"].tap()
        let find = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Tiny ocean homes")).firstMatch
        scrollTo(find); find.tap()
        scrollTo(app.buttons["discovery-card"]); app.buttons["discovery-card"].tap()
        XCTAssertTrue(app.staticTexts["card-observation"].exists)
    }

    func testEmptyCollectionOffersAnExplorationEntry() {
        app.terminate()
        app.launchArguments = ["--ui-testing", "--reset-journal", "--empty-journal"]
        app.launch()
        app.tabBars.buttons["Collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("0 discoveries"))
        scrollTo(app.buttons["Find another wonder"])
        capture("empty-collection")
        app.buttons["Find another wonder"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 5))
    }

    func testLiveSharingCreatesAURLThatCanBeReadAndRevoked() throws {
        guard ProcessInfo.processInfo.environment["POCKET_RUN_LIVE_SHARE"] == "1" else { throw XCTSkip("Start the isolated local sharing test server to run this integration.") }
        let baseURL = ProcessInfo.processInfo.environment["POCKET_SHARE_BASE_URL"] ?? "http://127.0.0.1:4176"
        app.terminate()
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = baseURL
        app.launchArguments.removeAll { $0 == "--reset-language" }
        app.launch()
        let trip = app.buttons["trip-10000000-0000-4000-8000-000000000001"]
        scrollTo(trip); trip.tap()
        scrollTo(app.buttons["share-trip"]); app.buttons["share-trip"].tap()
        XCTAssertFalse(app.buttons["Family sharing settings"].exists)
        XCTAssertFalse(app.secureTextFields["Family owner key"].exists)
        XCTAssertTrue(app.buttons["create-share"].isHittable)
        scrollTo(app.buttons["create-share"]); app.buttons["create-share"].tap()
        let created = app.staticTexts["share-url"].waitForExistence(timeout: 20)
        capture("cloudflare-sharing")
        XCTAssertTrue(created, app.staticTexts["share-error"].exists ? app.staticTexts["share-error"].label : "No sharing URL appeared.")
        let url = URL(string: app.staticTexts["share-url"].label)!
        let token = url.lastPathComponent
        let freshRead = expectation(description: "Independent public read")
        URLSession.shared.dataTask(with: URL(string: baseURL + "/api/shares/" + token)!) { data, response, error in
            XCTAssertNil(error); XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            let object = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
            XCTAssertEqual(object?["title"] as? String, "The day we met the ducks")
            XCTAssertNil(object?["firstName"]); XCTAssertNil(object?["city"])
            freshRead.fulfill()
        }.resume()
        wait(for: [freshRead], timeout: 10)
        let attachment = XCTAttachment(string: url.absoluteString); attachment.name = "app-created-sharing-url"; attachment.lifetime = .keepAlways; add(attachment)
        app.terminate()
        app.launchArguments.removeAll { $0 == "--reset-journal" }
        app.launch()
        scrollTo(trip); trip.tap()
        scrollTo(app.buttons["share-trip"]); app.buttons["share-trip"].tap()
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["share-url"].label, url.absoluteString)
        scrollTo(app.buttons["Copy link"]); app.buttons["Copy link"].tap()
        XCTAssertEqual(app.staticTexts["share-message"].label, "Link copied.")
        scrollTo(app.buttons["Stop sharing this story"]); app.buttons["Stop sharing this story"].tap()
        let stopped = expectation(for: NSPredicate(format: "label == %@", "This link is no longer shared."), evaluatedWith: app.staticTexts["share-message"])
        wait(for: [stopped], timeout: 15)
        let revoked = expectation(description: "Independent revoked read")
        URLSession.shared.dataTask(with: URL(string: baseURL + "/api/shares/" + token)!) { _, response, _ in
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 410); revoked.fulfill()
        }.resume()
        wait(for: [revoked], timeout: 10)
    }

    func testMapMarkerOpensItsMatchingAdventure() {
        let marker = app.buttons["Open The day we met the ducks in Sydney"]
        capture("map-before-selection")
        for _ in 0..<4 {
            if marker.isHittable { break }
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.06, dy: 0.70))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.06, dy: 0.42)), withVelocity: .slow, thenHoldForDuration: 0.1)
        }
        capture("map-ready-for-selection")
        XCTAssertTrue(marker.isHittable)
        marker.tap()
        XCTAssertTrue(app.navigationBars["My adventure"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["The day we met the ducks"].exists)
        XCTAssertTrue(app.staticTexts["Sydney"].exists || app.staticTexts["SYDNEY"].exists)
    }

    func testSystemReducedMotionKeepsCardReadable() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        func row(_ label: String) -> XCUIElement {
            settings.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch
        }
        let reduce = settings.switches["Reduce Motion"]
        if !reduce.exists {
            let accessibility = row("Accessibility")
            for _ in 0..<6 { if accessibility.isHittable { break }; settings.swipeUp() }
            XCTAssertTrue(accessibility.isHittable); accessibility.tap()
            let motion = row("Motion")
            for _ in 0..<4 { if motion.isHittable { break }; settings.swipeUp() }
            XCTAssertTrue(motion.isHittable); motion.tap()
        }
        XCTAssertTrue(reduce.waitForExistence(timeout: 5))
        let wasEnabled = reduce.value as? String == "1"
        if !wasEnabled { reduce.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap() }
        let enabled = expectation(for: NSPredicate(format: "value == '1'"), evaluatedWith: reduce)
        wait(for: [enabled], timeout: 5)
        app.terminate()
        app.launchArguments.removeAll { $0 == "--reset-language" }
        app.launch()
        XCTAssertTrue(app.buttons["start-exploring"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 5))
        let find = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Tiny ocean homes")).firstMatch
        scrollTo(find); find.tap()
        scrollTo(app.buttons["discovery-card"]); app.buttons["discovery-card"].tap()
        XCTAssertTrue(app.staticTexts["card-observation"].exists)
        capture("reduced-motion-card")
        if !wasEnabled { settings.activate(); reduce.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap(); app.activate() }
    }

    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<8 {
            dismissAccountReminder()
            if element.isHittable { return }
            app.swipeUp()
        }
        if !element.isHittable {
            capture("unreachable-control")
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "unreachable-control-hierarchy"; hierarchy.lifetime = .keepAlways; add(hierarchy)
        }
        XCTAssertTrue(element.isHittable, "Control remains reachable")
    }
    private func continueToObservation() {
        let next = app.buttons["stop-reply"]
        if next.waitForExistence(timeout: 3) { next.tap() }
        let status = app.staticTexts["exploration-status"]
        let ready = expectation(for: NSPredicate(format: "label == %@ OR label == %@", "Notice one thing, then make it into your card.", "记录一件新发现，把它变成自己的卡片。"), evaluatedWith: status)
        wait(for: [ready], timeout: 10)
    }
    private func revealEarnedCard() {
        let reveal = app.buttons["reveal-card"]
        XCTAssertTrue(reveal.waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["card-unlock-stage"].exists)
        reveal.tap()
    }
    private func dismissAccountReminder() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let later = springboard.buttons["Not Now"]
        if later.exists { later.tap() }
        let passwordService = XCUIApplication(bundleIdentifier: "com.apple.SafariViewService")
        let passwordReminder = passwordService.buttons["Not Now"]
        if passwordReminder.exists { passwordReminder.tap() }
        let localReminder = app.alerts.buttons["Not Now"]
        if localReminder.exists { localReminder.tap() }
    }
    private func capture(_ name: String) {
        dismissAccountReminder()
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways
        add(attachment)
    }
}
