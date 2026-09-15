import XCTest

final class ShareReentryFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let base = ProcessInfo.processInfo.environment["POCKET_SHARE_FIXTURE_URL"] ?? "http://127.0.0.1:4201"

    func testFrenchRevocationRemainsVisibleAtTheLargestTextSize() throws {
        continueAfterFailure = false
        _ = try fixture("reset")
        defer { _ = try? fixture("reset") }
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR",
                               "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.tabBars.buttons["Carte"].tap()
        let trip = app.buttons["trip-10000000-0000-4000-8000-000000000001"]
        scrollTo(trip); trip.tap()
        let share = app.buttons["share-trip"]
        scrollTo(share); share.tap()
        app.buttons["create-share"].tap()
        _ = try fixture("release")
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 5))
        _ = try fixture("hold-revocation")
        let revoke = app.buttons["revoke-share"]
        scrollInSheet(to: revoke)
        capture("french-maximum-text-published")
        try app.performAccessibilityAudit(for: .textClipped) { issue in
            !["revoke-share", "share-message"].contains(issue.element?.identifier ?? "")
        }
        scrollInSheet(to: revoke)
        XCTAssertTrue(revoke.isHittable)
        XCTAssertLessThan(revoke.frame.maxY, app.frame.maxY)
        revoke.tap()
        capture("french-maximum-text-revoking")
        let progress = app.staticTexts["Arrêt du partage…"]
        XCTAssertTrue(progress.waitForExistence(timeout: 3))
        XCTAssertGreaterThan(progress.frame.minY, app.navigationBars.firstMatch.frame.maxY)
        XCTAssertLessThan(progress.frame.maxY, app.frame.maxY)
        XCTAssertFalse(revoke.isEnabled)
        _ = try fixture("release")
        let removed = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.staticTexts["share-url"])
        wait(for: [removed], timeout: 5)
        XCTAssertTrue(app.buttons["create-share"].isHittable)
        capture("french-maximum-text-revoked")
    }

    func testReopeningARevokingShareWaitsAndRemovesTheUnavailableLink() throws {
        continueAfterFailure = true
        _ = try fixture("reset")
        defer { _ = try? fixture("reset") }
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.tabBars.buttons["Map"].tap()
        app.buttons["trip-10000000-0000-4000-8000-000000000001"].tap()
        let share = app.buttons["share-trip"]
        for _ in 0..<6 where !share.isHittable { app.swipeUp(velocity: .slow) }
        share.tap(); app.buttons["create-share"].tap()
        XCTAssertEqual(try fixture("status")["creates"] as? Int, 1)
        _ = try fixture("release")
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 5))
        _ = try fixture("hold-revocation")
        app.buttons["revoke-share"].tap()
        XCTAssertEqual(try fixture("status")["revokes"] as? Int, 1)
        app.buttons["Done"].tap(); share.tap()
        XCTAssertTrue(app.buttons["revoke-share"].waitForExistence(timeout: 5))
        capture("share-reopened-while-revoking")
        XCTAssertTrue(app.staticTexts["Stopping sharing…"].exists)
        XCTAssertFalse(app.buttons["revoke-share"].isEnabled)
        XCTAssertFalse(app.buttons["Share my adventure"].isEnabled, "A link being revoked should not still be offered for sharing.")
        _ = try fixture("release")
        let removed = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.staticTexts["share-url"])
        wait(for: [removed], timeout: 5)
        XCTAssertEqual(try fixture("status")["active"] as? Int, 0)
        capture("revoked-link-removed-after-reentry")
    }

    func testClosingAndReopeningAPendingShareKeepsOneRequestAndOneRevocableLink() throws {
        continueAfterFailure = true
        _ = try fixture("reset")
        defer { _ = try? fixture("reset") }
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        app.tabBars.buttons["Map"].tap()
        app.buttons["trip-10000000-0000-4000-8000-000000000001"].tap()
        let share = app.buttons["share-trip"]
        for _ in 0..<6 where !share.isHittable { app.swipeUp(velocity: .slow) }
        share.tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 5))
        app.switches["Include a first name"].tap()
        app.textFields["First name"].tap(); app.textFields["First name"].typeText("Ari")
        app.buttons["create-share"].tap()
        XCTAssertEqual(try fixture("status")["creates"] as? Int, 1)
        app.buttons["Done"].tap()
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        share.tap()
        let create = app.buttons["create-share"]
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        capture("share-reopened-while-pending")
        XCTAssertFalse(create.isEnabled, "Reopening must retain the existing request instead of offering another public link.")
        XCTAssertTrue(app.staticTexts["Explored by Ari"].exists, "The pending preview must retain the exact snapshot being published.")
        if create.isEnabled { create.tap() }
        _ = try fixture("release")
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 5))
        let status = try fixture("status")
        XCTAssertEqual(status["creates"] as? Int, 1)
        XCTAssertEqual(status["active"] as? Int, 1, "A second untracked share must not remain available.")
        capture("one-completed-share-after-reentry")
        app.buttons["revoke-share"].tap()
        let revoked = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.staticTexts["share-url"])
        wait(for: [revoked], timeout: 5)
        XCTAssertEqual(try fixture("status")["active"] as? Int, 0)
    }

    private func fixture(_ command: String) throws -> [String: Any] {
        let complete = expectation(description: command)
        var output: [String: Any]?
        var failure: Error?
        URLSession.shared.dataTask(with: URL(string: "\(base)/__fixture/\(command)")!) { data, response, error in
            failure = error
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            output = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
            complete.fulfill()
        }.resume()
        wait(for: [complete], timeout: 5)
        if let failure { throw failure }
        return try XCTUnwrap(output)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }

    private func scrollInSheet(to element: XCUIElement) {
        let top = app.navigationBars.firstMatch.frame.maxY + 12
        let bottom = app.frame.maxY - 20
        for _ in 0..<18 {
            let frame = element.frame
            if element.isHittable && frame.minY >= top && frame.maxY <= bottom { break }
            let delta = max(-220, min(220, (top + bottom) / 2 - frame.midY))
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 0, dy: delta)))
        }
        XCTAssertTrue(element.isHittable)
        XCTAssertGreaterThan(element.frame.minY, top)
        XCTAssertLessThan(element.frame.maxY, bottom)
    }

    private func scrollTo(_ element: XCUIElement) {
        let navigation = app.navigationBars.firstMatch
        let top = navigation.exists ? navigation.frame.maxY + 12 : 40
        let bottom = app.tabBars.firstMatch.frame.minY - 12
        for _ in 0..<18 {
            let frame = element.frame
            let fits = frame.height <= bottom - top
            if element.isHittable && (fits ? frame.minY >= top && frame.maxY <= bottom : frame.midY > top && frame.midY < bottom) { break }
            let delta = max(-220, min(220, (top + bottom) / 2 - frame.midY))
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 0, dy: delta)))
        }
        XCTAssertTrue(element.isHittable)
        XCTAssertGreaterThan(element.frame.midY, top)
        XCTAssertLessThan(element.frame.midY, bottom)
    }
}
