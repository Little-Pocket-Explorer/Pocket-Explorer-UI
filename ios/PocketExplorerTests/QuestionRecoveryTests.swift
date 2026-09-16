import XCTest
@testable import PocketExplorer

final class QuestionRecoveryTests: XCTestCase {
    private var client: AIClient!
    private let connection = ShareConnection(baseURL: "https://stories.example", ownerKey: String(repeating: "a", count: 40))
    private let record = ExplorationRecord(id: UUID(), question: "Why is the sky blue?", language: "en", age: 7, createdAt: Date())
    private let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Look at a cloud.", category: "science", artworkPrompt: "A blue sky",
                                quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air scatters light."))

    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockShareProtocol.self]
        client = AIClient(session: URLSession(configuration: configuration), permission: { _ in })
    }

    override func tearDown() { MockShareProtocol.reply = nil; SuspendedAIProtocol.onStart = nil; SuspendedAIProtocol.onStop = nil }

    func testPendingQuestionReadsTheSameIDWithoutAnotherPostAndReturnsTheActualAnswer() async throws {
        var requests = 0
        MockShareProtocol.reply = { request in
            requests += 1
            XCTAssertEqual(request.httpMethod, requests == 1 ? "POST" : "GET")
            if requests > 1 { XCTAssertEqual(request.url?.lastPathComponent, self.record.id.uuidString.lowercased()) }
            return (200, try JSONEncoder().encode(AIReceipt(id: self.record.id, question: self.record.question, status: requests < 3 ? "thinking" : "ready", reply: requests < 3 ? nil : self.reply)))
        }
        let result = try await client.answer(record, photo: nil, connection: connection, pollInterval: .milliseconds(1))
        XCTAssertEqual(result.reply, reply)
        XCTAssertEqual(requests, 3)
    }

    func testResumeReadsTheSavedAnswerWithoutReencodingOrPostingTheOldPhoto() async throws {
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            return (200, try JSONEncoder().encode(AIReceipt(id: self.record.id, question: self.record.question, status: "ready", reply: self.reply)))
        }
        let result = try await client.answer(record, photo: Data("old unsupported photo".utf8), connection: connection, resume: true)
        XCTAssertEqual(result.reply, reply)
    }

    func testResumePostsOnlyWhenTheSavedQuestionNeverReachedTheServer() async throws {
        var requests = 0
        MockShareProtocol.reply = { request in
            requests += 1
            XCTAssertEqual(request.httpMethod, requests == 1 ? "GET" : "POST")
            return requests == 1 ? (404, Data()) : (200, try JSONEncoder().encode(AIReceipt(id: self.record.id, question: self.record.question, status: "ready", reply: self.reply)))
        }
        _ = try await client.answer(record, photo: nil, connection: connection, resume: true)
        XCTAssertEqual(requests, 2)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "GET", "A failed saved answer requires an explicit re-ask before another POST.")
            return (200, try JSONEncoder().encode(AIReceipt(id: self.record.id, question: self.record.question, status: "failed", reply: nil)))
        }
        do { _ = try await client.answer(record, photo: nil, connection: connection, resume: true); XCTFail() }
        catch { XCTAssertEqual(error as? AIClientError, .answerFailed) }
    }
    func testMissingSavedPhotoStillResumesButCannotSilentlyResubmitWithoutIt() async throws {
        var original = record; original.photoFilename = "missing.jpg"
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            return (200, try JSONEncoder().encode(AIReceipt(id: self.record.id, question: self.record.question, status: "ready", reply: self.reply)))
        }
        let result = try await client.answer(original, photo: nil, connection: connection, resume: true)
        XCTAssertEqual(result.reply, reply)
        MockShareProtocol.reply = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            return (404, Data())
        }
        do { _ = try await client.answer(original, photo: nil, connection: connection, resume: true); XCTFail("Resubmitted without its original photo") }
        catch { XCTAssertEqual(error as? AIClientError, .photoUnreadable) }
    }

    func testFailedAndMalformedAnswersCannotRemainInAThinkingLoop() async {
        for (status, id, reply, expected) in [("failed", record.id, nil, AIClientError.answerFailed),
                                             ("unexpected", record.id, nil, .invalidResponse),
                                             ("ready", UUID(), self.reply, .invalidResponse),
                                             ("thinking", UUID(), nil, .invalidResponse),
                                             ("ready", record.id, nil, .invalidResponse)] {
            MockShareProtocol.reply = { _ in (200, try JSONEncoder().encode(AIReceipt(id: id, question: self.record.question, status: status, reply: reply))) }
            do { _ = try await client.answer(record, photo: nil, connection: connection); XCTFail("Expected a recoverable error") }
            catch { XCTAssertEqual(error as? AIClientError, expected) }
        }
    }

    func testOverallDeadlineCancelsEvenAnInitialRequestThatNeverReturns() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SuspendedAIProtocol.self]
        client = AIClient(session: URLSession(configuration: configuration), permission: { _ in })
        let stopped = expectation(description: "Timed-out URL task was cancelled")
        SuspendedAIProtocol.onStop = { stopped.fulfill() }
        let start = ContinuousClock.now
        do { _ = try await client.answer(record, photo: nil, connection: connection, deadline: .milliseconds(80)); XCTFail("Expected a bounded wait") }
        catch { XCTAssertEqual(error as? AIClientError, .pending) }
        XCTAssertLessThan(start.duration(to: .now), .seconds(2))
        await fulfillment(of: [stopped], timeout: 2)
    }

    func testExplicitCancellationDoesNotWaitForTheNetworkDeadline() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SuspendedAIProtocol.self]
        client = AIClient(session: URLSession(configuration: configuration), permission: { _ in })
        let started = expectation(description: "Request is waiting")
        let stopped = expectation(description: "Cancelled URL task")
        SuspendedAIProtocol.onStart = { started.fulfill() }
        SuspendedAIProtocol.onStop = { stopped.fulfill() }
        let task = Task { try await client.answer(record, photo: nil, connection: connection) }
        await fulfillment(of: [started], timeout: 2)
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
        await fulfillment(of: [stopped], timeout: 2)
    }

    func testQuotaAndNetworkErrorsOfferAccurateRecoveryWithoutExposingProviderDetails() async {
        for (code, expected) in [("demo_limit", AIClientError.demoLimit), ("daily_limit", .dailyLimit), ("image_retry_limit", .artworkLimit), ("please_wait", .rateLimited), ("unknown", .rateLimited)] {
            MockShareProtocol.reply = { _ in (429, Data("{\"error\":\"\(code)\"}".utf8)) }
            do { _ = try await client.ask(record, photo: nil, connection: connection); XCTFail() }
            catch { XCTAssertEqual(error as? AIClientError, expected) }
            XCTAssertFalse(expected.localizedDescription.contains(code))
        }
        for (code, expected) in [(URLError.timedOut, AIClientError.timedOut), (.notConnectedToInternet, .offline), (.networkConnectionLost, .offline), (.cannotFindHost, .unavailable)] {
            MockShareProtocol.reply = { _ in throw URLError(code) }
            do { _ = try await client.ask(record, photo: nil, connection: connection); XCTFail() }
            catch { XCTAssertEqual(error as? AIClientError, expected) }
        }
        MockShareProtocol.reply = { _ in (409, Data()) }
        do { _ = try await client.ask(record, photo: nil, connection: connection); XCTFail() }
        catch { XCTAssertEqual(error as? AIClientError, .requestConflict) }
        for error in [AIClientError.demoLimit, .dailyLimit, .artworkLimit, .requestConflict] { XCTAssertFalse(error.allowsImmediateRetry) }
        for error in [AIClientError.pending, .offline, .timedOut, .answerFailed] {
            XCTAssertTrue(error.allowsImmediateRetry)
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }
}

private final class SuspendedAIProtocol: URLProtocol {
    static var onStart: (() -> Void)?
    static var onStop: (() -> Void)?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() { Self.onStart?() }
    override func stopLoading() { Self.onStop?() }
}
