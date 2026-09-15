import XCTest
@testable import PocketExplorer

final class MemoryReadingTests: XCTestCase {
    func testShortChaptersAndLongReadingBounds() {
        XCTAssertEqual(MemoryReading.duration(for: "How do ducks swim?"), 5)
        XCTAssertEqual(MemoryReading.duration(for: ""), 5)
        XCTAssertEqual(MemoryReading.duration(for: " \n\t "), 5)
        XCTAssertEqual(MemoryReading.duration(for: String(repeating: "light ", count: 300)), 45)
        XCTAssertGreaterThan(MemoryReading.duration(for: String(repeating: "light ", count: 40)), 15)
    }

    func testCompactScriptsAndMixedLanguageReading() {
        for letter in ["空", "あ", "ア", "한"] {
            XCTAssertGreaterThan(MemoryReading.duration(for: String(repeating: letter, count: 30)), MemoryReading.duration(for: String(repeating: "a", count: 30)))
        }
        XCTAssertEqual(MemoryReading.duration(for: String(repeating: "光", count: 1000)), 45)
        XCTAssertEqual(MemoryReading.duration(for: "Sun " + String(repeating: "光", count: 30)), 9)
        XCTAssertGreaterThan(MemoryReading.duration(for: String(repeating: "لماذا يتغير الظل؟ ", count: 20)), 10)
    }

    func testFormattingAndUnicodeCompositionKeepTheSamePace() {
        XCTAssertEqual(MemoryReading.duration(for: String(repeating: "a ", count: 100)), MemoryReading.duration(for: String(repeating: "a\n", count: 100)))
        XCTAssertEqual(MemoryReading.duration(for: String(repeating: "é", count: 100)), MemoryReading.duration(for: String(repeating: "e\u{0301}", count: 100)))
    }
}
