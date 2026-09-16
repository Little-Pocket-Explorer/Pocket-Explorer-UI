import XCTest
@testable import PocketExplorer

@MainActor final class NavigationTests: XCTestCase {
    func testDetoursPreserveEachTabAndHomeClearsOnlyChat() {
        let navigation = AppNavigation(), discovery = UUID()
        let explore = ExplorerRoute.explore(.init(question: "Why?"))
        navigation.open(explore)
        navigation.open(.card(discovery))
        navigation.open(.nearby, in: .map)
        navigation.open(.event("event"))
        navigation.open(.friendProfile("friend"), in: .social)
        XCTAssertEqual(navigation.current, .friendProfile("friend"))
        navigation.open(explore, in: .chat)
        XCTAssertEqual(navigation.paths[.chat], [explore])
        XCTAssertEqual(navigation.paths[.map], [.nearby, .event("event")])
        navigation.back(); navigation.back()
        XCTAssertNil(navigation.current)
        navigation.open(.recall(discovery), in: .social)
        navigation.home()
        XCTAssertEqual(navigation.tab, .chat)
        XCTAssertTrue(navigation.paths[.chat]!.isEmpty)
        XCTAssertEqual(navigation.roots[.chat], 1)
        XCTAssertEqual(navigation.paths[.social], [.friendProfile("friend"), .recall(discovery)])
        for tab in ExplorerTab.allCases { navigation.tab = tab; XCTAssertNotNil(navigation.paths[.chat]) }
    }

    func testDraftsSurviveReopeningAndAreIsolatedByContext() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let journal = directory.appendingPathComponent("journal.json")
        let file = ExplorationDraftFile(journal: journal, context: ["one", "en"])
        XCTAssertNil(try file.load())
        let draft = ExplorationDraft(question: "Why?", observation: "It is green.", recordID: UUID(), parentID: UUID(), photo: Data([1, 2, 3]), photoChanged: true)
        try file.save(draft)
        XCTAssertEqual(try ExplorationDraftFile(journal: journal, context: ["one", "en"]).load(), draft)
        XCTAssertNil(try ExplorationDraftFile(journal: journal, context: ["two", "en"]).load())
        XCTAssertNil(try ExplorationDraftFile(journal: journal, context: ["one", "ar"]).load())
        var broken = file; broken.writer = { _, _ in throw CocoaError(.fileWriteOutOfSpace) }
        XCTAssertThrowsError(try broken.save(.init(question: "A new thought")))
        XCTAssertEqual(try file.load(), draft)
        XCTAssertThrowsError(try file.save(.init(photo: Data(repeating: 1, count: 8_000_000))))
        XCTAssertEqual(try file.load(), draft)
        try file.save(.init()); XCTAssertNil(try file.load())
        try file.remove()
        try Data("broken".utf8).write(to: file.url)
        XCTAssertThrowsError(try file.load())
        XCTAssertEqual(try Data(contentsOf: file.url), Data("broken".utf8))
        try Data(repeating: 1, count: 8_000_001).write(to: file.url)
        XCTAssertThrowsError(try file.load())
    }
}
