import AVFoundation
import XCTest
@testable import PocketExplorer

@MainActor
final class FakeVoiceTransport: VoiceTransport {
    var onTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onFinishedSpeaking: (() -> Void)?
    var onInterrupted: (() -> Void)?
    var microphone = true
    var speech = true
    var startError = false
    var speakError = false
    var starts = 0
    var stops = 0
    var spoken = ""
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
    func startRecognition() throws { if startError { throw VoiceError.unavailable }; starts += 1 }
    func speak(_ text: String) throws { if speakError { throw VoiceError.unavailable }; spoken = text }
    func stop() { stops += 1 }
}

@MainActor
final class VoiceTests: XCTestCase {
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
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
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
