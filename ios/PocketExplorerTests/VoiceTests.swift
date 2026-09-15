import AVFoundation
import XCTest
@testable import PocketExplorer

@MainActor
final class FakeVoiceTransport: VoiceTransport {
    var onTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onFinishedSpeaking: (() -> Void)?
    var onFinishedListening: (() -> Void)?
    var onInterrupted: (() -> Void)?
    var microphone = true
    var speech = true
    var startError = false
    var speakError = false
    var starts = 0
    var stops = 0
    var played: Data?
    var playError = false
    func play(_ data: Data) throws { if playError { throw VoiceError.unavailable }; played = data }
    var spoken = ""
    var spokenLanguage = ""
    var recognitionLanguage = ""
    var finishing: (() -> Void)?
    var pendingMicrophone: CheckedContinuation<Bool, Never>?
    var pendingSpeech: CheckedContinuation<Bool, Never>?
    var delayMicrophone = false
    var delaySpeech = false
    func microphoneAllowed() async -> Bool {
        if delayMicrophone { return await withCheckedContinuation { pendingMicrophone = $0 } }
        return microphone
    }
    func speechAllowed() async -> Bool {
        if delaySpeech { return await withCheckedContinuation { pendingSpeech = $0 } }
        return speech
    }
    func startRecognition(language: String) throws { if startError { throw VoiceError.unavailable }; starts += 1; recognitionLanguage = language }
    func speak(_ text: String, language: String) throws { if speakError { throw VoiceError.unavailable }; spoken = text; spokenLanguage = language }
    func stop() { stops += 1 }
    func finishRecognition() async { finishing?() }
}

