import XCTest

@MainActor final class PitchLanguageFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private let base = PitchFixtureServer.base
    private var done = "Done"
    func testChineseFamilyFriendsAndNearbyEvents() async throws { try await exercise("zh-Hans", done: "完成") }
    func testArabicFamilyFriendsAndNearbyEvents() async throws { try await exercise("ar", done: "تم") }
    func testArabicNewFeaturesAtLargestTextSize() async throws { try await exercise("ar", done: "تم", large: true) }
    private func button(_ id: String) -> XCUIElement {
        let matches = app.buttons.matching(identifier: id); return matches.allElementsBoundByIndex.last ?? matches.firstMatch
    }
    private func reach(_ element: XCUIElement) {
        _ = element.waitForExistence(timeout: 2)
        for _ in 0..<20 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }
    private func tap(_ id: String) { let element = button(id); reach(element); element.tap() }
    private func capture(_ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    private func exercise(_ language: String, done: String, large: Bool = false) async throws {
        continueAfterFailure = false; self.done = done
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/reset")!)
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(\(language))", "-AppleLocale", language]
        if large { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base; app.launch()
        tap("language-continue"); tap("open-profile"); tap("open-family-settings")
        reach(app.textFields["family-nickname"]); capture("pitch-\(language)-profile-\(large)")
        for id in ["family-pin", "family-confirm-pin"] {
            let field = app.secureTextFields[id]; reach(field); field.tap(); field.typeText("926418")
        }
        tap("family-create"); reach(app.staticTexts["family-recovery-code"]); tap("family-recovery-saved")
        let social = app.switches["family-social"]; reach(social); social.coordinate(withNormalizedOffset: CGVector(dx: language == "ar" ? 0.1 : 0.9, dy: 0.5)).tap()
        XCTAssertEqual(social.value as? String, "1"); capture("pitch-\(language)-permissions-\(large)")
        tap("family-save")
        XCTAssertTrue(app.staticTexts["family-saved"].waitForExistence(timeout: 15) || app.otherElements["family-saved"].exists)
        tap("family-done"); tap(done)
        app.tabBars.buttons.element(boundBy: 2).tap()
        let code = app.staticTexts["friend-code"]; reach(code); capture("pitch-\(language)-friend-code-\(large)")
        let (seedData, _) = try await URLSession.shared.data(from: URL(string: base + "/__fixture/social/seed")!)
        let seed = try XCTUnwrap(JSONSerialization.jsonObject(with: seedData) as? [String: String])
        func peer(_ path: String, _ body: [String: Any]) async throws -> [String: Any] {
            var request = URLRequest(url: URL(string: base + path)!); request.httpMethod = "POST"
            request.setValue("Bearer \(seed["key"]!)", forHTTPHeaderField: "Authorization"); request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        }
        let invited = try await peer("/api/social/friends", ["code": code.label]), id = try XCTUnwrap(invited["id"] as? String)
        tap("friends-refresh"); tap("friend-accept-\(id)"); tap("friend-open-\(id)")
        _ = try await peer("/api/social/friends/\(id)/messages", ["id": UUID().uuidString.lowercased(), "text": language == "ar" ? "رأيت قوس قزح!" : "我发现了彩虹！"])
        tap("friend-refresh"); reach(button("friend-message-send")); capture("pitch-\(language)-messages-\(large)")
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
        app.open(URL(string: "pocketexplorer://events/77777777-7777-4777-8777-777777777777")!)
        reach(button("event-location")); capture("pitch-\(language)-event-\(large)")
        reach(button("event-choice-0")); capture("pitch-\(language)-challenge-\(large)"); tap(done)
        app.tabBars.buttons.element(boundBy: 1).tap(); tap("open-nearby"); tap("find-events")
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            let allow = app.alerts.buttons.matching(NSPredicate(format: "label CONTAINS %@", "While Using")).firstMatch
            if allow.exists { allow.tap() }
        }
        reach(button("nearby-event-77777777-7777-4777-8777-777777777777")); capture("pitch-\(language)-nearby-\(large)")
        app.terminate()
    }
}
