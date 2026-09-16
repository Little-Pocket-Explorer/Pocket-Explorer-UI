import Foundation
import Observation

@MainActor @Observable
final class TripStore {
    private(set) var state: JournalState
    let fileURL: URL
    let recommendations: RecommendationStore
    let demo: DemoStore
    let events: EventStore
    let social: SocialStore
    let family: FamilyStore
    let recall = RecallCoordinator()
    private let write: (Data, URL) throws -> Void

    init(fileURL: URL, initial: JournalState = .examples(), writer: ((Data, URL) throws -> Void)? = nil, bundledContent: [PreparedContent]? = nil) throws {
        self.fileURL = fileURL
        self.recommendations = RecommendationStore(file: fileURL.deletingLastPathComponent().appendingPathComponent("recommendations.json"), bundled: bundledContent)
        self.demo = DemoStore(file: fileURL.deletingLastPathComponent().appendingPathComponent("demo.json"))
        self.events = EventStore(file: fileURL.deletingLastPathComponent().appendingPathComponent("events.json"))
        self.social = try SocialStore(file: fileURL.deletingLastPathComponent().appendingPathComponent("social.json"))
        self.family = try FamilyStore(file: fileURL.deletingLastPathComponent().appendingPathComponent("family.json"))
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
    func beginPrepared(_ content: PreparedContent, age: Int, id: UUID = UUID(), now: Date = Date()) throws -> ExplorationRecord {
        guard content.isEligible(language: AppLanguage.current.rawValue, age: age, at: now) else { throw AIClientError.requestConflict }
        if let existing = questions.first(where: { $0.id == id }) { return existing }
        let record = ExplorationRecord(id: id, question: content.question, language: content.language, age: age, createdAt: now,
            reply: content.reply, preparedContent: content, preparedRegistered: false)
        var next = state
        next.explorations = [record] + questions
        try commit(next)
        return record
    }

    func markPreparedRegistered(_ id: UUID, artwork: ArtworkJob) throws {
        guard let index = questions.firstIndex(where: { $0.id == id }), questions[index].preparedContent != nil, artwork.status == "ready", UUID(uuidString: artwork.id) != nil else { throw AIClientError.invalidResponse }
        var next = state
        next.explorations?[index].preparedRegistered = true
        next.explorations?[index].preparedArtwork = artwork
        next.explorations?[index].preparedUnavailable = nil
        if let card = next.discoveries.firstIndex(where: { $0.explorationID == id }) { next.discoveries[card].artwork = artwork }
        try commit(next)
    }

    func markPreparedUnavailable(_ id: UUID) throws {
        guard let index = questions.firstIndex(where: { $0.id == id }), questions[index].preparedContent != nil else { throw JournalError.missingDiscovery }
        var next = state
        next.explorations?[index].preparedUnavailable = true
        try commit(next)
    }

    func preparedContentNeedsUpdate(_ id: UUID?) -> Bool {
        guard let record = questions.first(where: { $0.id == id }), let content = record.preparedContent else { return false }
        return record.preparedUnavailable == true || recommendations.isWithdrawn(content.reference)
    }

    func savePreparedArtwork(_ image: Data, discoveryID: UUID, asset: PreparedAsset) throws {
        guard let index = state.discoveries.firstIndex(where: { $0.id == discoveryID }), PreparedAssets().valid(image, for: asset) else { throw AIClientError.invalidArtwork }
        let filename = "prepared-\(asset.sha256).png"
        try image.write(to: mediaURL(filename), options: .atomic)
        var next = state
        next.discoveries[index].artworkFilename = filename
        try commit(next)
    }

    @discardableResult
    func beginQuestion(_ question: String, age: Int, photo: Data?, id: UUID = UUID(), now: Date = Date(), parentID: UUID? = nil, evolveFrom: String? = nil) throws -> ExplorationRecord {
        let cleaned = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { throw JournalError.emptyQuestion }
        if let existing = questions.first(where: { $0.id == id }) { return existing }
        let filename = photo.map { _ in "question-\(id.uuidString).jpg" }
        let parent = questions.first { $0.id == parentID }
        if parentID != nil && parent?.reply == nil { throw JournalError.missingDiscovery }
        let record = ExplorationRecord(id: id, question: cleaned, language: AppLanguage.current.rawValue, age: min(18, max(5, family.family?.profile.age ?? age)), createdAt: now, photoFilename: filename,
            conversationID: parent.map { $0.conversationID ?? $0.id }, parentID: parentID, evolveFrom: evolveFrom)
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
    func keepQuestion(_ id: UUID, observation: String = "", tripID existingTripID: UUID? = nil, place: Place? = nil, now: Date = Date(), preparedImage: Data? = nil) throws -> Discovery {
        guard let question = questions.first(where: { $0.id == id }), let reply = question.reply else { throw JournalError.missingDiscovery }
        if let existing = state.discoveries.first(where: { $0.explorationID == id }) { return existing }
        if let existingTripID, !state.trips.contains(where: { $0.id == existingTripID }) { throw JournalError.missingTrip }
        let tripID = existingTripID ?? UUID()
        var record = Discovery(id: UUID(), tripID: tripID, subject: .discovery, question: question.question,
            observation: observation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? question.question : observation,
            explanation: reply.answer, createdAt: now, photoFilename: question.photoFilename, unlockedAt: nil, origin: .exploration, tier: .common,
            ai: reply, explorationID: id, artwork: question.preparedArtwork, place: place, language: question.language, unlockRequired: true, evolvesFrom: question.evolveFrom)
        if let preparedImage, let asset = question.preparedContent?.artwork {
            guard PreparedAssets().valid(preparedImage, for: asset) else { throw AIClientError.invalidArtwork }
            let filename = "prepared-\(asset.sha256).png"
            try preparedImage.write(to: mediaURL(filename), options: .atomic)
            record.artworkFilename = filename
        }
        var next = state
        if existingTripID == nil { next.trips.insert(Trip(id: tripID, title: reply.title, startedAt: question.createdAt, place: place, isExample: false, language: question.language), at: 0) }
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

    func answerQuiz(discoveryID: UUID, choice: Int, now: Date = Date(), attemptID: UUID = UUID()) throws {
        guard let index = state.discoveries.firstIndex(where: { $0.id == discoveryID }),
              let quiz = state.discoveries[index].ai?.quiz, quiz.choices.indices.contains(choice) else { throw JournalError.missingDiscovery }
        var next = state
        next.discoveries[index].quizChoice = choice
        let discovery = state.discoveries[index]
        if discovery.isUnlocked && discovery.quizAnsweredAt != nil {
            next.discoveries[index].recallReviewedAt = now
            try commit(next)
            return
        }
        if discovery.unlockRequired != true {
            next.discoveries[index].quizAnsweredAt = now
        } else {
            if discovery.quizAnsweredAt != nil { return }
            if let previous = (state.recallAttempts ?? []).first(where: { $0.id == attemptID }) {
                guard previous.discoveryID == discoveryID, previous.choice == choice else { throw CollectibleError.requestConflict }
                return
            }
            if choice == quiz.correctIndex && (discovery.evolvesFrom == nil || discovery.ai?.advancesCard == true) {
                next.discoveries[index].quizAnsweredAt = now
                next.discoveries[index].unlockedAt = now
            }
            guard let explorationID = discovery.explorationID else { throw JournalError.missingDiscovery }
            next.recallAttempts = (next.recallAttempts ?? []) + [RecallAttempt(id: attemptID, discoveryID: discoveryID, explorationID: explorationID, choice: choice, createdAt: now)]
        }
        try commit(next)
    }

    func applyRecall(_ receipt: RecallReceipt, attemptID: UUID) throws {
        guard let attempt = state.recallAttempts?.first(where: { $0.id == attemptID }) else { return }
        guard let discovery = state.discoveries.first(where: { $0.id == attempt.discoveryID }),
              receipt.correctIndex == discovery.ai?.quiz.correctIndex,
              receipt.correct == (attempt.choice == receipt.correctIndex) else { throw CollectibleError.invalidResponse }
        var next = state
        if let card = receipt.collectible {
            guard receipt.correct, card.isValid, card.id == discovery.collectionID,
                  let version = card.versions.first(where: { $0.explorationID == attempt.explorationID.uuidString.lowercased() }),
                  version.reply == discovery.ai else { throw CollectibleError.invalidResponse }
            for index in next.discoveries.indices where next.discoveries[index].collectionID == card.id {
                next.discoveries[index].collectible = card
                next.discoveries[index].tier = card.tier
                if next.discoveries[index].id == discovery.id {
                    next.discoveries[index].unlockedAt = Date(timeIntervalSince1970: version.awardedAt / 1000)
                    next.discoveries[index].quizAnsweredAt = attempt.createdAt
                }
            }
        } else if receipt.correct { throw CollectibleError.invalidResponse }
        next.recallAttempts?.removeAll { $0.id == attemptID }
        try commit(next)
    }

    func failRecall(_ id: UUID, code: String) throws {
        guard let index = state.recallAttempts?.firstIndex(where: { $0.id == id }) else { return }
        var next = state
        next.recallAttempts?[index].failure = code
        if let attempt = next.recallAttempts?[index],
           let found = next.discoveries.firstIndex(where: { $0.id == attempt.discoveryID }),
           next.discoveries[found].unlockRequired == true,
           !next.discoveries[found].isVerified {
            next.discoveries[found].unlockedAt = nil
            next.discoveries[found].quizAnsweredAt = nil
        }
        try commit(next)
    }

    func saveCardStyle(_ card: KnowledgeCard) throws {
        guard card.isValid, state.discoveries.contains(where: { $0.collectible?.id == card.id }) else { throw CollectibleError.invalidResponse }
        var next = state
        for index in next.discoveries.indices where next.discoveries[index].collectible?.id == card.id { next.discoveries[index].collectible = card }
        try commit(next)
    }

    @discardableResult
    func receiveCard(_ card: KnowledgeCard, place: Place? = nil) throws -> Discovery {
        guard card.isValid, let latest = card.versions.last, let explorationID = UUID(uuidString: latest.explorationID) else { throw CollectibleError.invalidResponse }
        if let existing = state.discoveries.first(where: { $0.collectionID == card.id && $0.explorationID == explorationID }) {
            try saveCardStyle(card)
            return state.discoveries.first { $0.id == existing.id }!
        }
        let awarded = Date(timeIntervalSince1970: card.createdAt / 1000), tripID = UUID()
        let artwork = latest.artworkID.map { ArtworkJob(id: $0, status: "ready", attempts: 0, imagePath: "/api/artwork/\($0)/image") }
        let discovery = Discovery(id: UUID(), tripID: tripID, subject: .discovery, question: latest.question, observation: latest.question,
            explanation: latest.reply.answer, createdAt: awarded, unlockedAt: awarded, origin: card.origin?.kind == "event" ? .exploration : .gift,
            tier: card.tier, ai: latest.reply, explorationID: explorationID, artwork: artwork, quizAnsweredAt: awarded, place: place,
            language: latest.language, unlockRequired: true, collectible: card, evolvesFrom: card.id)
        var next = state
        next.trips.insert(Trip(id: tripID, title: card.origin?.displayLabel ?? latest.reply.title, startedAt: awarded, place: place, isExample: false, language: latest.language), at: 0)
        next.discoveries.append(discovery)
        if !questions.contains(where: { $0.id == explorationID }) {
            let record = ExplorationRecord(id: explorationID, question: latest.question, language: latest.language, age: family.family?.profile.age ?? 7,
                createdAt: awarded, reply: latest.reply, cardID: discovery.id)
            next.explorations = [record] + questions
        }
        refreshMemory(in: &next, tripID: tripID)
        try commit(next)
        return discovery
    }

    @discardableResult
    func createTrip(title: String, place: Place?, now: Date = Date()) throws -> UUID {
        let id = UUID()
        var next = state
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        next.trips.insert(Trip(id: id, title: cleaned.isEmpty ? L10n.text("A day of little wonders") : cleaned, startedAt: now, place: place, isExample: false, language: cleaned.isEmpty ? AppLanguage.current.rawValue : nil), at: 0)
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
        let record = Discovery(id: id, tripID: tripID, subject: subject, question: question, observation: observation, explanation: explanation, createdAt: now, photoFilename: filename, unlockedAt: now, origin: .exploration, tier: .fieldFind, language: AppLanguage.current.rawValue)
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
