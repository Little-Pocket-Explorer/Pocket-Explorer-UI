import AVFoundation
import XCTest
@testable import PocketExplorer

final class NarrationStyleTests: XCTestCase {
    func testVoiceSelectionPrefersNaturalFemaleVoicesWithoutChangingTheSpokenLanguage() {
        let voices = [
            NarrationStyle.Candidate(identifier: "en-default", language: "en-AU", quality: 1, female: true),
            NarrationStyle.Candidate(identifier: "en-natural", language: "en-AU", quality: 2, female: true),
            NarrationStyle.Candidate(identifier: "en-premium", language: "en-US", quality: 3, female: true),
            NarrationStyle.Candidate(identifier: "en-male", language: "en-AU", quality: 3, female: false),
            NarrationStyle.Candidate(identifier: "zh-natural", language: "zh-CN", quality: 2, female: true),
            NarrationStyle.Candidate(identifier: "zh-cantonese", language: "zh-HK", quality: 3, female: true)
        ]
        XCTAssertEqual(NarrationStyle.preferredIdentifier(in: voices, locale: "en-AU"), "en-premium")
        XCTAssertEqual(NarrationStyle.preferredIdentifier(in: voices, locale: "zh-CN"), "zh-natural")
        XCTAssertEqual(NarrationStyle.preferredIdentifier(in: voices, locale: "zh-HK"), "zh-cantonese")
        XCTAssertNil(NarrationStyle.preferredIdentifier(in: voices, locale: "ja-JP"))
        XCTAssertEqual(NarrationStyle.preferredIdentifier(in: Array(voices.prefix(1)), locale: "en-AU"), "en-default")
        let regional = [
            NarrationStyle.Candidate(identifier: "us", language: "en-US", quality: 2, female: true),
            NarrationStyle.Candidate(identifier: "au", language: "en-AU", quality: 2, female: true)
        ]
        XCTAssertEqual(NarrationStyle.preferredIdentifier(in: regional, locale: "en-AU"), "au")
        XCTAssertEqual(NarrationStyle.preferredIdentifier(in: regional.reversed(), locale: "en-GB"), "au")
    }

    func testSentencePacingPreservesEnglishAndChineseContent() {
        XCTAssertEqual(NarrationStyle.locale(for: "en"), "en-AU")
        XCTAssertEqual(NarrationStyle.locale(for: "zh-Hans"), "zh-CN")
        XCTAssertEqual(NarrationStyle.locale(for: "zh-Hant"), "zh-TW")
        XCTAssertEqual(NarrationStyle.locale(for: "fr-FR"), "fr-FR")
        XCTAssertTrue(NarrationStyle.sentences("  \n ").isEmpty)
        for text in ["Air scatters blue light. Look up at the clouds!", "空气把蓝光散开。看看云朵的颜色！"] {
            let sentences = NarrationStyle.sentences(text)
            XCTAssertGreaterThanOrEqual(sentences.count, 2)
            XCTAssertEqual(sentences.joined().replacingOccurrences(of: " ", with: ""), text.replacingOccurrences(of: " ", with: ""))
        }
        XCTAssertEqual(NarrationStyle.sentences("Look at this leaf"), ["Look at this leaf"])
    }

    func testActualAvailableVoicesAndUtterancesUseGentleCadence() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let inventory = voices.map { "\($0.identifier) | \($0.language) | quality=\($0.quality.rawValue) | gender=\($0.gender.rawValue)" }.joined(separator: "\n")
        let attachment = XCTAttachment(string: inventory); attachment.name = "available-system-voices"; attachment.lifetime = .keepAlways; add(attachment)
        for (language, text) in [("en", "A leaf catches sunlight. It uses this light to grow."), ("zh-Hans", "叶子会接住阳光。它用这些阳光慢慢长大。") ] {
            let utterances = NarrationStyle.utterances(text, language: language, voices: voices)
            XCTAssertEqual(utterances.count, 2)
            XCTAssertTrue(utterances.allSatisfy { $0.rate < AVSpeechUtteranceDefaultSpeechRate && $0.postUtteranceDelay > 0 })
            XCTAssertEqual(utterances[0].preUtteranceDelay, 0.05)
            XCTAssertEqual(utterances[1].preUtteranceDelay, 0)
            XCTAssertTrue(utterances.allSatisfy { $0.pitchMultiplier < 1.1 })
            if let voice = utterances.first?.voice { XCTAssertTrue(voice.language.hasPrefix(language == "en" ? "en" : "zh")) }
        }
        XCTAssertTrue(NarrationStyle.utterances("", language: "en").isEmpty)
    }
}
