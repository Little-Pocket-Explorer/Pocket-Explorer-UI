import AVFoundation
import XCTest
@testable import PocketExplorer

@MainActor
final class NarrationRenderTests: XCTestCase {
    func testSystemPlaybackCompletesOnlyAfterTheLastSentenceAndCancellationStaysSilent() async throws {
        let transport = SystemVoiceTransport()
        let finished = expectation(description: "Both sentences finished")
        var completions = 0
        transport.onFinishedSpeaking = { completions += 1; finished.fulfill() }
        XCTAssertThrowsError(try transport.speak("   ", language: "en"))
        let started = Date()
        try transport.speak("Look at the sky. Can you find a cloud?", language: "en")
        await fulfillment(of: [finished], timeout: 20)
        XCTAssertEqual(completions, 1)
        XCTAssertGreaterThan(Date().timeIntervalSince(started), 1)
        let cancelled = expectation(description: "Cancelled playback must not finish")
        cancelled.isInverted = true
        transport.onFinishedSpeaking = { cancelled.fulfill() }
        try transport.speak("A leaf can catch the sunlight.", language: "en")
        transport.stop()
        await fulfillment(of: [cancelled], timeout: 1)
    }

    func testEnglishAndChineseNarrationRenderNonSilentAudio() async throws {
        let synthesizer = AVSpeechSynthesizer()
        for (language, text) in [("en", "A leaf catches sunlight, a little like a tiny solar panel."),
                                 ("zh-Hans", "叶子会接住阳光，就像一块小小的太阳能板。") ] {
            let utterance = try XCTUnwrap(NarrationStyle.utterances(text, language: language).first)
            XCTAssertNotNil(utterance.voice)
            let destination = FileManager.default.temporaryDirectory.appendingPathComponent("pocket-voice-\(language)-\(UUID()).caf")
            defer { try? FileManager.default.removeItem(at: destination) }
            let rendered = expectation(description: "Rendered \(language) narration")
            let output = NarrationCapture(url: destination)
            synthesizer.write(utterance) { buffer in
                guard let pcm = buffer as? AVAudioPCMBuffer else { return }
                if pcm.frameLength == 0 { if output.finishOnce() { rendered.fulfill() } }
                else { output.append(pcm) }
            }
            await fulfillment(of: [rendered], timeout: 20)
            synthesizer.stopSpeaking(at: .immediate)
            try output.closeAndVerify()
            let attachment = XCTAttachment(contentsOfFile: destination)
            attachment.name = "gentle-narration-\(language)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}

private final class NarrationCapture {
    private let lock = NSLock()
    private let url: URL
    private var file: AVAudioFile?
    private var failure: Error?
    private var frames: AVAudioFramePosition = 0
    private var audible = false
    private var finished = false

    init(url: URL) { self.url = url }

    func finishOnce() -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard !finished else { return false }
        finished = true
        return true
    }

    func append(_ buffer: AVAudioPCMBuffer) {
        lock.lock(); defer { lock.unlock() }
        do {
            if file == nil { file = try AVAudioFile(forWriting: url, settings: buffer.format.settings) }
            try file?.write(from: buffer)
            frames += AVAudioFramePosition(buffer.frameLength)
            if let samples = buffer.floatChannelData?[0] {
                audible = audible || (0..<Int(buffer.frameLength)).contains { abs(samples[$0]) > 0.001 }
            }
        } catch { failure = error }
    }

    func closeAndVerify() throws {
        lock.lock(); defer { lock.unlock() }
        file = nil
        if let failure { throw failure }
        XCTAssertTrue(audible, "Synthesized audio must contain an audible signal.")
        let readback = try AVAudioFile(forReading: url)
        XCTAssertEqual(readback.length, frames)
        XCTAssertGreaterThan(Double(readback.length) / readback.fileFormat.sampleRate, 1)
    }
}
