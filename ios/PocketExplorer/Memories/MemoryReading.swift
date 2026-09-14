import Foundation

enum MemoryReading {
    private static let compactScript = try! NSRegularExpression(pattern: "[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}]")

    static func duration(for text: String) -> TimeInterval {
        let normalized = text.precomposedStringWithCanonicalMapping
        let visible = normalized.unicodeScalars.filter { !CharacterSet.whitespacesAndNewlines.contains($0) }.count
        let compact = compactScript.numberOfMatches(in: normalized, range: NSRange(normalized.startIndex..., in: normalized))
        return min(45, max(5, ceil(2 + Double(visible + compact * 2) / 14)))
    }
}
