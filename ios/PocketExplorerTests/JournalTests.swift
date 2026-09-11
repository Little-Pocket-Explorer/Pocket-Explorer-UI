import XCTest
@testable import PocketExplorer

@MainActor
final class JournalTests: XCTestCase {
    private var directory: URL!

    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private var fileURL: URL { directory.appendingPathComponent("journal.json") }

    func testSeedsPersistAcrossIndependentInstances() throws {
        let first = try TripStore(fileURL: fileURL)
        XCTAssertEqual(first.state.trips.count, 3)
        XCTAssertEqual(first.discoveries(in: first.state.trips[0].id).count, 2)
        let second = try TripStore(fileURL: fileURL, initial: JournalState(trips: [], discoveries: []))
        XCTAssertEqual(second.state, first.state)
        XCTAssertEqual(Set(second.state.discoveries.map(\.subject)), Set(DiscoverySubject.allCases))
    }

    func testCreateSavePhotoEditAndFinishSurviveReload() throws {
        let store = try TripStore(fileURL: fileURL)
        let trip = try store.createTrip(title: "  Our adventure  ", place: nil)
        let observation = "  The feet moved backwards!  "
        let photo = Data([0xFF, 0xD8, 0xFF])
        let record = try store.addDiscovery(tripID: trip, subject: .duck, question: "How do ducks swim?", observation: observation, explanation: "Webbed feet push water.", photo: photo)
        var reload = try TripStore(fileURL: fileURL)
        XCTAssertEqual(reload.discoveries(in: trip).first?.observation, observation)
        XCTAssertEqual(reload.discoveries(in: trip).first?.unlockedAt, record.createdAt)
        XCTAssertEqual(reload.discoveries(in: trip).first?.origin, .exploration)
        XCTAssertEqual(reload.discoveries(in: trip).first?.tier, .fieldFind)
        XCTAssertEqual(try Data(contentsOf: reload.mediaURL(record.photoFilename!)), photo)
        XCTAssertEqual(reload.state.trips[0].title, "Our adventure")
        XCTAssertNil(reload.state.trips[0].place)
        try store.finishTrip(trip, now: Date(timeIntervalSince1970: 1000))
        try store.finishTrip(trip, now: Date(timeIntervalSince1970: 2000))
        try store.updateObservation(discoveryID: record.id, observation: "I watched the webbed feet.")
        reload = try TripStore(fileURL: fileURL)
        XCTAssertEqual(reload.state.trips[0].completedAt, Date(timeIntervalSince1970: 1000))
        XCTAssertEqual(reload.state.trips[0].memory?.chapters[1].text, "I watched the webbed feet.")
        XCTAssertEqual(reload.discoveries(in: trip).count, 1)
        let duplicate = try store.addDiscovery(tripID: trip, subject: .duck, question: "Repeat", observation: "Repeat", explanation: "Repeat", id: record.id)
        XCTAssertEqual(duplicate.id, record.id)
        XCTAssertEqual(store.discoveries(in: trip).count, 1)
        _ = try store.addDiscovery(tripID: trip, subject: .leaf, question: "A leaf?", observation: "I saw veins.", explanation: "They transport water.")
        XCTAssertEqual(store.state.trips[0].memory?.chapters.count, 6)
    }

    func testInvalidInputDoesNotChangeState() throws {
        let store = try TripStore(fileURL: fileURL)
        let id = try store.createTrip(title: " ", place: .sydney)
        XCTAssertEqual(store.state.trips[0].title, "A day of little wonders")
        let baseline = store.state
        XCTAssertThrowsError(try store.addDiscovery(tripID: UUID(), subject: .duck, question: "Duck?", observation: "Feet", explanation: "Water"))
        XCTAssertThrowsError(try store.addDiscovery(tripID: id, subject: .duck, question: " ", observation: "Feet", explanation: "Water"))
        XCTAssertThrowsError(try store.addDiscovery(tripID: id, subject: .duck, question: "Duck?", observation: "\n ", explanation: "Water"))
        XCTAssertThrowsError(try store.updateObservation(discoveryID: UUID(), observation: "Something"))
        XCTAssertThrowsError(try store.updateObservation(discoveryID: store.state.discoveries[0].id, observation: " "))
        XCTAssertThrowsError(try store.finishTrip(id))
        XCTAssertThrowsError(try store.finishTrip(UUID()))
        XCTAssertThrowsError(try store.dismissReminder(UUID()))
        XCTAssertEqual(store.state, baseline)
    }

