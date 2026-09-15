import XCTest

final class DailyDiscoveryFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let base = FixtureServer.base

    override func setUpWithError() throws {
        continueAfterFailure = false
        _ = try request(base + "/__fixture/daily/reset")
    }

    override func tearDownWithError() throws {
        app.terminate()
        _ = try request(base + "/__fixture/daily/reset")
    }

    func testDownloadedRevisionWaitsForTheNextDayAndKeepsLanguageSnapshots() throws {
        let now = Date().timeIntervalSince1970
        launch(reset: true, language: "en", time: now)
        let original = identifiers()
        XCTAssertEqual(original.count, 3)
        _ = try request(base + "/__fixture/daily/revise")
        launch(reset: false, language: "en", time: now, refresh: true)
        XCTAssertEqual(identifiers(), original)
        capture("daily-refreshed-bank-stable-today")
        launch(reset: false, language: "fr", time: now, resetLanguage: true)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Pourquoi")).firstMatch.waitForExistence(timeout: 10))
        capture("daily-french-context")
        launch(reset: false, language: "en", time: now, resetLanguage: true)
        XCTAssertEqual(identifiers(), original)
        launch(reset: false, language: "en", time: now + 90000)
        let next = identifiers()
        XCTAssertEqual(next.count, 3)
        XCTAssertTrue(next.allSatisfy { $0.hasPrefix("daily-question-new-") })
        XCTAssertTrue(Set(next).isDisjoint(with: original))
        capture("daily-next-day-activation")
    }

    func testKnownWithdrawalRemovesOnlyTheAffectedQuestionWithoutReplacement() throws {
        let now = Date().timeIntervalSince1970
        launch(reset: true, language: "en", time: now)
        let original = identifiers()
        let removed = try XCTUnwrap(original.first)
        let topic = removed.replacingOccurrences(of: "daily-question-", with: "")
        app.buttons[removed].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 2))
        app.buttons["save-discovery"].tap()
        app.unlockSavedObservation()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
        _ = try request(base + "/__fixture/daily/withdraw?topic=" + topic)
        launch(reset: false, language: "en", time: now, refresh: true)
        let questions = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-"))
        let settled = expectation(for: NSPredicate(format: "count == 2"), evaluatedWith: questions)
        wait(for: [settled], timeout: 10)
        XCTAssertEqual(identifiers(), original.filter { $0 != removed })
        capture("daily-withdrawal-two-questions")
        app.tabBars.buttons["Map"].tap()
        app.buttons["open-collection"].tap()
        let card = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "collection-card-")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 8)); card.tap()
        XCTAssertTrue(app.otherElements["prepared-update-notice"].waitForExistence(timeout: 3) || app.staticTexts["prepared-update-notice"].exists)
        capture("daily-collected-withdrawal-notice")
    }

    func testBackgroundEntryDownloadsARevisionWithoutReplacingTodaysQuestions() throws {
        let time = Date().timeIntervalSince1970 - 25200
        launch(reset: true, language: "en", time: time, simulateBackground: true)
        let original = identifiers()
        let before = try XCTUnwrap(request(base + "/__fixture/daily/status")["dailyCatalogReads"] as? Int)
        _ = try request(base + "/__fixture/daily/revise")
        XCUIDevice.shared.press(.home)
        let deadline = Date().addingTimeInterval(10)
        var reads = before
        while reads == before && Date() < deadline {
            reads = try XCTUnwrap(request(base + "/__fixture/daily/status")["dailyCatalogReads"] as? Int)
            if reads == before { RunLoop.current.run(until: Date().addingTimeInterval(0.2)) }
        }
        XCTAssertGreaterThan(reads, before)
        app.activate()
        XCTAssertTrue(app.buttons[try XCTUnwrap(original.first)].waitForExistence(timeout: 10))
        XCTAssertEqual(identifiers(), original)
        capture("daily-background-refresh-stable-today")
        _ = try request(base + "/__fixture/daily/offline")
        launch(reset: false, language: "en", time: time + 90000)
        XCTAssertEqual(identifiers().count, 3)
        XCTAssertTrue(identifiers().allSatisfy { $0.hasPrefix("daily-question-new-") })
    }

    func testFreshInstallationReadsRealBundledDiscoveriesOfflineInThreeScripts() throws {
        _ = try request(base + "/__fixture/daily/offline")
        let before = try request(base + "/__fixture/daily/status")
        for language in ["en", "zh-Hans", "ar"] {
            app.terminate()
            app.launchArguments = ["--ui-testing", "--bundled-discoveries", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(\(language))", "-AppleLocale", language]
            app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
            app.launchEnvironment.removeValue(forKey: "POCKET_TEST_DISCOVERY_TIME")
            app.launch()
            XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
            app.buttons["language-continue"].tap()
            let question = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-")).firstMatch
            XCTAssertTrue(question.waitForExistence(timeout: 5))
            XCTAssertEqual(identifiers().count, 3)
            capture("bundled-\(language)-home")
            for _ in 0..<4 where !question.isHittable { app.swipeUp() }
            question.tap()
            XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 2))
            capture("bundled-\(language)-answer")
            app.buttons["save-discovery"].tap()
            XCTAssertTrue(app.buttons["pending-quiz"].waitForExistence(timeout: 8))
            capture("bundled-\(language)-real-artwork")
        }
        let after = try request(base + "/__fixture/daily/status")
        XCTAssertEqual(after["generatedQuestions"] as? Int, before["generatedQuestions"] as? Int)
        XCTAssertEqual(after["generatedArtwork"] as? Int, before["generatedArtwork"] as? Int)
    }

    func testCachedPreparedAnswerAndCardRemainUsableDuringNetworkFailure() throws {
        let now = Date().timeIntervalSince1970
        launch(reset: true, language: "en", time: now)
        let original = identifiers()
        let question = app.buttons[try XCTUnwrap(original.first)]
        question.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 2))
        app.buttons["save-discovery"].tap()
        app.unlockSavedObservation()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
        _ = try request(base + "/__fixture/daily/offline")
        launch(reset: false, language: "en", time: now, refresh: true)
        XCTAssertEqual(identifiers(), original)
        app.buttons[original[1]].tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.otherElements["thinking"].exists)
        capture("daily-offline-cached-answer")
        app.buttons["save-discovery"].tap()
        app.unlockSavedObservation()
        XCTAssertTrue(app.buttons["reveal-card"].waitForExistence(timeout: 8))
        app.buttons["reveal-card"].tap()
        capture("daily-offline-cached-card")
    }

    private func launch(reset: Bool, language: String, time: TimeInterval, refresh: Bool = false, resetLanguage: Bool = false, simulateBackground: Bool = false) {
        app.terminate()
        app.launchArguments = ["--ui-testing", "--empty-journal", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "fr" ? "fr_FR" : "en_AU"]
        if reset { app.launchArguments += ["--reset-journal"] }
        if reset || resetLanguage { app.launchArguments += ["--reset-language"] }
        if refresh { app.launchArguments += ["--refresh-discoveries"] }
        if simulateBackground { app.launchArguments += ["--simulate-discovery-refresh"] }
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launchEnvironment["POCKET_TEST_DISCOVERY_TIME"] = String(time)
        app.launch()
        if reset || resetLanguage {
            XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
            app.buttons["language-continue"].tap()
        }
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-")).firstMatch.waitForExistence(timeout: 10))
    }

    private func identifiers() -> [String] {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-")).allElementsBoundByIndex.map(\.identifier)
    }

    func testPreparedAnswerCardAndSharingPersistWithoutGenerationOrDailyReshuffle() throws {
        continueAfterFailure = false
        let before = try request(base + "/__fixture/daily/status")
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        app.buttons["language-continue"].tap()
        let questions = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "daily-question-"))
        XCTAssertTrue(questions.firstMatch.waitForExistence(timeout: 10))
        let identifiers = questions.allElementsBoundByIndex.map(\.identifier)
        XCTAssertEqual(identifiers.count, 3)
        let question = questions.firstMatch
        for _ in 0..<4 where !question.isHittable { app.swipeUp() }
        capture("daily-stable-home")
        question.tap()
        XCTAssertTrue(app.staticTexts["live-answer"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.otherElements["thinking"].exists)
        capture("daily-prepared-answer")
        app.buttons["save-discovery"].tap()
        app.unlockSavedObservation()
        let reveal = app.buttons["reveal-card"]
        XCTAssertTrue(reveal.waitForExistence(timeout: 8))
        reveal.tap()
        capture("daily-prepared-card")
        let memory = app.buttons["new-card-memory"]
        XCTAssertTrue(memory.waitForExistence(timeout: 8)); memory.tap()
        let share = app.buttons["memory-share-preview"]
        XCTAssertTrue(share.waitForExistence(timeout: 8)); share.tap()
        app.buttons["create-share"].tap()
        XCTAssertTrue(app.staticTexts["share-url"].waitForExistence(timeout: 10))
        let url = try XCTUnwrap(URL(string: app.staticTexts["share-url"].label))
        let body = try request(base + "/api/shares/" + url.lastPathComponent)
        let cards = try XCTUnwrap(body["cards"] as? [[String: Any]])
        XCTAssertEqual(cards.count, 1); XCTAssertNotNil(cards[0]["artworkID"])
        capture("daily-prepared-share")
        app.buttons["revoke-share"].tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 10))
        app.terminate()
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
        app.launch()
        XCTAssertTrue(questions.firstMatch.waitForExistence(timeout: 10))
        XCTAssertEqual(questions.allElementsBoundByIndex.map(\.identifier), identifiers)
        let status = try request(base + "/__fixture/daily/status")
        XCTAssertEqual(status["generatedQuestions"] as? Int, before["generatedQuestions"] as? Int)
        XCTAssertEqual(status["generatedArtwork"] as? Int, before["generatedArtwork"] as? Int)
    }
    private func request(_ url: String) throws -> [String: Any] {
        let done = expectation(description: "fixture response")
        var result: Result<Data, Error>?
        URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
            result = error.map(Result.failure) ?? .success(data ?? Data()); done.fulfill()
        }.resume()
        wait(for: [done], timeout: 10)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: result!.get()) as? [String: Any])
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
}
