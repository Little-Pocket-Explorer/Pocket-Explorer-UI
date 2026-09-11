import Foundation

struct GuideReply: Equatable {
    var subject: DiscoverySubject
    var answer: String
    var invitation: String
}

enum DemoGuide {
    static func reply(to question: String, language: AppLanguage = .current) -> GuideReply? {
        let text = question.lowercased()
        if text.contains("duck") || text.contains("鸭") || text.contains("鴨") {
            if language == .chinese {
                return GuideReply(subject: .duck, answer: "鸭子的脚趾之间有蹼，像小船桨一样向后推水，让身体向前游。", invitation: "仔细看看鸭子游泳时的脚，你发现了什么？")
            }
            return GuideReply(subject: .duck, answer: "Ducks use their webbed feet to push against the water.", invitation: "Watch a duck for a moment. What do its feet do when it moves?")
        }
        if text.contains("leaf") || text.contains("leaves") || text.contains("叶") || text.contains("葉") {
            if language == .chinese {
                return GuideReply(subject: .leaf, answer: "树叶有不同的形状、边缘和叶脉，就像每片叶子都有自己的花纹。", invitation: "找两片落叶，比一比它们的边缘，有什么不同？")
            }
            return GuideReply(subject: .leaf, answer: "Leaves come in many shapes, with different edges and patterns of veins.", invitation: "Find two fallen leaves. What is different about their edges?")
        }
        if text.contains("shell") || text.contains("贝壳") || text.contains("貝殼") || text.contains("海螺") {
            if language == .chinese {
                return GuideReply(subject: .shell, answer: "许多身体柔软的海洋动物会长出壳，保护自己的身体。", invitation: "看看贝壳的形状和开口，你发现了哪些细节？")
            }
            return GuideReply(subject: .shell, answer: "Many soft-bodied sea animals grow shells to protect themselves.", invitation: "Look at its shape and opening. What details can you spot?")
        }
        return nil
    }
}

enum VoicePhase: String, Equatable {
    case idle, listening, thinking, speaking, failed
}

struct ExplorationState: Equatable {
    enum Stage { case question, observation }
    enum Action { case record, finishQuestion, finishObservation, ask, save, stopReply, wait }
    var stage: Stage = .question
    private(set) var phase: VoicePhase = .idle
    var question = ""
    var observation = ""
    private(set) var reply: GuideReply?
    private(set) var error: String?

    var primaryAction: Action {
        if phase == .thinking { return .wait }
        if phase == .speaking { return .stopReply }
        if phase == .listening { return stage == .question ? .finishQuestion : .finishObservation }
        let input = stage == .question ? question : observation
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return .record }
        return stage == .question ? .ask : .save
    }

    mutating func startListening() { error = nil; phase = .listening }
    mutating func receiveTranscript(_ text: String) {
        if stage == .question { question = text } else { observation = text }
    }
    mutating func stop() { phase = .idle }
    mutating func fail(_ message: String) { error = message; phase = .failed }
    mutating func think() { phase = .thinking; error = nil; reply = nil }
    mutating func answer() {
        guard let answer = DemoGuide.reply(to: question) else {
            fail(L10n.text("This demo explores ducks, leaves and shells. Try a question about one of them."))
            return
        }
        reply = answer
        phase = .speaking
    }
    mutating func beginObservation() { stage = .observation; phase = .idle }
    var canSave: Bool {
        reply != nil && !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !observation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
