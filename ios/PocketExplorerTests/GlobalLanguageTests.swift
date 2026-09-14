import XCTest
@testable import PocketExplorer

@MainActor final class GlobalLanguageTests: XCTestCase {
    func testLanguageNegotiationUsesEveryPreferenceAndHonoursChineseScript() {
        let cases: [([String], AppLanguage)] = [
            (["xx-ZZ", "fr-CA", "en"], .french), (["zh-TW"], .traditionalChinese), (["zh_HK"], .traditionalChinese),
            (["zh-MO"], .traditionalChinese), (["zh-Hans-TW"], .chinese), (["zh-Hant-CN"], .traditionalChinese),
            (["zh-SG"], .chinese), (["pt-PT"], .portuguese), (["es-MX"], .spanish), (["de-AT"], .german),
            (["ja-JP"], .japanese), (["ko-KR"], .korean), (["ar-EG"], .arabic), (["unknown"], .english)
        ]
        for (input, expected) in cases { XCTAssertEqual(AppLanguage.resolve(input), expected, input.joined(separator: ",")) }
        XCTAssertEqual(LanguagePreference(rawValue: "english"), .english)
        XCTAssertEqual(LanguagePreference(rawValue: "chinese"), .chinese)
        XCTAssertEqual(LanguagePreference(rawValue: "system"), .system)
        XCTAssertEqual(LanguagePreference.allCases.count, 11)
        for preference in LanguagePreference.allCases {
            XCTAssertEqual(preference.id, preference.rawValue)
            XCTAssertEqual(preference.resolve(["fr-CA"]), preference.language ?? .french)
        }
        let locales = ["en-AU", "zh-CN", "zh-TW", "es-ES", "fr-FR", "de-DE", "pt-BR", "ja-JP", "ko-KR", "ar-SA"]
        for (language, expected) in zip(AppLanguage.allCases, locales) {
            XCTAssertEqual(language.id, language.rawValue)
            XCTAssertFalse(language.name.isEmpty)
            XCTAssertEqual(language.speechLocale, expected)
            XCTAssertEqual(language.isRightToLeft, language == .arabic)
        }
    }

    func testSavedLanguageStaysWithTheAnswerAfterSwitchingReloadingAndSharing() throws {
        let defaults = LanguageSettings.preferences
        let previous = defaults.object(forKey: "app-language")
        defer { if let previous { defaults.set(previous, forKey: "app-language") } else { defaults.removeObject(forKey: "app-language") } }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("journal.json")
        LanguageSettings.save(.spanish)
        let store = try TripStore(fileURL: file, initial: JournalState(trips: [], discoveries: []))
        let question = try store.beginQuestion("葉っぱはなぜ緑？", age: 7, photo: nil)
        let answer = AIReply(title: "Hojas verdes", answer: "La clorofila da color verde a muchas hojas.", invitation: "Mira una hoja desde donde estás.", category: "nature", artworkPrompt: "A green leaf",
                             quiz: DiscoveryQuiz(question: "¿Qué da el color verde?", choices: ["La clorofila", "La luna", "La lluvia"], correctIndex: 0, explanation: "La clorofila es verde."))
        try store.saveAnswer(answer, for: question.id)
        LanguageSettings.save(.arabic)
        let card = try store.keepQuestion(question.id, observation: "緑色の葉っぱを見た。")
        XCTAssertEqual(card.language, "es")
        XCTAssertEqual(card.title, answer.title)
        try store.finishTrip(card.tripID)
        let reopened = try TripStore(fileURL: file)
        XCTAssertEqual(reopened.questions.first?.language, "es")
        XCTAssertEqual(reopened.state.discoveries.first?.observation, "緑色の葉っぱを見た。")
        let trip = try XCTUnwrap(reopened.state.trips.first)
        let story = PublicStory.make(trip: trip, discoveries: reopened.state.discoveries)
        XCTAssertEqual(story.language, "es")
        XCTAssertEqual(story.cards.first?.language, "es")
        XCTAssertEqual(story.chapters.map(\.language), ["es", "es", "es"])
        XCTAssertEqual(story.chapters[0].text, question.question)
        XCTAssertEqual(story.chapters[1].text, card.observation)
        XCTAssertEqual(story.chapters[2].text, answer.answer)
        XCTAssertEqual(story.chapters[0].title, "It started with a why.")
        XCTAssertEqual(try JSONDecoder().decode(PublicStory.self, from: JSONEncoder().encode(story)), story)
    }

