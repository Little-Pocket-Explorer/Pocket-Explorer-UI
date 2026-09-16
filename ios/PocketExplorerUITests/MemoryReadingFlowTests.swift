import XCTest

final class MemoryReadingFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let tripID = "10000000-0000-4000-8000-000000000091"
    private let question = "Why do shadows change?"
    private let observation = String(repeating: "I watched the shadow beside the tree. It stretched across the path as the sun moved lower. ", count: 4).trimmingCharacters(in: .whitespaces)
    private let explanation = "A shadow is a place where an object blocks light."

    func testLongMemoryKeepsReadingTimeAndCanBePaused() throws {
        try openMemory()
        app.buttons["Next chapter"].tap()
        let chapter = app.staticTexts["memory-chapter"]
        XCTAssertEqual(chapter.label, observation)
        let play = app.buttons["memory-play-pause"]
        play.tap()
        let delay = expectation(description: "Read the first few lines")
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { delay.fulfill() }
        wait(for: [delay], timeout: 8)
        capture("long-memory-after-six-seconds")
        XCTAssertEqual(chapter.label, observation)
        XCTAssertTrue(play.isHittable)
        play.tap()
        XCTAssertTrue(play.label.contains("Play"))
    }

    func testNextAndReplayRevealTheOpening() throws { try exerciseNavigation(large: false) }
    func testNextAndReplayRevealTheOpeningAtMaximumText() throws { try exerciseNavigation(large: true) }

    func testPausePreservesReadingPositionAndReplayRevealsTheSameChapterOpening() throws {
        let longQuestion = observation + " Why does this happen?"
        try openMemory(large: true, firstQuestion: longQuestion)
        let chapter = app.staticTexts["memory-chapter"]
        let play = app.buttons["memory-play-pause"]
        play.tap()
        for _ in 0..<6 {
            if chapter.frame.minY < 40 { break }
            app.swipeUp(velocity: .fast)
        }
        let position = chapter.frame.minY
        XCTAssertLessThan(position, 40)
        play.tap()
        XCTAssertEqual(chapter.frame.minY, position, accuracy: 1)
        play.tap()
        XCTAssertEqual(chapter.frame.minY, position, accuracy: 1)
        app.buttons["memory-replay"].tap()
        XCTAssertEqual(chapter.label, longQuestion)
        XCTAssertEqual(chapter.value as? String, "Chapter 1 of 3")
        assertOpeningIsVisible(chapter)
        capture("replay-same-long-chapter")
        play.tap()
        let sharing = app.buttons["memory-share-preview"]
        XCTAssertTrue(sharing.isHittable)
        sharing.tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["navigation-home"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["Map"].isHittable)
        capture("memory-toolbar-share-at-maximum-text")
        app.navigationBars.buttons["BackButton"].tap()
        XCTAssertTrue(chapter.waitForExistence(timeout: 5))
        XCTAssertEqual(chapter.label, longQuestion)
    }

    private func exerciseNavigation(large: Bool) throws {
        try openMemory(large: large)
        let chapter = app.staticTexts["memory-chapter"]
        app.buttons["Next chapter"].tap()
        XCTAssertEqual(chapter.label, observation)
        for _ in 0..<16 {
            if chapter.frame.maxY < app.buttons["memory-play-pause"].frame.minY - 4 { break }
            app.swipeUp(velocity: .fast)
        }
        capture("long-memory-bottom-\(large ? "large" : "normal")")
        app.buttons["Next chapter"].tap()
        XCTAssertEqual(chapter.label, explanation)
        capture("memory-next-opening-\(large ? "large" : "normal")")
        assertOpeningIsVisible(chapter)
        app.buttons["memory-replay"].tap()
        XCTAssertEqual(chapter.label, question)
        capture("memory-replay-opening-\(large ? "large" : "normal")")
        assertOpeningIsVisible(chapter)
        app.buttons["memory-play-pause"].tap()
    }

    private func assertOpeningIsVisible(_ chapter: XCUIElement) {
        let navigation = app.navigationBars.firstMatch
        let top = navigation.exists ? navigation.frame.maxY : 40
        XCTAssertGreaterThanOrEqual(chapter.frame.minY, top - 1)
        XCTAssertLessThan(chapter.frame.minY, app.buttons["memory-play-pause"].frame.minY)
    }

    private func openMemory(large: Bool = false, firstQuestion: String? = nil) throws {
        continueAfterFailure = false
        let discoveryID = "20000000-0000-4000-8000-000000000091"
        let titles = ["It started with a why.", "Then I looked closer.", "A little discovery, kept."]
        let texts = [firstQuestion ?? question, observation, explanation]
        let chapters: [[String: Any]] = ["question", "observation", "discovery"].enumerated().map { index, suffix in
            ["id": discoveryID + "-" + suffix, "title": titles[index], "text": texts[index], "subject": "leaf", "language": "en"]
        }
        let trip: [String: Any] = ["id": tripID, "title": "Looking at light", "startedAt": 800000000, "completedAt": 800000001, "isExample": true, "memory": ["id": tripID, "chapters": chapters], "language": "en"]
        let discovery: [String: Any] = ["id": discoveryID, "tripID": tripID, "subject": "leaf", "question": firstQuestion ?? question, "observation": observation, "explanation": explanation, "createdAt": 800000000, "language": "en"]
        let journal: [String: Any] = ["version": 1, "trips": [trip], "discoveries": [discovery]]
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        if large { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launchEnvironment["POCKET_TEST_JOURNAL"] = String(data: try JSONSerialization.data(withJSONObject: journal), encoding: .utf8)
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.tabBars.buttons["Map"].tap()
        let trip = app.buttons["trip-\(tripID)"]
        XCTAssertTrue(trip.waitForExistence(timeout: 8))
        if !trip.isHittable { app.swipeUp() }
        trip.tap()
        let memory = app.buttons["make-memory"]
        if !memory.isHittable { app.swipeUp() }
        memory.tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 8))
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