@MainActor
final class VoiceTests: XCTestCase {
    func testInterruptionEndDoesNotInterruptANewSession() async {
        let hardware = SystemVoiceTransport()
        let unexpected = expectation(description: "Ended and malformed interruptions are ignored")
        unexpected.isInverted = true
        unexpected.assertForOverFulfill = false
        hardware.onInterrupted = { unexpected.fulfill() }
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue])
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: nil)
        await fulfillment(of: [unexpected], timeout: 0.2)
    }

    func testFinishingAcceptsTheLastTranscriptAndPreservesTheTypedPrefix() async throws {
        let hardware = FakeVoiceTransport()
        let voice = VoiceSession(transport: hardware)
        let draft = DictationDraft(original: "I wonder why")
        var text = draft.original
        var finished = 0
        voice.onTranscript = { text = draft.applying($0) }
        voice.onFinishedListening = { finished += 1 }
        try await voice.start()
        hardware.onTranscript?("the sky")
        XCTAssertEqual(text, "I wonder why the sky")
        hardware.finishing = { hardware.onTranscript?("the sky is blue") }
        await voice.finish()
        XCTAssertEqual(text, "I wonder why the sky is blue")
        XCTAssertEqual(finished, 1)
        hardware.onTranscript?("an obsolete result")
        XCTAssertEqual(text, "I wonder why the sky is blue")
        XCTAssertEqual(DictationDraft(original: "").applying(" hello "), "hello")
        XCTAssertEqual(DictationDraft(original: "Keep these words").applying("  "), "Keep these words")
        try await voice.start()
        hardware.onFinishedListening?()
        XCTAssertEqual(finished, 2)
    }

    func testCancellingARecordingDuringFinishDoesNotReportAStaleCompletion() async throws {
        let hardware = FakeVoiceTransport()
        let voice = VoiceSession(transport: hardware)
        var completed = 0
        voice.onFinishedListening = { completed += 1 }
        try await voice.start()
        hardware.finishing = { voice.stop() }
        await voice.finish()
        XCTAssertEqual(completed, 0)
        let system = SystemVoiceTransport()
        await system.finishRecognition()
        system.stop()
    }
    func testSavedContentLanguageReachesTheVoiceRegardlessOfTheInterfaceLanguage() async throws {
        let hardware = FakeVoiceTransport()
        let voice = VoiceSession(transport: hardware)
        try voice.speak("天空像一张蓝色的画布。", language: "zh-Hans")
        XCTAssertEqual(hardware.spokenLanguage, "zh-Hans")
        try voice.speak("The sky is blue.", language: "en")
        XCTAssertEqual(hardware.spokenLanguage, "en")
        try await voice.start(language: "fr-FR")
        XCTAssertEqual(hardware.recognitionLanguage, "fr-FR")
    }
    func testPermissionErrorsExplainRecoveryAndUnavailableSpeechOffersTyping() {
        for error in [VoiceError.microphoneDenied, .speechDenied] {
            let message = error.localizedDescription
            XCTAssertTrue(message.contains("Settings") || message.contains("设置"))
        }
        let unavailable = VoiceError.unavailable.localizedDescription
        XCTAssertTrue(unavailable.contains("type") || unavailable.contains("打字"))
    }
    func testActualTranscriptsAreForwardedAndInterruptionPreservesWordsWithoutRestart() async throws {
        let hardware = FakeVoiceTransport()
        let voice = VoiceSession(transport: hardware)
        var exploration = ExplorationState()
        exploration.question = "Existing words"
        voice.onTranscript = { exploration.receiveTranscript($0) }
        voice.onInterrupted = { exploration.stop() }
        voice.onError = { exploration.fail($0) }
        try await voice.start()
        exploration.startListening()
        hardware.onTranscript?("How do these ducks move?")
        XCTAssertEqual(exploration.question, "How do these ducks move?")
        let oldTranscript = hardware.onTranscript
        hardware.onInterrupted?()
        oldTranscript?("stale recognition")
        XCTAssertEqual(exploration.question, "How do these ducks move?")
        XCTAssertEqual(exploration.phase, .idle)
        XCTAssertEqual(hardware.starts, 1)
        try await voice.start()
        hardware.onError?("Recognition interrupted")
        XCTAssertEqual(exploration.error, "Recognition interrupted")
        XCTAssertEqual(exploration.question, "How do these ducks move?")
    }
    func testDeniedPermissionsNeverStartCaptureAndKeepExistingInput() async {
        for microphoneDenied in [true, false] {
            let hardware = FakeVoiceTransport()
            hardware.microphone = !microphoneDenied
            hardware.speech = microphoneDenied
            let voice = VoiceSession(transport: hardware)
            var exploration = ExplorationState(); exploration.question = "My question"
            do { try await voice.start(); XCTFail("Expected denial") }
            catch { exploration.fail(error.localizedDescription) }
            XCTAssertEqual(hardware.starts, 0)
            XCTAssertEqual(exploration.question, "My question")
            XCTAssertTrue(exploration.error!.contains("type"))
        }
    }
    func testCancellationDuringEitherPermissionPromptCannotRestartRecording() async {
        for microphonePending in [true, false] {
            let hardware = FakeVoiceTransport()
            hardware.delayMicrophone = microphonePending
            hardware.delaySpeech = !microphonePending
            let voice = VoiceSession(transport: hardware)
            let task = Task { try await voice.start() }
            while hardware.pendingMicrophone == nil && hardware.pendingSpeech == nil { await Task.yield() }
            voice.stop()
            hardware.pendingMicrophone?.resume(returning: true)
            hardware.pendingSpeech?.resume(returning: true)
            do { try await task.value; XCTFail("Expected cancellation") } catch { XCTAssertTrue(error is CancellationError) }
            XCTAssertEqual(hardware.starts, 0)
        }
    }
    func testFailedStartAndStaleSpeechCompletionDoNotAffectANewSession() async throws {
        let hardware = FakeVoiceTransport()
        let voice = VoiceSession(transport: hardware)
        var completed = 0
        voice.onFinishedSpeaking = { completed += 1 }
        try voice.speak("Look a little closer.")
        XCTAssertEqual(hardware.spoken, "Look a little closer.")
        let stale = hardware.onFinishedSpeaking
        voice.stop(); stale?()
        XCTAssertEqual(completed, 0)
        try voice.speak("A new reply."); hardware.onFinishedSpeaking?()
        XCTAssertEqual(completed, 1)
        hardware.startError = true
        do { try await voice.start(); XCTFail() } catch { XCTAssertTrue(hardware.stops > 0) }
        hardware.speakError = true
        XCTAssertThrowsError(try voice.speak("Unavailable"))
    }
    func testSystemInterruptionAdapterAndCameraPhotoEncoding() async throws {
        let hardware = SystemVoiceTransport()
        let interrupted = expectation(description: "System interruption forwarded")
        hardware.onInterrupted = { interrupted.fulfill() }
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance(),
                                        userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        await fulfillment(of: [interrupted], timeout: 3)
        hardware.stop()
        var imageData: Data?
        var canceled = 0
        let camera = CameraCapture(onPhoto: { imageData = $0 }, onCancel: { canceled += 1 })
        let coordinator = camera.makeCoordinator()
        let picker = UIImagePickerController()
        let image = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20)).image { context in UIColor.green.setFill(); context.fill(CGRect(x: 0, y: 0, width: 20, height: 20)) }
        coordinator.imagePickerController(picker, didFinishPickingMediaWithInfo: [.originalImage: image])
        XCTAssertNotNil(imageData.flatMap(UIImage.init(data:)))
        coordinator.imagePickerController(picker, didFinishPickingMediaWithInfo: [:])
        coordinator.imagePickerControllerDidCancel(picker)
        XCTAssertEqual(canceled, 2)
    }
}
