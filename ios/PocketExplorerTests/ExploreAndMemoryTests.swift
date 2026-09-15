import XCTest
@testable import PocketExplorer

final class ExploreAndMemoryTests: XCTestCase {
    func testLanguageSelectionAndSpeechLocales() throws {
        XCTAssertEqual(AppLanguage.resolve(["zh-Hans-CN", "en"]), .chinese)
        XCTAssertEqual(AppLanguage.resolve(["zh-Hant-TW"]), .chinese)
        XCTAssertEqual(AppLanguage.resolve(["en-AU", "zh-Hans"]), .english)
        XCTAssertEqual(AppLanguage.resolve([]), .english)
        XCTAssertEqual(AppLanguage.chinese.speechLocale, "zh-CN")
        XCTAssertEqual(AppLanguage.english.speechLocale, "en-AU")
        let bundle = Bundle(for: VoiceSession.self)
        for (language, expected) in [("en", "Start exploring"), ("zh-Hans", "开始探索")] {
            let path = try XCTUnwrap(bundle.path(forResource: language, ofType: "lproj"))
            let localized = try XCTUnwrap(Bundle(path: path))
            XCTAssertEqual(localized.localizedString(forKey: "Start exploring", value: nil, table: nil), expected)
        }
        XCTAssertFalse(L10n.text("Start exploring").isEmpty)
        XCTAssertEqual(LanguagePreference.system.resolve(["zh-Hans"]), .chinese)
        XCTAssertEqual(LanguagePreference.english.resolve(["zh-Hans"]), .english)
        XCTAssertEqual(LanguagePreference.chinese.resolve(["en"]), .chinese)
        let suite = "PocketLanguageTests-\(UUID())"
        let preferences = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { preferences.removePersistentDomain(forName: suite) }
        LanguageSettings.save(.chinese, to: preferences)
        let independent = try XCTUnwrap(UserDefaults(suiteName: suite))
        XCTAssertEqual(independent.string(forKey: "app-language"), "chinese")
        LanguageSettings.save(.system, to: preferences)
        XCTAssertEqual(independent.string(forKey: "app-language"), "system")
    }

    func testProfileSetupValidatesAndPersistsAnEmailAddress() throws {
        let suite = "PocketProfileTests-\(UUID())"
        let preferences = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { preferences.removePersistentDomain(forName: suite) }
        XCTAssertThrowsError(try ProfileSettings.save(email: "not an email", to: preferences))
        let profile = try ProfileSettings.save(email: " Kai@Example.com ", to: preferences)
        XCTAssertEqual(profile, ExplorerProfile(email: "kai@example.com", displayName: "Kai"))
        let data = try XCTUnwrap(preferences.data(forKey: "explorer-profile"))
        XCTAssertEqual(try JSONDecoder().decode(ExplorerProfile.self, from: data), profile)
    }

    func testGuideUnderstandsChineseAndUsesSelectedReplyLanguage() {
        for (question, subject) in [("鸭子怎么游泳？", DiscoverySubject.duck), ("這片葉子為什麼不同？", .leaf), ("貝殼住著誰？", .shell), ("海螺有什么？", .shell)] {
            let chinese = DemoGuide.reply(to: question, language: .chinese)
            let english = DemoGuide.reply(to: question, language: .english)
            XCTAssertEqual(chinese?.subject, subject)
            XCTAssertEqual(english?.subject, subject)
            XCTAssertNotEqual(chinese?.answer, english?.answer)
            XCTAssertNotEqual(chinese?.invitation, english?.invitation)
        }
        XCTAssertNil(DemoGuide.reply(to: "月亮为什么亮？", language: .chinese))
    }

    func testPrimaryActionFollowsSpeechAndKeepsTheObservationForReview() {
        var state = ExplorationState()
        XCTAssertEqual(state.primaryAction, .record)
        state.question = "  \n"
        XCTAssertEqual(state.primaryAction, .record)
        state.startListening()
        XCTAssertEqual(state.primaryAction, .finishQuestion)
        state.receiveTranscript("How do ducks swim?")
        XCTAssertEqual(state.primaryAction, .finishQuestion)
        state.stop()
        XCTAssertEqual(state.primaryAction, .ask)
        state.think()
        XCTAssertEqual(state.primaryAction, .wait)
        state.answer()
        XCTAssertEqual(state.primaryAction, .stopReply)
        state.beginObservation()
        XCTAssertEqual(state.primaryAction, .record)
        state.startListening()
        state.receiveTranscript("One foot pushed water backwards.")
        XCTAssertEqual(state.primaryAction, .finishObservation)
        state.stop()
        XCTAssertEqual(state.primaryAction, .save)
        XCTAssertEqual(state.observation, "One foot pushed water backwards.")
        XCTAssertTrue(state.canSave)
        state.fail("Interrupted")
        XCTAssertEqual(state.primaryAction, .save)
        XCTAssertEqual(state.question, "How do ducks swim?")
        state.observation = " \n"
        XCTAssertEqual(state.primaryAction, .record)
        XCTAssertFalse(state.canSave)
    }

