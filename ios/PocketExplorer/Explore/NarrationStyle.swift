import AVFoundation
import Foundation

enum NarrationStyle {
    struct Candidate {
        var identifier: String
        var language: String
        var quality: Int
        var female: Bool
    }

    static func locale(for language: String) -> String {
        switch language {
        case "en": return "en-AU"
        case "zh-Hans": return "zh-CN"
        case "zh-Hant": return "zh-TW"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "ar": return "ar-SA"
        default: return language
        }
    }

    static func preferredIdentifier(in candidates: [Candidate], locale: String) -> String? {
        let family = locale.split(separator: "-").first
        let matching = candidates.filter {
            $0.language.split(separator: "-").first == family &&
                !(family == "zh" && locale != "zh-HK" && $0.language == "zh-HK")
        }
        let natural = matching.filter { $0.quality >= AVSpeechSynthesisVoiceQuality.enhanced.rawValue }
        let pool = natural.isEmpty ? matching : natural
        func score(_ voice: Candidate) -> Int {
            (voice.female ? 100 : 0) + voice.quality * 10 + (voice.language == locale ? 5 : 0)
        }
        return pool.sorted {
            score($0) == score($1) ? $0.identifier < $1.identifier : score($0) > score($1)
        }.first?.identifier
    }

    static func sentences(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        var result: [String] = []
        trimmed.enumerateSubstrings(in: trimmed.startIndex..<trimmed.endIndex, options: .bySentences) { sentence, _, _, _ in
            if let sentence { result.append(sentence.trimmingCharacters(in: .whitespacesAndNewlines)) }
        }
        return result.isEmpty ? [trimmed] : result
    }

    static func utterances(_ text: String, language: String, voices: [AVSpeechSynthesisVoice] = AVSpeechSynthesisVoice.speechVoices()) -> [AVSpeechUtterance] {
        let locale = locale(for: language)
        let candidates = voices.filter { !$0.voiceTraits.contains(.isNoveltyVoice) && !$0.voiceTraits.contains(.isPersonalVoice) }.map {
            Candidate(identifier: $0.identifier, language: $0.language, quality: $0.quality.rawValue, female: $0.gender == .female)
        }
        let identifier = preferredIdentifier(in: candidates, locale: locale)
        let selected = voices.first { $0.identifier == identifier } ?? AVSpeechSynthesisVoice(language: locale)
        return sentences(text).enumerated().map { index, sentence in
            let utterance = AVSpeechUtterance(string: sentence)
            utterance.voice = selected
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
            utterance.pitchMultiplier = 1.02
            utterance.preUtteranceDelay = index == 0 ? 0.05 : 0
            utterance.postUtteranceDelay = 0.18
            return utterance
        }
    }
}