    func testFailedWritePreservesSavedStateAndRemovesUncommittedPhoto() throws {
        let first = try TripStore(fileURL: fileURL)
        let baseline = first.state
        let store = try TripStore(fileURL: fileURL, writer: { _, _ in throw CocoaError(.fileWriteNoPermission) })
        let recordID = UUID()
        XCTAssertThrowsError(try store.addDiscovery(tripID: baseline.trips[0].id, subject: .duck, question: "Duck?", observation: "I noticed feet", explanation: "Water", photo: Data([1]), id: recordID))
        XCTAssertEqual(store.state, baseline)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.mediaURL("\(recordID).jpg").path))
        XCTAssertEqual(try TripStore(fileURL: fileURL).state, baseline)
        XCTAssertThrowsError(try store.createTrip(title: "Not saved", place: nil))
        XCTAssertEqual(store.state, baseline)
    }

    func testCorruptAndUnsupportedJournalsAreNotOverwritten() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let corrupt = Data("not json".utf8)
        try corrupt.write(to: fileURL)
        XCTAssertThrowsError(try TripStore(fileURL: fileURL))
        XCTAssertEqual(try Data(contentsOf: fileURL), corrupt)
        var future = JournalState.examples()
        future.version = 50
        let encoded = try JSONEncoder().encode(future)
        try encoded.write(to: fileURL)
        XCTAssertThrowsError(try TripStore(fileURL: fileURL))
        XCTAssertEqual(try Data(contentsOf: fileURL), encoded)
    }

    func testLegacyDiscoveriesDecodeWithoutUnlockMetadata() throws {
        let encoded = try JSONEncoder().encode(JournalState.examples())
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        var discoveries = try XCTUnwrap(object["discoveries"] as? [[String: Any]])
        for index in discoveries.indices {
            discoveries[index].removeValue(forKey: "unlockedAt")
            discoveries[index].removeValue(forKey: "origin")
            discoveries[index].removeValue(forKey: "tier")
        }
        object["discoveries"] = discoveries
        let legacy = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(JournalState.self, from: legacy)
        XCTAssertTrue(decoded.discoveries.allSatisfy { $0.unlockedAt == nil && $0.origin == nil && $0.tier == nil })
    }

    func testReminderBoundariesAndPersistence() throws {
        let store = try TripStore(fileURL: fileURL)
        let trip = store.state.trips[0]
        let due = trip.completedAt!.addingTimeInterval(ReminderPolicy.interval)
        XCTAssertFalse(ReminderPolicy.isEligible(trip, now: due.addingTimeInterval(-1)))
        XCTAssertTrue(ReminderPolicy.isEligible(trip, now: due))
        try store.dismissReminder(trip.id, now: due)
        let read = try TripStore(fileURL: fileURL).state.trips[0]
        XCTAssertFalse(ReminderPolicy.isEligible(read, now: due.addingTimeInterval(ReminderPolicy.interval - 1)))
        XCTAssertTrue(ReminderPolicy.isEligible(read, now: due.addingTimeInterval(ReminderPolicy.interval)))
        var unfinished = trip
        unfinished.completedAt = nil
        XCTAssertFalse(ReminderPolicy.isEligible(unfinished, now: due))
        XCTAssertNotNil(read.memory)
    }
}
