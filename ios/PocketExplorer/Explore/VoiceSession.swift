import AVFoundation
import Foundation
import Speech

@MainActor
protocol VoiceTransport: AnyObject {
    var onTranscript: ((String) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onFinishedSpeaking: (() -> Void)? { get set }
    var onFinishedListening: (() -> Void)? { get set }
    var onInterrupted: (() -> Void)? { get set }
    func microphoneAllowed() async -> Bool
    func speechAllowed() async -> Bool
    func startRecognition(language: String) throws
    func speak(_ text: String, language: String) throws
    func finishRecognition() async
    func stop()
}

@MainActor
final class VoiceSession {
    var onTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onFinishedSpeaking: (() -> Void)?
    var onFinishedListening: (() -> Void)?
    var onInterrupted: (() -> Void)?
    private let transport: VoiceTransport
    private var generation = UUID()

    init(transport: VoiceTransport? = nil) {
        self.transport = transport ?? SystemVoiceTransport()
        self.transport.onInterrupted = { [weak self] in self?.stop(); self?.onInterrupted?() }
    }
    func start(language: String = AppLanguage.current.rawValue) async throws {
        try Task.checkCancellation()
        stop()
        let token = generation
        let microphone = await transport.microphoneAllowed()
        guard token == generation, !Task.isCancelled else { throw CancellationError() }
        guard microphone else { throw VoiceError.microphoneDenied }
        let speech = await transport.speechAllowed()
        guard token == generation, !Task.isCancelled else { throw CancellationError() }
        guard speech else { throw VoiceError.speechDenied }
        transport.onTranscript = { [weak self] text in
            guard let self, token == self.generation else { return }
            self.onTranscript?(text)
        }
        transport.onError = { [weak self] error in
            guard let self, token == self.generation else { return }
            self.stop(); self.onError?(error)
        }
        transport.onFinishedListening = { [weak self] in
            guard let self, token == self.generation else { return }
            self.stop(); self.onFinishedListening?()
        }
        do { try transport.startRecognition(language: language) }
        catch { stop(); throw error }
    }

    func finish() async {
        let token = generation
        await transport.finishRecognition()
        guard token == generation else { return }
        stop(); onFinishedListening?()
    }
    func speak(_ text: String, language: String = AppLanguage.current.rawValue) throws {
        stop()
        let token = generation
        transport.onFinishedSpeaking = { [weak self] in
            guard let self, token == self.generation else { return }
            self.onFinishedSpeaking?()
        }
        do { try transport.speak(text, language: language) }
        catch { stop(); throw error }
    }
    func stop() { generation = UUID(); transport.stop() }
}

@MainActor
final class SystemVoiceTransport: NSObject, VoiceTransport, AVSpeechSynthesizerDelegate {
    var onTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onFinishedSpeaking: (() -> Void)?
    var onFinishedListening: (() -> Void)?
    var onInterrupted: (() -> Void)?
    private let engine = AVAudioEngine()
    private let speaker = AVSpeechSynthesizer()
    private var recognition: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var hasTap = false
    private var generation = UUID()
    private var activeUtterance: AVSpeechUtterance?
    private var interruptionObserver: NSObjectProtocol?

    override init() {
        super.init()
        speaker.delegate = self
        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] notification in
            guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: raw) == .began else { return }
            Task { @MainActor in self?.stop(); self?.onInterrupted?() }
        }
    }
    deinit { if let interruptionObserver { NotificationCenter.default.removeObserver(interruptionObserver) } }
    func microphoneAllowed() async -> Bool {
        await withCheckedContinuation { continuation in AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) } }
    }
    func speechAllowed() async -> Bool {
        let status = await withCheckedContinuation { continuation in SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) } }
        return status == .authorized
    }
    func startRecognition(language: String) throws {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: NarrationStyle.locale(for: language))), recognizer.isAvailable else { throw VoiceError.unavailable }
        let token = generation
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
        try session.setActive(true)
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { throw VoiceError.unavailable }
        let bufferRequest = SFSpeechAudioBufferRecognitionRequest()
        bufferRequest.shouldReportPartialResults = true
        bufferRequest.addsPunctuation = true
        request = bufferRequest
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in bufferRequest.append(buffer) }
        hasTap = true
        engine.prepare()
        try engine.start()
        recognition = recognizer.recognitionTask(with: bufferRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self, token == self.generation else { return }
                if let result { self.onTranscript?(result.bestTranscription.formattedString) }
                if result?.isFinal == true { self.stop(); self.onFinishedListening?() }
                else if error != nil { self.stop(); self.onError?(VoiceError.unavailable.localizedDescription) }
            }
        }
    }

    func finishRecognition() async {
        let token = generation
        engine.stop()
        if hasTap { engine.inputNode.removeTap(onBus: 0); hasTap = false }
        request?.endAudio()
        recognition?.finish()
        for _ in 0..<20 {
            guard token == generation, recognition != nil else { return }
            do { try await Task.sleep(for: .milliseconds(100)) } catch { return }
        }
    }
    func speak(_ text: String, language: String) throws {
        let utterances = NarrationStyle.utterances(text, language: language)
        guard let last = utterances.last, last.voice != nil else { throw VoiceError.unavailable }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio)
        try session.setActive(true)
        activeUtterance = last
        for utterance in utterances { speaker.speak(utterance) }
    }
    func stop() {
        generation = UUID()
        recognition?.cancel(); recognition = nil
        engine.stop()
        if hasTap { engine.inputNode.removeTap(onBus: 0); hasTap = false }
        request?.endAudio(); request = nil
        activeUtterance = nil
        speaker.stopSpeaking(at: .immediate)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard activeUtterance === utterance else { return }
            activeUtterance = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            onFinishedSpeaking?()
        }
    }
}

enum VoiceError: LocalizedError {
    case microphoneDenied, speechDenied, unavailable
    var errorDescription: String? {
        switch self {
        case .microphoneDenied: return L10n.text("Microphone access is off. Enable it in Settings, or type below.")
        case .speechDenied: return L10n.text("Speech recognition is off. Enable it in Settings, or type below.")
        case .unavailable: return L10n.text("Speech is not available right now. You can try again or type your discovery.")
        }
    }
}
