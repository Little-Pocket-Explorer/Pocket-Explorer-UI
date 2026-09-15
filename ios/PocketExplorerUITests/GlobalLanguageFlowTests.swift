import XCTest

final class GlobalLanguageFlowTests: XCTestCase {
    private let app = XCUIApplication()

    func testEnglish() { exercise("english", map: "Map", title: "The day we met the ducks", done: "Done") }
    func testSimplifiedChinese() { exercise("chinese", map: "地图", title: "遇见鸭子的那一天", done: "完成") }
    func testTraditionalChinese() { exercise("traditionalChinese", map: "地圖", title: "遇見鴨子的那一天", done: "完成") }
    func testSpanish() { exercise("spanish", map: "Mapa", title: "El día que conocimos a los patos", done: "Listo") }
    func testFrench() { exercise("french", map: "Carte", title: "Le jour où nous avons rencontré les canards", done: "Terminé") }
    func testGerman() { exercise("german", map: "Karte", title: "Der Tag, an dem wir die Enten trafen", done: "Fertig") }
    func testPortuguese() { exercise("portuguese", map: "Mapa", title: "O dia em que conhecemos os patos", done: "Pronto") }
    func testJapanese() { exercise("japanese", map: "地図", title: "アヒルに出会った日", done: "完了") }
    func testKorean() { exercise("korean", map: "지도", title: "오리를 만난 날", done: "완료") }
    func testArabic() { exercise("arabic", map: "الخريطة", title: "اليوم الذي التقينا فيه بالبط", done: "تم") }
    func testArabicAtTheLargestTextSize() { exercise("arabic", map: "الخريطة", title: "اليوم الذي التقينا فيه بالبط", done: "تم", large: true) }
    func testGermanAtTheLargestTextSize() { exercise("german", map: "Karte", title: "Der Tag, an dem wir die Enten trafen", done: "Fertig", large: true) }
    func testFrenchAtTheLargestTextSize() { exercise("french", map: "Carte", title: "Le jour où nous avons rencontré les canards", done: "Terminé", large: true) }
    func testPortugueseAtTheLargestTextSize() { exercise("portuguese", map: "Mapa", title: "O dia em que conhecemos os patos", done: "Pronto", large: true) }

    private func exercise(_ preference: String, map: String, title: String, done: String, large: Bool = false) {
        continueAfterFailure = false
        app.launchArguments = ["--ui-testing", "--reset-journal", "--reset-language", "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        if large { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        app.launchEnvironment["POCKET_SHARE_BASE_URL"] = FixtureServer.base
        app.launch()
        XCTAssertTrue(app.buttons["language-continue"].waitForExistence(timeout: 15))
        let option = app.buttons["language-\(preference)"]
        for _ in 0..<18 {
            let bottom = app.buttons["language-continue"].frame.minY - 8
            if option.isHittable && option.frame.minY >= 40 && option.frame.maxY <= bottom { break }
            let delta = max(-180, min(180, (40 + bottom) / 2 - option.frame.midY))
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.52))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 0, dy: delta)))
        }
        XCTAssertTrue(option.isHittable)
        XCTAssertLessThan(option.frame.maxY, app.buttons["language-continue"].frame.minY)
        option.tap()
        let selected = expectation(for: NSPredicate(format: "selected == true"), evaluatedWith: option)
        wait(for: [selected], timeout: 5)
        capture("\(preference)-language\(large ? "-large" : "")")
        app.buttons["language-continue"].tap()
        XCTAssertTrue(app.tabBars.buttons[map].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["home-question"].isHittable)
        XCTAssertGreaterThanOrEqual(app.buttons["home-ask"].frame.height, 44)
        if large { XCTAssertLessThan(app.buttons["home-question"].frame.height, app.frame.height * 0.22) }
        capture("\(preference)-home\(large ? "-large" : "")")
        app.buttons["home-question"].tap()
        XCTAssertTrue(app.buttons["speak-button"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["speak-button"].isHittable)
        capture("\(preference)-question\(large ? "-large" : "")")
        app.buttons["exploration-close"].tap()
        app.tabBars.buttons[map].tap()
        capture("\(preference)-map\(large ? "-large" : "")")
        app.buttons["open-collection"].tap()
        XCTAssertTrue(app.staticTexts["journal-count"].waitForExistence(timeout: 6))
        capture("\(preference)-collection\(large ? "-large" : "")")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let trip = app.buttons["trip-10000000-0000-4000-8000-000000000001"]
        scrollTo(trip); trip.tap()
        XCTAssertTrue(app.staticTexts["trip-title"].waitForExistence(timeout: 6))
        XCTAssertEqual(app.staticTexts["trip-title"].label, title, "First-launch examples must be created after selecting their language.")
        capture("\(preference)-trip\(large ? "-large" : "")")
        scrollTo(app.buttons["make-memory"]); app.buttons["make-memory"].tap()
        XCTAssertTrue(app.staticTexts["memory-chapter"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["memory-play-pause"].isHittable)
        if large { XCTAssertLessThan(app.buttons["memory-play-pause"].frame.height, 115) }
        capture("\(preference)-memory\(large ? "-large" : "")")
        app.buttons[done].tap()
        scrollTo(app.buttons["share-trip"])
        capture("\(preference)-before-sharing\(large ? "-large" : "")")
        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = "\(preference)-sharing-hierarchy"
        hierarchy.lifetime = .keepAlways
        add(hierarchy)
        app.buttons["share-trip"].tap()
        XCTAssertTrue(app.buttons["create-share"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["create-share"].isHittable)
        XCTAssertGreaterThanOrEqual(app.buttons["create-share"].frame.height, 44)
        for identifier in ["share-include-name", "share-include-city"] {
            let toggle = app.switches.matching(identifier: identifier).firstMatch
            XCTAssertTrue(toggle.exists)
            XCTAssertEqual(toggle.value as? String, "0")
        }
        capture("\(preference)-share\(large ? "-large" : "")")
        app.terminate()
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

    private func capture(_ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name; screenshot.lifetime = .keepAlways; add(screenshot)
    }
}
