import XCTest

@MainActor final class EventFlowTests: XCTestCase {
    private let app = XCUIApplication()
    private var base: String { PitchFixtureServer.base }
    override func setUp() async throws {
        continueAfterFailure = false
        _ = try await URLSession.shared.data(from: URL(string: base + "/__fixture/family/reset")!)
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "--empty-journal", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = base
        app.launch()
        XCTAssertTrue(button("language-continue").waitForExistence(timeout: 15)); button("language-continue").tap()
    }
    private func button(_ id: String) -> XCUIElement {
        let matches = app.buttons.matching(identifier: id); return matches.allElementsBoundByIndex.last ?? matches.firstMatch
    }
    private func reach(_ element: XCUIElement) {
        _ = element.waitForExistence(timeout: 2)
        for _ in 0..<12 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot()); image.name = name; image.lifetime = .keepAlways; add(image)
    }
    private func pin(_ value: String, confirm: Bool = false) {
        let input = app.secureTextFields[confirm ? "family-confirm-pin" : "family-pin"]
        reach(input); input.tap(); input.typeText(value)
    }
    func testFamilySetupEventVisitChallengeAwardAndCoarseMapSharing() async throws {
        app.tabBars.buttons["Map"].tap()
        reach(button("open-nearby")); button("open-nearby").tap()
        reach(button("Family settings")); button("Family settings").tap()
        pin("926418"); pin("926418", confirm: true)
        reach(button("family-create")); button("family-create").tap()
        XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 15)); button("family-recovery-saved").tap()
        button("family-done").tap()
        reach(button("find-events")); button("find-events").tap()
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            let allow = app.alerts.buttons.matching(NSPredicate(format: "label CONTAINS %@", "While Using")).firstMatch
            if allow.exists { allow.tap() }
        }
        let event = button("nearby-event-77777777-7777-4777-8777-777777777777")
        reach(event); capture("nearby-native-map-and-event"); event.tap()
        reach(button("Refresh event")); button("Refresh event").tap()
        reach(button("event-choice-1")); button("event-choice-1").tap()
        reach(button("event-claim")); button("event-claim").tap()
        XCTAssertTrue(app.staticTexts["event-error"].waitForExistence(timeout: 5))
        for _ in 0..<5 where !button("event-location").isHittable { app.swipeDown() }
        button("event-location").tap()
        reach(button("event-choice-1")); button("event-choice-1").tap()
        reach(button("event-claim")); button("event-claim").tap()
        XCTAssertTrue(app.staticTexts["event-feedback"].waitForExistence(timeout: 15)); capture("event-wrong-answer-keeps-challenge")
        reach(button("event-choice-0")); button("event-choice-0").tap()
        reach(button("event-claim")); button("event-claim").tap()
        reach(button("reveal-card")); capture("event-exclusive-card-awarded"); button("reveal-card").tap()
        reach(button("card-map-sharing")); button("card-map-sharing").tap()
        reach(button("Family settings")); button("Family settings").tap()
        pin("926418"); button("family-unlock").tap()
        let sharing = app.switches["family-mapSharing"]
        reach(sharing); sharing.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        reach(button("family-save")); button("family-save").tap()
        XCTAssertTrue(app.staticTexts["Family settings saved"].waitForExistence(timeout: 10)); button("family-done").tap()
        reach(button("publish-map-card")); button("publish-map-card").tap()
        XCTAssertTrue(app.staticTexts["map-published"].waitForExistence(timeout: 15) || app.otherElements["map-published"].exists)
        let (bytes, _) = try await URLSession.shared.data(from: URL(string: base + "/api/map-discoveries?latitude=-33.87&longitude=151.21")!)
        let data = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? [String: Any]), cards = try XCTUnwrap(data["items"] as? [[String: Any]])
        XCTAssertFalse(cards.isEmpty)
        let publicText = String(data: bytes, encoding: .utf8)!
        XCTAssertFalse(publicText.contains("33.871373")); XCTAssertFalse(publicText.contains("owner_hash"))
        capture("map-card-published-coarse-location")
        button("revoke-map-card").tap()
        XCTAssertFalse(button("revoke-map-card").waitForExistence(timeout: 2))
    }
    func testSharedCardAndEventLinksLoadOriginalContentAndUnavailableState() async throws {
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
        let (data, _) = try await URLSession.shared.data(from: URL(string: base + "/__fixture/social/seed")!)
        let seed = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String]), mapID = try XCTUnwrap(seed["mapID"])
        app.open(URL(string: "pocketexplorer://discoveries/\(mapID)")!)
        XCTAssertTrue(app.staticTexts["Moon neighbour"].waitForExistence(timeout: 15))
        reach(app.staticTexts["Shared in this area"]); capture("shared-card-link-original-content")
        button("Done").tap()
        app.open(URL(string: "pocketexplorer://events/77777777-7777-4777-8777-777777777777")!)
        XCTAssertTrue(app.staticTexts["Sky watchers"].waitForExistence(timeout: 15))
        reach(button("Family settings")); capture("event-link-profile-guidance")
        app.open(URL(string: "pocketexplorer://events/11111111-1111-4111-8111-111111111111")!)
        XCTAssertTrue(button("Try again").waitForExistence(timeout: 15)); button("Try again").tap()
        XCTAssertTrue(button("Done").waitForExistence(timeout: 5)); button("Done").tap()
    }
    func testSharedCardIsReadableFromTheNearbyMap() async throws {
        let (data, _) = try await URLSession.shared.data(from: URL(string: base + "/__fixture/social/seed")!)
        let seed = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String]), mapID = try XCTUnwrap(seed["mapID"])
        app.tabBars.buttons["Map"].tap(); reach(button("open-nearby")); button("open-nearby").tap()
        reach(button("Family settings")); button("Family settings").tap()
        pin("926418"); pin("926418", confirm: true); reach(button("family-create")); button("family-create").tap()
        XCTAssertTrue(app.staticTexts["family-recovery-code"].waitForExistence(timeout: 15)); button("family-recovery-saved").tap(); button("family-done").tap()
        reach(button("find-events")); button("find-events").tap()
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            let allow = app.alerts.buttons.matching(NSPredicate(format: "label CONTAINS %@", "While Using")).firstMatch
            if allow.exists { allow.tap() }
        }
        let shared = button("nearby-shared-\(mapID)"); reach(shared); shared.tap()
        XCTAssertTrue(app.staticTexts["Moon neighbour"].waitForExistence(timeout: 10))
        reach(app.staticTexts["Shared in this area"]); capture("shared-card-opened-from-nearby-map")
        button("Done").tap(); XCTAssertTrue(button("nearby-shared-\(mapID)").exists)
    }
    func testEventLinkOpensWhileProfileSheetIsAlreadyPresented() {
        app.launchArguments.removeAll { ["--reset-journal", "--reset-language"].contains($0) }
        button("open-profile").tap()
        XCTAssertTrue(button("open-family-settings").waitForExistence(timeout: 5))
        app.open(URL(string: "pocketexplorer://events/77777777-7777-4777-8777-777777777777")!)
        XCTAssertTrue(app.staticTexts["Sky watchers"].waitForExistence(timeout: 15))
        capture("event-link-over-profile-sheet")
        button("Done").tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
}
