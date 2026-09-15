import XCTest
@testable import PocketExplorer

@MainActor final class RecallProgressionTests: XCTestCase {
    func testNewObservationWaitsForCorrectRecallBeforeCardUnlock() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let question = try store.beginQuestion("Why is the sky blue?", age: 7, photo: nil)
        let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Look away from the sun.", category: "science", artworkPrompt: "Blue sky", quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "The moon"], correctIndex: 0, explanation: "Air scatters blue light."))
        try store.saveAnswer(reply, for: question.id)
        let card = try store.keepQuestion(question.id)
        XCTAssertNil(card.unlockedAt, "A newly saved observation must wait for recall before unlocking its card.")
        try store.answerQuiz(discoveryID: card.id, choice: 1)
        XCTAssertNil(store.state.discoveries[0].unlockedAt, "A wrong answer must preserve the observation without unlocking the card.")
        try store.answerQuiz(discoveryID: card.id, choice: 0)
        XCTAssertNotNil(store.state.discoveries[0].unlockedAt)
    }
}
