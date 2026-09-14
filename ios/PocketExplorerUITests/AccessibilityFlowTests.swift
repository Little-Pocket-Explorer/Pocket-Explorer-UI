import XCTest

final class AccessibilityFlowTests: XCTestCase {
    private let app = XCUIApplication()

    func testEnglishHomeAccessibility() throws {
        launch(language: "en", large: false)
        capture("english-home-audit")
        try audit()
    }

    func testMemoriesTabKeepsChapterNavigationAndCanReturnToTheList() throws {
        launch(language: "en", large: false)
        app.tabBars.buttons["Memories"].tap()
        let memory = app.buttons["memory-10000000-0000-4000-8000-000000000001"]
        scrollTo(memory)
        capture("memories-tab-list")
        memory.tap()
        let chapter = app.staticTexts["memory-chapter"]
        XCTAssertTrue(chapter.waitForExistence(timeout: 6))
        XCTAssertEqual(chapter.value as? String, "Chapter 1 of 6")
        let firstText = chapter.label
        app.buttons["Next chapter"].tap()
        XCTAssertEqual(chapter.value as? String, "Chapter 2 of 6")
        XCTAssertNotEqual(chapter.label, firstText)
        app.buttons["Previous chapter"].tap()
        XCTAssertEqual(chapter.label, firstText)
        capture("memories-tab-player")
        let back = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(back.isHittable)
        back.tap()
        XCTAssertTrue(memory.waitForExistence(timeout: 6))
        memory.tap()
        XCTAssertEqual(chapter.value as? String, "Chapter 1 of 6")
        try audit()
    }

    func testArabicHomeKeepsRoomForExplorationAtLargestText() throws {
        launch(language: "ar", large: true)
        capture("arabic-home-reading-space")
        XCTAssertLessThan(app.buttons["home-question"].frame.height, app.frame.height * 0.22,
                          "The fixed composer must leave useful space for the exploration content.")
        for identifier in ["home-camera", "home-question", "home-ask"] {
            let button = app.buttons[identifier]
            XCTAssertTrue(button.isHittable)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
            XCTAssertFalse(button.label.isEmpty)
        }
        try audit()
        app.buttons["home-question"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 6))
    }

    func testArabicCollectionKeepsReadableCardsAtLargestText() throws {
        launch(language: "ar", large: true)
        app.tabBars.buttons["الخريطة"].tap()
        app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 6))
        capture("arabic-collection-reading-space")
        try audit()
        let card = app.buttons["collection-card-20000000-0000-4000-8000-000000000004"]
        scrollTo(card)
        capture("arabic-collection-card-reading-space")
        XCTAssertGreaterThan(card.frame.width, app.frame.width * 0.75,
                             "At accessibility sizes a two-column card leaves too little width for readable text.")
        card.tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 6))
    }

    func testArabicMemoryKeepsPlaybackReadableAtLargestText() throws {
        launch(language: "ar", large: true)
        app.tabBars.buttons["الخريطة"].tap()
        let trip = app.buttons["trip-10000000-0000-4000-8000-000000000001"]
        scrollTo(trip); trip.tap()
        scrollTo(app.buttons["make-memory"]); app.buttons["make-memory"].tap()
        let play = app.buttons["memory-play-pause"]
        XCTAssertTrue(play.waitForExistence(timeout: 6))
        capture("arabic-memory-controls-reading-space")
        XCTAssertLessThan(play.frame.height, 115, "Playback text must not be squeezed into a narrow multi-line capsule.")
        try audit()
        play.tap(); play.tap()
        app.buttons["memory-replay"].tap(); play.tap()
    }

    private func launch(language: String, large: Bool) {
        continueAfterFailure = true
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(\(language))", "-AppleLocale", language]
        if large { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = "http://127.0.0.1:4197"
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        XCTAssertTrue(app.buttons["home-question"].waitForExistence(timeout: 10))
    }

    private func audit() throws {
        try app.performAccessibilityAudit(for: [.contrast, .hitRegion, .sufficientElementDescription, .textClipped]) { issue in
            let details = XCTAttachment(string: "\(issue.auditType.rawValue): \(issue.compactDescription)\n\(issue.detailedDescription)\n\(issue.element?.debugDescription ?? "No associated element")")
            details.name = issue.auditType == .contrast ? "contrast-pixel-review" : "accessibility-issue"
            details.lifetime = .keepAlways; self.add(details)
            // The contrast audit also samples labels occluded by system scroll overlays.
            // Preserve those findings for screenshot/pixel review instead of discarding them.
            return issue.auditType == .contrast
        }
    }

    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<18 where !element.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(element.isHittable)
    }

    private func capture(_ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name; screenshot.lifetime = .keepAlways; add(screenshot)
    }
}
