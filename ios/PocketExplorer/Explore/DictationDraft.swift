import Foundation

struct DictationDraft {
    let original: String

    func applying(_ transcript: String) -> String {
        let words = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty else { return original }
        let prefix = original.trimmingCharacters(in: .whitespacesAndNewlines)
        return prefix.isEmpty ? words : prefix + " " + words
    }
}
