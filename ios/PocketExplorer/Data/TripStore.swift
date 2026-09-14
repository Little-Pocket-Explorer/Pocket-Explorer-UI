import Foundation
import Observation

@MainActor @Observable
final class TripStore {
    private(set) var state: JournalState
    let fileURL: URL
    private let write: (Data, URL) throws -> Void

    init(fileURL: URL, initial: JournalState = .examples(), writer: ((Data, URL) throws -> Void)? = nil) throws {
        self.fileURL = fileURL
        self.write = writer ?? { data, url in try data.write(to: url, options: .atomic) }
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            state = try JSONDecoder().decode(JournalState.self, from: Data(contentsOf: fileURL))
            guard state.version == 1 else { throw JournalError.invalidVersion }
        } else {
            state = initial
            try write(JSONEncoder().encode(initial), fileURL)
        }
    }

    static var defaultURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PocketExplorer/journal.json")
    }

    func discoveries(in tripID: UUID) -> [Discovery] {
        state.discoveries.filter { $0.tripID == tripID }
    }

    var questions: [ExplorationRecord] { state.explorations ?? [] }

    @discardableResult
    func beginQuestion(_ question: String, age: Int, photo: Data?, id: UUID = UUID(), now: Date = Date()) throws -> ExplorationRecord {
        let cleaned = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { throw JournalError.emptyQuestion }
        if let existing = questions.first(where: { $0.id == id }) { return existing }
        let filename = photo.map { _ in "question-\(id.uuidString).jpg" }
        let record = ExplorationRecord(id: id, question: cleaned, language: AppLanguage.current.rawValue, age: min(18, max(5, age)), createdAt: now, photoFilename: filename)
        var next = state
        next.explorations = [record] + questions
        if let photo, let filename { try photo.write(to: mediaURL(filename), options: .atomic) }
        do { try commit(next) }
        catch { if let filename { try? FileManager.default.removeItem(at: mediaURL(filename)) }; throw error }
        return record
    }

    func saveAnswer(_ reply: AIReply, for id: UUID) throws {
        guard reply.quiz.isValid, let index = questions.firstIndex(where: { $0.id == id }) else { throw JournalError.missingDiscovery }
        var next = state
        next.explorations?[index].reply = reply
        try commit(next)
    }

    @discardableResult
    func keepQuestion(_ id: UUID, observation: String = "", tripID existingTripID: UUID? = nil, place: Place? = nil, now: Date = Date()) throws -> Discovery {
        guard let question = questions.first(where: { $0.id == id }), let reply = question.reply else { throw JournalError.missingDiscovery }
        if let existing = state.discoveries.first(where: { $0.explorationID == id }) { return existing }
        if let existingTripID, !state.trips.contains(where: { $0.id == existingTripID }) { throw JournalError.missingTrip }
        let tripID = existingTripID ?? UUID()
        let record = Discovery(id: UUID(), tripID: tripID, subject: .discovery, question: question.question,
            observation: observation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? question.question : observation,
            explanation: reply.answer, createdAt: now, photoFilename: question.photoFilename, unlockedAt: now, origin: .exploration, tier: .fieldFind,
            ai: reply, explorationID: id, place: place)
        var next = state
        if existingTripID == nil { next.trips.insert(Trip(id: tripID, title: reply.title, startedAt: question.createdAt, place: place, isExample: false), at: 0) }
        else if let index = next.trips.firstIndex(where: { $0.id == tripID }), next.trips[index].place == nil { next.trips[index].place = place }
        next.discoveries.append(record)
        refreshMemory(in: &next, tripID: tripID)
        if let index = next.explorations?.firstIndex(where: { $0.id == id }) { next.explorations?[index].cardID = record.id }
        try commit(next)
        return record
    }

    func saveArtwork(_ job: ArtworkJob, discoveryID: UUID, image: Data? = nil) throws {
        guard let index = state.discoveries.firstIndex(where: { $0.id == discoveryID }) else { throw JournalError.missingDiscovery }
        guard UUID(uuidString: job.id) != nil else { throw JournalError.missingDiscovery }
        if image == nil, state.discoveries[index].artwork == job { return }
        var next = state
        next.discoveries[index].artwork = job
        let filename = "artwork-\(job.id).png"
        let oldImage = image == nil ? nil : try? Data(contentsOf: mediaURL(filename))
        if let image {
            try image.write(to: mediaURL(filename), options: .atomic)
            next.discoveries[index].artworkFilename = filename
        }
        do { try commit(next) }
        catch {
            if image != nil {
                if let oldImage { try? oldImage.write(to: mediaURL(filename), options: .atomic) }
                else { try? FileManager.default.removeItem(at: mediaURL(filename)) }
            }
            throw error
        }
    }

    func answerQuiz(discoveryID: UUID, choice: Int, now: Date = Date()) throws {
        guard let index = state.discoveries.firstIndex(where: { $0.id == discoveryID }),
              let quiz = state.discoveries[index].ai?.quiz, quiz.choices.indices.contains(choice) else { throw JournalError.missingDiscovery }
        var next = state
        next.discoveries[index].quizAnsweredAt = now
        next.discoveries[index].quizChoice = choice
        try commit(next)
    }

    @discardableResult
    func createTrip(title: String, place: Place?, now: Date = Date()) throws -> UUID {
        let id = UUID()
        var next = state
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        next.trips.insert(Trip(id: id, title: cleaned.isEmpty ? "A day of little wonders" : cleaned, startedAt: now, place: place, isExample: false), at: 0)
        try commit(next)
        return id
    }

    @discardableResult
    func addDiscovery(tripID: UUID, subject: DiscoverySubject, question: String, observation: String, explanation: String, photo: Data? = nil, id: UUID = UUID(), now: Date = Date()) throws -> Discovery {
        guard state.trips.contains(where: { $0.id == tripID }) else { throw JournalError.missingTrip }
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw JournalError.emptyQuestion }
        guard !observation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw JournalError.emptyObservation }
        if let existing = state.discoveries.first(where: { $0.id == id }) { return existing }
        let filename = photo.map { _ in "\(id.uuidString).jpg" }
        let record = Discovery(id: id, tripID: tripID, subject: subject, question: question, observation: observation, explanation: explanation, createdAt: now, photoFilename: filename, unlockedAt: now, origin: .exploration, tier: .fieldFind)
        var next = state
        next.discoveries.append(record)
        refreshMemory(in: &next, tripID: tripID)
        if let photo, let filename { try photo.write(to: mediaURL(filename), options: .atomic) }
        do { try commit(next) } catch {
            if let filename { try? FileManager.default.removeItem(at: mediaURL(filename)) }
            throw error
        }
        return record
    }

    func updateObservation(discoveryID: UUID, observation: String) throws {
        guard !observation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw JournalError.emptyObservation }
        guard let index = state.discoveries.firstIndex(where: { $0.id == discoveryID }) else { throw JournalError.missingDiscovery }
        var next = state
        next.discoveries[index].observation = observation
        refreshMemory(in: &next, tripID: next.discoveries[index].tripID)
        try commit(next)
    }

    func finishTrip(_ id: UUID, now: Date = Date()) throws {
        guard let index = state.trips.firstIndex(where: { $0.id == id }) else { throw JournalError.missingTrip }
        let found = discoveries(in: id)
        guard !found.isEmpty else { throw JournalError.emptyTrip }
        var next = state
        next.trips[index].completedAt = next.trips[index].completedAt ?? now
        next.trips[index].memory = MemoryBuilder.build(tripID: id, discoveries: found)
        try commit(next)
    }

    func dismissReminder(_ id: UUID, now: Date = Date()) throws {
        guard let index = state.trips.firstIndex(where: { $0.id == id }) else { throw JournalError.missingTrip }
        var next = state
        next.trips[index].dismissedUntil = now.addingTimeInterval(ReminderPolicy.interval)
        try commit(next)
    }

    func mediaURL(_ filename: String) -> URL {
        fileURL.deletingLastPathComponent().appendingPathComponent(URL(fileURLWithPath: filename).lastPathComponent)
    }

    private func refreshMemory(in next: inout JournalState, tripID: UUID) {
        guard let i = next.trips.firstIndex(where: { $0.id == tripID }), next.trips[i].completedAt != nil else { return }
        next.trips[i].memory = MemoryBuilder.build(tripID: tripID, discoveries: next.discoveries.filter { $0.tripID == tripID })
    }

    private func commit(_ next: JournalState) throws {
        try write(JSONEncoder().encode(next), fileURL)
        state = next
    }
}
