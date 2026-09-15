import XCTest
import UIKit

final class MiroFlowTests: XCTestCase {
    private let app = XCUIApplication()
    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = FixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
    }

    func testMiroHomeAndMapCollectionHaveVisiblePrimaryActions() {
        let ask = app.buttons["home-ask"]
        XCTAssertTrue(ask.waitForExistence(timeout: 15))
        XCTAssertTrue(ask.isHittable)
        XCTAssertGreaterThanOrEqual(ask.frame.width, 44)
        XCTAssertGreaterThanOrEqual(ask.frame.height, 44)
        XCTAssertGreaterThanOrEqual(app.buttons["open-profile"].frame.width, 44)
        XCTAssertGreaterThanOrEqual(app.buttons["open-profile"].frame.height, 44)
        capture("miro-home-en")
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.buttons["open-collection"].waitForExistence(timeout: 10))
        capture("miro-map")
        app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 5))
        capture("miro-collection")
        let cards = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "collection-card-")).allElementsBoundByIndex
        XCTAssertGreaterThanOrEqual(cards.count, 2)
        let first = cards[0].frame, second = cards[1].frame
        let bounds = XCTAttachment(string: "First card: \(first), second card: \(second), window: \(app.frame)")
        bounds.name = "collection-card-bounds"; bounds.lifetime = .keepAlways; add(bounds)
        XCTAssertGreaterThanOrEqual(first.minX, app.frame.minX + 15)
        XCTAssertLessThanOrEqual(second.maxX, app.frame.maxX - 15)
        XCTAssertGreaterThanOrEqual(second.minX - first.maxX, 10, "Filled artwork must stay inside its grid column.")
        XCTAssertEqual(first.height, second.height, accuracy: 1)
    }

    func testLiveContractQuestionCardImageMemoryAndShareJourney() {
        if ProcessInfo.processInfo.environment["POCKET_EXPECT_REDUCED_MOTION"] == "1" {
            XCTAssertTrue(UIAccessibility.isReduceMotionEnabled, "The simulator must have the actual system setting enabled.")
        }
        app.buttons["home-question"].tap()
        let input = field("exploration-input")
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap(); input.typeText("Why is the sky blue?")
        app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 12))
        XCTAssertTrue(app.buttons["save-discovery"].isHittable, "Saving the answer must not require scrolling.")
        capture("miro-live-answer")
        scrollTo(app.buttons["save-discovery"])
        app.buttons["save-discovery"].tap()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
        capture("miro-card-reveal")
        scrollTo(app.buttons["reveal-card"]); app.buttons["reveal-card"].tap()
        XCTAssertTrue(app.buttons["discovery-card"].waitForExistence(timeout: 8))
        capture("miro-card-detail")
        app.buttons["discovery-card"].tap()
        XCTAssertTrue(app.staticTexts["card-observation"].exists)
        app.buttons["discovery-card"].tap()
        scrollTo(app.buttons["new-card-memory"]); app.buttons["new-card-memory"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 8))
        capture("miro-memory")
        scrollTo(app.buttons["memory-share-preview"]); app.buttons["memory-share-preview"].tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 8))
        app.buttons["create-share"].tap()
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 10))
        let url = app.staticTexts["share-url"].label
        let read = expectation(description: "Independent generated story read")
        URLSession.shared.dataTask(with: URL(string: (FixtureServer.base + "/api/shares/") + URL(string: url)!.lastPathComponent)!) { data, response, error in
            XCTAssertNil(error); XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            let object = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
            let cards = object?["cards"] as? [[String: Any]]
            XCTAssertEqual(cards?.first?["title"] as? String, "Blue sky")
            XCTAssertNotNil(cards?.first?["artworkID"])
            read.fulfill()
        }.resume()
        wait(for: [read], timeout: 10)
        capture("miro-share-preview")
        app.terminate()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
        app.tabBars.buttons["Map"].tap(); app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["journal-count"].label.contains("Discoveries: 5"))
    }

    func testFailedQuestionRemainsInTheHistoryAfterRelaunch() {
        app.buttons["home-question"].tap()
        let input = field("exploration-input")
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap(); input.typeText("network failure question")
        app.buttons["ask-button"].tap()
        XCTAssertTrue(app.staticTexts["exploration-error"].waitForExistence(timeout: 10))
        XCTAssertEqual(input.value as? String, "network failure question")
        capture("miro-network-error")
        app.terminate()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launch()
        XCTAssertTrue(app.buttons["question-history"].waitForExistence(timeout: 10))
        app.buttons["question-history"].tap()
        XCTAssertTrue(app.staticTexts["network failure question"].waitForExistence(timeout: 5))
    }

    private func field(_ id: String) -> XCUIElement {
        if app.textViews[id].exists { return app.textViews[id] }
        return app.textFields[id]
    }
    private func scrollTo(_ element: XCUIElement) {
        for _ in 0..<7 where !element.isHittable { app.swipeUp(velocity: .slow) }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
