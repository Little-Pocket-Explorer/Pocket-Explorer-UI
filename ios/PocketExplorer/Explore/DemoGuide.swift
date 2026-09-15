import Foundation

struct GuideReply: Equatable {
    var subject: DiscoverySubject
    var answer: String
    var invitation: String
}

enum DemoGuide {
    static func reply(to question: String, language: AppLanguage = .current) -> GuideReply? {
        let text = question.precomposedStringWithCompatibilityMapping.lowercased()
        let subjects: [(DiscoverySubject, String, String, String)] = [
            (.duck, #"duck|鸭|鴨|pato|canard|\benten?\b|アヒル|あひる|오리|البط|بطة"#,
             "Ducks use their webbed feet to push against the water.", "Watch a duck for a moment. What do its feet do when it moves?"),
            (.leaf, #"leaf|leaves|叶|葉|hoja|feuille|blatt|blätter|folha|잎|أوراق|ورقة"#,
             "Leaves come in many shapes, with different edges and patterns of veins.", "Find two fallen leaves. What is different about their edges?"),
            (.shell, #"shell|贝壳|貝殼|海螺|concha|coquill|muschel|貝|かいがら|조개|صدف|أصداف"#,
             "Many soft-bodied sea animals grow shells to protect themselves.", "Look at its shape and opening. What details can you spot?")
        ]
        for (subject, pattern, answer, invitation) in subjects where text.range(of: pattern, options: .regularExpression) != nil {
            return GuideReply(subject: subject, answer: L10n.text(answer, language: language), invitation: L10n.text(invitation, language: language))
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
