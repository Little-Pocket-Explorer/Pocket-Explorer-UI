import XCTest
import UIKit
@testable import PocketExplorer

@MainActor
final class AIExplorationTests: XCTestCase {
    private var directory: URL!
    private let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "What colour do you see?", category: "science", artworkPrompt: "Blue sky and white clouds",
                                quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air scatters light."))
    private let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    private var fileURL: URL { directory.appendingPathComponent("journal.json") }
    private var client: AIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockShareProtocol.self]
        return AIClient(session: URLSession(configuration: configuration))
    }
    override func setUp() async throws { directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString) }
    override func tearDown() async throws { try? FileManager.default.removeItem(at: directory); MockShareProtocol.reply = nil }

    func testLegacyAndGeneratedCardsKeepStableFilterCategories() {
        let originals = JournalState.examples().discoveries
        XCTAssertEqual(originals.map(\.categoryID), ["animals", "nature", "nature", "animals"])
        var card = originals[0]
        card.subject = .discovery
        XCTAssertEqual(card.categoryID, "science")
        var answer = reply; answer.category = "space"
        card.ai = answer
        XCTAssertEqual(card.categoryID, "space")
    }

    func testLegacyJournalsGainQuestionsWithoutLosingExistingDiscoveries() throws {
        let original = JournalState.examples()
        var encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(original)) as? [String: Any])
        encoded.removeValue(forKey: "explorations")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONSerialization.data(withJSONObject: encoded).write(to: fileURL)
        let store = try TripStore(fileURL: fileURL)
        XCTAssertEqual(store.questions, [])
        XCTAssertEqual(store.state.discoveries, original.discoveries)
        let question = try store.beginQuestion("  Why is the sky blue?  ", age: 50, photo: Data([1, 2]))
        XCTAssertEqual(question.question, "Why is the sky blue?")
        XCTAssertEqual(question.age, 18)
        XCTAssertEqual(try store.beginQuestion("Same request", age: 7, photo: nil, id: question.id), question)
        let reopened = try TripStore(fileURL: fileURL)
        XCTAssertEqual(reopened.questions, [question])
        XCTAssertEqual(try Data(contentsOf: reopened.mediaURL(question.photoFilename!)), Data([1, 2]))
        XCTAssertEqual(reopened.state.discoveries, original.discoveries)
        XCTAssertThrowsError(try store.beginQuestion("  ", age: 7, photo: nil))
    }

    func testQuestionAnswerCardArtworkQuizAndSharedMetadataSurviveIndependentReloads() throws {
        let store = try TripStore(fileURL: fileURL, initial: JournalState(trips: [], discoveries: []))
        let question = try store.beginQuestion("Why is the sky blue?", age: 3, photo: nil)
        XCTAssertEqual(question.age, 5)
        XCTAssertThrowsError(try store.keepQuestion(question.id))
        try store.saveAnswer(reply, for: question.id)
        let discovery = try store.keepQuestion(question.id, place: .sydney)
        XCTAssertEqual(discovery.title, reply.title)
        XCTAssertEqual(discovery.category, "Science")
        XCTAssertEqual(discovery.subject, .discovery)
        XCTAssertEqual(discovery.place, .sydney)
        XCTAssertFalse(ReminderPolicy.isEligible(discovery, now: discovery.createdAt.addingTimeInterval(86399)))
        XCTAssertTrue(ReminderPolicy.isEligible(discovery, now: discovery.createdAt.addingTimeInterval(86400)))
        XCTAssertEqual(discovery.observation, question.question)
        XCTAssertEqual(try store.keepQuestion(question.id).id, discovery.id)
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "ready", attempts: 1, imagePath: nil)
        try store.saveArtwork(job, discoveryID: discovery.id, image: Data([3, 4]))
        try store.answerQuiz(discoveryID: discovery.id, choice: 2)
        try store.finishTrip(discovery.tripID)
        let reopened = try TripStore(fileURL: fileURL)
        let card = reopened.state.discoveries[0]
        XCTAssertEqual(card.ai, reply)
        XCTAssertEqual(card.quizChoice, 2)
        XCTAssertNil(card.quizAnsweredAt)
        XCTAssertFalse(card.isUnlocked)
        XCTAssertTrue(ReminderPolicy.isEligible(card, now: card.createdAt.addingTimeInterval(172800)))
        XCTAssertEqual(reopened.state.discoveries.count, 1, "A wrong quiz answer must keep the observation.")
        XCTAssertEqual(try Data(contentsOf: reopened.mediaURL(card.artworkFilename!)), Data([3, 4]))
        XCTAssertTrue(PublicStory.make(trip: reopened.state.trips[0], discoveries: [card]).cards.isEmpty)
        try reopened.answerQuiz(discoveryID: card.id, choice: 0)
        let earned = try TripStore(fileURL: fileURL).state.discoveries[0]
        XCTAssertTrue(earned.isUnlocked)
        let story = PublicStory.make(trip: reopened.state.trips[0], discoveries: [earned])
        XCTAssertEqual(story.cards.count, 1)
        XCTAssertEqual(story.cards[0].title, reply.title)
        XCTAssertEqual(story.cards[0].artworkID, job.id)
        XCTAssertNil(story.city)
        let exported = String(data: try JSONEncoder().encode(story), encoding: .utf8)!
        for field in ["latitude", "longitude", "artworkPrompt", "photoFilename", "ownerKey", "quiz"] { XCTAssertFalse(exported.contains(field)) }
    }

    func testAddingASecondQuestionToAnExistingTripRefreshesItsMemory() throws {
        let store = try TripStore(fileURL: fileURL)
        let trip = store.state.trips[0]
        let question = try store.beginQuestion("Another question", age: 7, photo: nil)
        try store.saveAnswer(reply, for: question.id)
        XCTAssertThrowsError(try store.keepQuestion(question.id, tripID: UUID()))
        let card = try store.keepQuestion(question.id, observation: "I saw blue", tripID: trip.id)
        XCTAssertEqual(card.tripID, trip.id)
        XCTAssertEqual(card.observation, "I saw blue")
        XCTAssertEqual(store.state.trips.count, 3)
        XCTAssertEqual(store.state.trips[0].memory?.chapters.count, 9)
        XCTAssertThrowsError(try store.answerQuiz(discoveryID: card.id, choice: 10))
        XCTAssertThrowsError(try store.saveAnswer(reply, for: UUID()))
        var invalid = reply; invalid.quiz.correctIndex = 10
        XCTAssertThrowsError(try store.saveAnswer(invalid, for: question.id))
        XCTAssertThrowsError(try store.saveArtwork(ArtworkJob(id: "wrong", status: "ready", attempts: 1), discoveryID: card.id))
    }

    func testFailedWritesKeepTheOldJournalAndRemoveUncommittedMedia() throws {
        let store = try TripStore(fileURL: fileURL)
        let question = try store.beginQuestion("Sky?", age: 7, photo: nil)
        try store.saveAnswer(reply, for: question.id)
        let card = try store.keepQuestion(question.id)
        let baseline = store.state
        let failing = try TripStore(fileURL: fileURL, writer: { _, _ in throw CocoaError(.fileWriteNoPermission) })
        let id = UUID()
        XCTAssertThrowsError(try failing.beginQuestion("Another", age: 7, photo: Data([1]), id: id))
        XCTAssertFalse(FileManager.default.fileExists(atPath: failing.mediaURL("question-\(id).jpg").path))
        let job = ArtworkJob(id: UUID().uuidString, status: "ready", attempts: 1)
        XCTAssertThrowsError(try failing.saveArtwork(job, discoveryID: card.id, image: Data([1])))
        XCTAssertFalse(FileManager.default.fileExists(atPath: failing.mediaURL("artwork-\(job.id).png").path))
        try Data([9]).write(to: failing.mediaURL("artwork-\(job.id).png"))
        XCTAssertThrowsError(try failing.saveArtwork(job, discoveryID: card.id, image: Data([1])))
        XCTAssertEqual(try Data(contentsOf: failing.mediaURL("artwork-\(job.id).png")), Data([9]))
        XCTAssertEqual(try TripStore(fileURL: fileURL).state, baseline)
    }

    func testHTTPClientUsesInstallationAuthorizationAndPreservesProviderIndependentPayloads() async throws {
        let record = ExplorationRecord(id: UUID(), question: "天空为什么是蓝色的？", language: "zh-Hans", age: 7, createdAt: Date())
        let receipt = AIReceipt(id: record.id, question: record.question, status: "ready", reply: reply)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/explorations")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            let body = try JSONSerialization.jsonObject(with: Self.body(request)) as! [String: Any]
            XCTAssertEqual(body["question"] as? String, record.question)
            XCTAssertEqual(body["language"] as? String, "zh-Hans")
            XCTAssertEqual(body["id"] as? String, record.id.uuidString.lowercased())
            XCTAssertTrue((body["photo"] as? String)?.hasPrefix("data:image/jpeg;base64,") == true)
            XCTAssertNil(body["model"])
            return (200, try JSONEncoder().encode(receipt))
        }
        let asked = try await client.ask(record, photo: Self.png(), connection: connection)
        XCTAssertEqual(asked, receipt)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.url?.path, "/api/explorations/\(record.id.uuidString.lowercased())")
            return (200, try JSONEncoder().encode(receipt))
        }
        let read = try await client.read(record.id, connection: connection)
        XCTAssertEqual(read, receipt)
        XCTAssertNil(AIClient.imageInput(Data([0])))
        do { _ = try await client.ask(record, photo: Data([0]), connection: connection); XCTFail() }
        catch { XCTAssertTrue(error.localizedDescription.contains("photo")) }
    }

    func testArtworkTransportValidatesPathsPixelsAndFailureResponses() async throws {
        let id = UUID().uuidString.lowercased()
        let job = ArtworkJob(id: id, status: "ready", attempts: 1, imagePath: "/api/artwork/\(id)/image")
        MockShareProtocol.reply = { _ in (202, try JSONEncoder().encode(job)) }
        let created = try await client.createArtwork(UUID(), connection: connection)
        XCTAssertEqual(created, job)
        let loaded = try await client.artwork(id, connection: connection)
        XCTAssertEqual(loaded, job)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "POST"); XCTAssertTrue(request.url!.path.hasSuffix("/retry"))
            return (202, try JSONEncoder().encode(job))
        }
        let retried = try await client.artwork(id, retry: true, connection: connection)
        XCTAssertEqual(retried, job)
        let png = Self.png()
        MockShareProtocol.reply = { _ in (200, png) }
        let image = try await client.image(job, connection: connection)
        XCTAssertEqual(image, png)
        for candidate in [ArtworkJob(id: "wrong", status: "ready", attempts: 1), ArtworkJob(id: id, status: "queued", attempts: 0), ArtworkJob(id: id, status: "ready", attempts: 1, imagePath: "https://untrusted/image")] {
            do { _ = try await client.image(candidate, connection: connection); XCTFail() } catch {}
        }
        for code in [429, 503, 200] {
            MockShareProtocol.reply = { _ in (code, Data([0])) }
            do { _ = try await client.artwork(id, connection: connection); XCTFail() } catch { XCTAssertFalse(error.localizedDescription.isEmpty) }
        }
        MockShareProtocol.reply = { _ in (200, Data([0])) }
        do { _ = try await client.image(job, connection: connection); XCTFail() } catch {}
        do { _ = try await client.artwork("invalid", connection: connection); XCTFail() } catch {}
        do { _ = try await client.read(UUID(), connection: ShareConnection(baseURL: "bad", ownerKey: "x")); XCTFail() } catch {}
        for failure in [AIClientError.unavailable, .invalidResponse, .rateLimited, .pending, .photoUnreadable] { XCTAssertFalse(failure.localizedDescription.isEmpty) }
    }

    private static func png() -> Data {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024), format: format).pngData { context in
            UIColor.green.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
        }
    }

    private static func body(_ request: URLRequest) -> Data {
        if let data = request.httpBody { return data }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open(); defer { stream.close() }
        var data = Data(); var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable { let count = stream.read(&buffer, maxLength: buffer.count); if count <= 0 { break }; data.append(buffer, count: count) }
        return data
    }
}