    func testEmptyRecordingAndUnmatchedQuestionNeverUnlockACard() {
        var state = ExplorationState()
        state.startListening()
        state.receiveTranscript("")
        state.stop()
        XCTAssertEqual(state.primaryAction, .record)
        XCTAssertFalse(state.canSave)
        state.question = "Why is the moon bright?"
        state.think(); state.answer()
        XCTAssertEqual(state.primaryAction, .ask)
        XCTAssertEqual(state.question, "Why is the moon bright?")
        XCTAssertFalse(state.canSave)
    }

    func testGuideMatchesSubjectsAndRejectsUnrelatedQuestions() {
        for subject in DiscoverySubject.allCases {
            let reply = DemoGuide.reply(to: subject.sampleQuestion)
            XCTAssertEqual(reply?.subject, subject)
            XCTAssertFalse(reply!.answer.isEmpty)
            XCTAssertFalse(reply!.invitation.isEmpty)
        }
        XCTAssertEqual(DemoGuide.reply(to: "What is a LEAF?")?.subject, .leaf)
        XCTAssertNil(DemoGuide.reply(to: "How does the sun shine?"))
        XCTAssertNil(DemoGuide.reply(to: ""))
    }

    func testActualTextSurvivesVoiceTransitionsFailureAndRetry() {
        var state = ExplorationState()
        XCTAssertFalse(state.canSave)
        state.startListening()
        XCTAssertEqual(state.phase, .listening)
        state.receiveTranscript("How do ducks swim sideways?")
        state.stop()
        XCTAssertEqual(state.question, "How do ducks swim sideways?")
        state.think()
        XCTAssertEqual(state.phase, .thinking)
        state.answer()
        XCTAssertEqual(state.phase, .speaking)
        XCTAssertEqual(state.reply?.subject, .duck)
        state.beginObservation()
        state.startListening()
        state.receiveTranscript("I saw one foot move more than the other.")
        state.fail("Interrupted")
        XCTAssertEqual(state.phase, .failed)
        XCTAssertEqual(state.observation, "I saw one foot move more than the other.")
        state.stop()
        XCTAssertEqual(state.phase, .idle)
        XCTAssertTrue(state.canSave)
        state.startListening()
        XCTAssertNil(state.error)
        XCTAssertEqual(state.question, "How do ducks swim sideways?")
    }

    func testUnmatchedQuestionRemainsUnchanged() {
        var state = ExplorationState()
        state.question = "Why is the sky blue?"
        state.answer()
        XCTAssertEqual(state.phase, .failed)
        XCTAssertNil(state.reply)
        XCTAssertFalse(state.canSave)
        XCTAssertEqual(state.question, "Why is the sky blue?")
        state.question = "What are shells?"
        state.answer()
        state.observation = "  "
        XCTAssertFalse(state.canSave)
    }

    func testMemoryKeepsPersonalContentAndChosenOrder() {
        let state = JournalState.examples()
        let records = Array(state.discoveries.prefix(2).reversed())
        let memory = MemoryBuilder.build(tripID: records[0].tripID, discoveries: records)
        XCTAssertEqual(memory.chapters.count, 6)
        XCTAssertEqual(memory.chapters[0].text, records[0].question)
        XCTAssertEqual(memory.chapters[1].text, records[0].observation)
        XCTAssertEqual(memory.chapters[3].text, records[1].question)
        XCTAssertEqual(Set(memory.chapters.map(\.id)).count, 6)
        XCTAssertEqual(MemoryBuilder.build(tripID: UUID(), discoveries: []).chapters.count, 0)
        XCTAssertEqual(MemoryBuilder.build(tripID: UUID(), discoveries: [records[0]]).chapters.count, 3)
    }

    func testPlaybackPauseReplayCompletionAndInvalidSelection() {
        var player = MemoryPlayback(count: 3)
        player.tick()
        XCTAssertEqual(player.index, 0)
        player.play()
        player.tick()
        XCTAssertEqual(player.index, 1)
        player.pause()
        player.tick()
        XCTAssertEqual(player.index, 1)
        player.select(20)
        XCTAssertEqual(player.index, 1)
        player.select(2)
        XCTAssertFalse(player.isPlaying)
        player.play()
        XCTAssertEqual(player.index, 0)
        player.tick(); player.tick()
        XCTAssertEqual(player.index, 2)
        XCTAssertFalse(player.isPlaying)
        player.replay()
        XCTAssertEqual(player.index, 0)
        XCTAssertTrue(player.isPlaying)
        var empty = MemoryPlayback(count: 0)
        empty.play(); empty.replay()
        XCTAssertFalse(empty.isPlaying)
    }
}
