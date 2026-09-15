import Foundation
import Observation

@MainActor @Observable
final class AnswerPresentation {
    private(set) var text = ""
    private(set) var visibleText = ""
    private(set) var hiddenText = ""
    private(set) var generation = UUID()
    private(set) var isRevealing = false
    @ObservationIgnored private var characters: [Character] = []

    func begin(_ text: String, animated: Bool) {
        generation = UUID()
        self.text = text
        characters = Array(text)
        isRevealing = animated && characters.count > 1
        show(isRevealing ? 1 : characters.count)
    }

    func reveal(generation expected: UUID? = nil, sleep: (Duration) async throws -> Void = { try await Task.sleep(for: $0) }) async {
        guard isRevealing, expected == nil || expected == generation else { return }
        let token = generation
        let steps = min(160, characters.count)
        do {
            for step in 1...steps {
                try await sleep(.milliseconds(45))
                guard token == generation, !Task.isCancelled else { return }
                show(max(1, characters.count * step / steps))
            }
            isRevealing = false
        } catch {
            if token == generation { finish() }
        }
    }

    func finish() {
        generation = UUID()
        show(characters.count)
        isRevealing = false
    }

    private func show(_ count: Int) {
        visibleText = String(characters.prefix(count))
        hiddenText = String(characters.dropFirst(count))
    }
}