    func testOldPublicStoryAndJournalDecodeWithoutInventingContentLanguages() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "public-story-v1", withExtension: "json"))
        let story = try JSONDecoder().decode(PublicStory.self, from: Data(contentsOf: url))
        XCTAssertNil(story.language)
        XCTAssertTrue(story.cards.allSatisfy { $0.language == nil })
        XCTAssertTrue(story.chapters.allSatisfy { $0.language == nil })
        func stripLanguages(_ value: Any) -> Any {
            if let array = value as? [Any] { return array.map(stripLanguages) }
            if let object = value as? [String: Any] { return object.filter { $0.key != "language" }.mapValues(stripLanguages) }
            return value
        }
        let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(JournalState.examples(language: .english)))
        let legacy = try JSONSerialization.data(withJSONObject: stripLanguages(object))
        let decoded = try JSONDecoder().decode(JournalState.self, from: legacy)
        XCTAssertEqual(decoded.trips.count, 3)
        XCTAssertNil(decoded.trips.first?.language)
        XCTAssertTrue(decoded.discoveries.allSatisfy { $0.language == nil })
    }

    func testEveryLanguageContainsAllMessagesFormatsAndPermissionDescriptions() throws {
        func dictionary(_ name: String, _ language: AppLanguage) throws -> [String: String] {
            let path = try XCTUnwrap(Bundle.main.path(forResource: name, ofType: "strings", inDirectory: nil, forLocalization: language.rawValue))
            return try XCTUnwrap(PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: path)), format: nil) as? [String: String])
        }
        let english = try dictionary("Localizable", .english)
        XCTAssertGreaterThanOrEqual(english.count, 316)
        let format = try NSRegularExpression(pattern: #"%(?:\d+\$)?(?:lld|@|%)"#)
        func placeholders(_ value: String) -> [String] {
            format.matches(in: value, range: NSRange(value.startIndex..., in: value)).map { String(value[Range($0.range, in: value)!]) }.sorted()
        }
        for language in AppLanguage.allCases {
            let messages = try dictionary("Localizable", language)
            XCTAssertEqual(Set(messages.keys), Set(english.keys), language.rawValue)
            for key in ["Card details", "My question", "From your discoveries"] {
                XCTAssertNotNil(messages[key], "\(language.rawValue): \(key)")
                if language != .english { XCTAssertNotEqual(L10n.text(key, language: language), key) }
            }
            for (key, value) in messages {
                XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "\(language.rawValue): \(key)")
                XCTAssertEqual(placeholders(value), placeholders(key), "\(language.rawValue): \(key)")
            }
            let permissions = try dictionary("InfoPlist", language)
            XCTAssertEqual(Set(permissions.keys), ["NSCameraUsageDescription", "NSMicrophoneUsageDescription", "NSSpeechRecognitionUsageDescription", "NSLocationWhenInUseUsageDescription"])
            XCTAssertTrue(permissions.values.allSatisfy { !$0.isEmpty })
            XCTAssertEqual(L10n.text("Choose your language", language: language), messages["Choose your language"])
        }
        XCTAssertEqual(L10n.text("A future untranslated key", language: .arabic), "A future untranslated key")
    }

    func testNewExamplesAndPreparedRepliesUseTheSelectedLanguageWithoutRewritingSavedStories() throws {
        let english = JournalState.examples(language: .english)
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("journal.json")
        _ = try TripStore(fileURL: url, initial: english)
        for language in AppLanguage.allCases {
            let sample = JournalState.examples(language: language)
            XCTAssertTrue(sample.discoveries.allSatisfy { $0.language == language.rawValue })
            XCTAssertTrue(sample.trips.allSatisfy { $0.language == language.rawValue })
            XCTAssertEqual(sample.discoveries.map(\.id), english.discoveries.map(\.id))
            XCTAssertEqual(sample.discoveries.first?.title, L10n.text("Duck paddles", language: language))
            let shared = PublicStory.make(trip: sample.trips[0], discoveries: Array(sample.discoveries.prefix(2)))
            XCTAssertEqual(shared.cards[0].title, L10n.text("Duck paddles", language: language))
            XCTAssertEqual(shared.cards[0].language, language.rawValue)
            for subject in [DiscoverySubject.duck, .leaf, .shell] {
                let question = L10n.text(english.discoveries.first { $0.subject == subject }!.question, language: language)
                let reply = try XCTUnwrap(DemoGuide.reply(to: question, language: language), language.rawValue)
                XCTAssertEqual(reply.subject, subject)
                if language != .english { XCTAssertNotEqual(reply.answer, DemoGuide.reply(to: question, language: .english)?.answer) }
            }
            if language != .english {
                XCTAssertNotEqual(sample.trips.first?.title, english.trips.first?.title)
                XCTAssertNotEqual(sample.discoveries.first?.observation, english.discoveries.first?.observation)
                XCTAssertNotEqual(sample.discoveries.first?.explanation, english.discoveries.first?.explanation)
            }
            let reopened = try TripStore(fileURL: url, initial: sample)
            XCTAssertEqual(reopened.state, english, "Changing the app language must not rewrite existing stories.")
        }
    }

    func testDatesFollowTheExplicitLanguageInsteadOfThePhoneLanguage() {
        let date = Date(timeIntervalSince1970: 1_789_387_200)
        let french = L10n.date(date, language: .french)
        XCTAssertTrue(french.contains("sept."), french)
        let german = L10n.date(date, language: .german)
        XCTAssertTrue(german.contains("Sept."), german)
        let japanese = L10n.date(date, language: .japanese)
        XCTAssertTrue(japanese.contains("2026"), japanese)
        XCTAssertNotEqual(japanese, french)
        for language in AppLanguage.allCases {
            XCTAssertGreaterThan(L10n.date(date, includeTime: true, language: language).count, L10n.date(date, language: language).count)
        }
    }
}
