import XCTest
@testable import PocketExplorer

@MainActor
final class ArtworkRecoveryTests: XCTestCase {
    private var directory: URL!
    private var store: TripStore!
    private var discovery: Discovery!
    private var coordinator: ArtworkCoordinator!

    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let question = try store.beginQuestion("Why is the sky blue?", age: 7, photo: nil)
        let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Look away from the sun.", category: "science", artworkPrompt: "A blue sky",
                            quiz: DiscoveryQuiz(question: "What scatters light?", choices: ["Air", "Paint", "Moon"], correctIndex: 0, explanation: "Air scatters light."))
        try store.saveAnswer(reply, for: question.id)
        discovery = try store.keepQuestion(question.id)
        coordinator = ArtworkCoordinator()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockShareProtocol.self]
        coordinator.client = AIClient(session: URLSession(configuration: configuration))
    }

    override func tearDown() async throws {
        MockShareProtocol.reply = nil
        try? FileManager.default.removeItem(at: directory)
    }

    func testAReadFailureDoesNotPermanentlyStopArtworkRecovery() async throws {
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "working", attempts: 1)
        try store.saveArtwork(job, discoveryID: discovery.id)
        var reads = 0
        MockShareProtocol.reply = { request in
            reads += 1
            XCTAssertEqual(request.httpMethod, "GET", "Recovery must read the existing job without generating again.")
            return reads == 1 ? (503, Data()) : (200, try JSONEncoder().encode(job))
        }
        await coordinator.update(store.state.discoveries[0], store: store)
        XCTAssertNotNil(coordinator.errors[discovery.id])
        await coordinator.update(store.state.discoveries[0], store: store)
        XCTAssertEqual(reads, 2, "A temporary read failure must not disable every future status check.")
        XCTAssertNil(coordinator.errors[discovery.id])
        XCTAssertEqual(try TripStore(fileURL: store.fileURL).state.discoveries.count, 1)
    }

    func testExhaustedAllowancesHaveAccurateCopyAndStopBackgroundRequests() async throws {
        for (code, expected) in [("daily_limit", AIClientError.dailyLimit), ("demo_limit", .demoLimit), ("image_retry_limit", .artworkLimit)] {
            let coordinator = ArtworkCoordinator()
            coordinator.client = self.coordinator.client
            var requests = 0
            MockShareProtocol.reply = { _ in
                requests += 1
                return (429, Data("{\"error\":\"\(code)\"}".utf8))
            }
            let now = Date(timeIntervalSince1970: 2000000000)
            await coordinator.refresh(store: store, now: now)
            XCTAssertEqual(coordinator.errors[discovery.id], expected.localizedDescription)
            XCTAssertTrue(coordinator.stopped.contains(discovery.id))
            await coordinator.refresh(store: store, now: now.addingTimeInterval(300))
            XCTAssertEqual(requests, 1, "An exhausted allowance is not a temporary network outage.")
            if code == "daily_limit" {
                let job = ArtworkJob(id: UUID().uuidString, status: "working", attempts: 1)
                MockShareProtocol.reply = { _ in requests += 1; return (200, try JSONEncoder().encode(job)) }
                await coordinator.refresh(store: store, now: now.addingTimeInterval(86400))
                XCTAssertEqual(requests, 2)
                XCTAssertFalse(coordinator.stopped.contains(discovery.id))
            }
        }
    }

    func testUnchangedArtworkChecksDoNotRewriteTheJournal() async throws {
        var writes = 0
        store = try TripStore(fileURL: store.fileURL, writer: { data, url in
            writes += 1
            try data.write(to: url, options: .atomic)
        })
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "working", attempts: 1)
        try store.saveArtwork(job, discoveryID: discovery.id)
        XCTAssertEqual(writes, 1)
        MockShareProtocol.reply = { _ in (200, try JSONEncoder().encode(job)) }
        await coordinator.update(store.state.discoveries[0], store: store)
        await coordinator.update(store.state.discoveries[0], store: store)
        XCTAssertEqual(writes, 1, "Polling an unchanged job must not rewrite and invalidate the whole journal.")
        XCTAssertEqual(try TripStore(fileURL: store.fileURL).state.discoveries[0].artwork, job)
    }

    func testBackgroundChecksBackOffWithoutBlockingAnExplicitCheck() async throws {
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "working", attempts: 1)
        try store.saveArtwork(job, discoveryID: discovery.id)
        var requests = 0
        MockShareProtocol.reply = { _ in requests += 1; return (503, Data()) }
        let now = Date()
        await coordinator.refresh(store: store, now: now)
        await coordinator.refresh(store: store, now: now.addingTimeInterval(5))
        XCTAssertEqual(requests, 1)
        await coordinator.refresh(store: store, now: now.addingTimeInterval(10))
        await coordinator.refresh(store: store, now: now.addingTimeInterval(20))
        XCTAssertEqual(requests, 2)
        MockShareProtocol.reply = { _ in requests += 1; return (200, try JSONEncoder().encode(job)) }
        await coordinator.update(discovery, store: store, retry: true, now: now.addingTimeInterval(21))
        XCTAssertEqual(requests, 3)
        XCTAssertNil(coordinator.errors[discovery.id])
        await coordinator.refresh(store: store, now: now.addingTimeInterval(26))
        XCTAssertEqual(requests, 4)
    }

    func testStaleCardSnapshotCannotGenerateAgainAfterTheImageWasSaved() async throws {
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "ready", attempts: 1)
        try store.saveArtwork(job, discoveryID: discovery.id, image: Data("already saved".utf8))
        MockShareProtocol.reply = { _ in XCTFail("A stale view must not repeat completed artwork work."); return (503, Data()) }
        await coordinator.update(discovery, store: store)
        XCTAssertTrue(coordinator.busy.isEmpty)
    }

    func testArtworkStatesExplainLongWaitsOfflineRecoveryAndExhaustedRetries() {
        let now = Date(timeIntervalSince1970: 2000000)
        discovery.createdAt = now
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .waiting)
        discovery.artwork = ArtworkJob(id: UUID().uuidString, status: "working", attempts: 1, updatedAt: now.timeIntervalSince1970 * 1000)
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .drawing)
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now.addingTimeInterval(31)), .slow)
        XCTAssertEqual(ArtworkProgress.resolve(discovery, error: "Offline", now: now), .paused)
        discovery.artwork?.expiresAt = now.timeIntervalSince1970 * 1000
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .paused)
        discovery.artwork?.status = "failed"
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .failed)
        discovery.artwork?.attempts = 2
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .exhausted)
        discovery.artwork?.attempts = 1
        discovery.artwork?.canRetry = false
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .exhausted)
        discovery.artworkFilename = "saved.png"
        XCTAssertEqual(ArtworkProgress.resolve(discovery, error: "Old failure", now: now), .ready)
        discovery.artworkFilename = nil
        discovery.ai = nil
        XCTAssertEqual(ArtworkProgress.resolve(discovery, now: now), .ready)
        for state in [ArtworkProgress.ready, .waiting, .drawing, .slow, .paused, .failed, .exhausted, .unavailable] {
            XCTAssertFalse(state.title.isEmpty)
            XCTAssertFalse(state.message.isEmpty)
            XCTAssertFalse(state.symbol.isEmpty)
        }
        XCTAssertEqual(ArtworkProgress.failed.action, "Try illustration again")
        XCTAssertEqual(ArtworkProgress.paused.action, "Check illustration")
        XCTAssertEqual(ArtworkProgress.slow.action, "Check illustration")
        XCTAssertNil(ArtworkProgress.exhausted.action)
        XCTAssertNil(ArtworkProgress.unavailable.action)
        discovery.ai = store.state.discoveries[0].ai
        XCTAssertEqual(ArtworkProgress.resolve(discovery, error: "Limit", stopped: true, now: now), .unavailable)
    }

    func testCheckingAnActiveJobCannotAccidentallyStartAnotherGeneration() async throws {
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "working", attempts: 1)
        try store.saveArtwork(job, discoveryID: discovery.id)
        var reads = 0
        MockShareProtocol.reply = { request in
            reads += 1
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertLessThanOrEqual(request.timeoutInterval, 20)
            XCTAssertFalse(request.url!.path.hasSuffix("/retry"))
            return (200, try JSONEncoder().encode(job))
        }
        await coordinator.update(store.state.discoveries[0], store: store, retry: true)
        XCTAssertEqual(reads, 1)
    }

    func testFailedJobRequiresAnExplicitPermittedRetryAndKeepsItsIdentity() async throws {
        var job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "failed", attempts: 1)
        try store.saveArtwork(job, discoveryID: discovery.id)
        var requests = 0
        MockShareProtocol.reply = { request in
            requests += 1
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url!.path, "/api/artwork/\(job.id)/retry")
            var queued = job; queued.status = "queued"
            return (200, try JSONEncoder().encode(queued))
        }
        await coordinator.update(store.state.discoveries[0], store: store)
        XCTAssertEqual(requests, 0)
        await coordinator.update(store.state.discoveries[0], store: store, retry: true)
        XCTAssertEqual(requests, 1)
        XCTAssertEqual(store.state.discoveries[0].artwork?.id, job.id)
        job.attempts = 2
        try store.saveArtwork(job, discoveryID: discovery.id)
        await coordinator.update(store.state.discoveries[0], store: store, retry: true)
        XCTAssertEqual(requests, 1)
    }

    func testACompletedJobIdentitySurvivesAnInterruptedImageDownload() async throws {
        let job = ArtworkJob(id: UUID().uuidString.lowercased(), status: "ready", attempts: 1)
        MockShareProtocol.reply = { request in
            if request.url!.path.hasSuffix("/artwork") { return (202, try JSONEncoder().encode(job)) }
            return (503, Data())
        }
        await coordinator.update(discovery, store: store)
        let persisted = try TripStore(fileURL: store.fileURL).state.discoveries[0]
        XCTAssertEqual(persisted.artwork?.id, job.id)
        XCTAssertNil(persisted.artworkFilename)
        XCTAssertNotNil(coordinator.errors[discovery.id])
        XCTAssertFalse(coordinator.busy.contains(discovery.id))
    }
}
