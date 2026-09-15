import Foundation
import Observation

@MainActor @Observable
final class PreparedRegistration {
    static let shared = PreparedRegistration()
    @ObservationIgnored private var pending: [UUID: Task<Void, Error>] = [:]
    @ObservationIgnored private var nextChecks: [UUID: Date] = [:]
    var client = AIClient()

    func register(_ id: UUID, store: TripStore, connection: ShareConnection) async throws {
        if let task = pending[id] { return try await task.value }
        guard let record = store.questions.first(where: { $0.id == id }), let prepared = record.preparedContent else { return }
        if record.preparedRegistered == true, record.preparedArtwork != nil { return }
        if record.preparedUnavailable == true { throw AIClientError.preparedUnavailable }
        let task = Task { @MainActor in
            defer { pending[id] = nil }
            do {
                let receipt = try await client.ask(record, photo: nil, connection: connection)
                guard receipt.id == id, receipt.status == "ready", receipt.reply == prepared.reply else { throw AIClientError.invalidResponse }
                let job = try await client.createArtwork(id, connection: connection)
                try store.markPreparedRegistered(id, artwork: job)
            } catch AIClientError.preparedUnavailable {
                try store.markPreparedUnavailable(id)
                throw AIClientError.preparedUnavailable
            }
        }
        pending[id] = task
        try await task.value
    }

    func prepareShare(_ snapshot: PublicStory, store: TripStore, connection: ShareConnection) async throws -> PublicStory {
        var result = snapshot
        await store.recall.synchronize(store: store, connection: connection)
        for index in result.cards.indices {
            if let discovery = store.state.discoveries.first(where: { $0.id.uuidString == result.cards[index].id }) {
                guard discovery.isUnlocked else { throw CollectibleError.pending }
                guard discovery.isVerified else { throw CollectibleError.unavailable }
            }
            guard let discovery = store.state.discoveries.first(where: { $0.id.uuidString == result.cards[index].id }),
                  let id = discovery.explorationID,
                  store.questions.first(where: { $0.id == id })?.preparedContent != nil else { continue }
            try await register(id, store: store, connection: connection)
            guard let artwork = store.questions.first(where: { $0.id == id })?.preparedArtwork, artwork.status == "ready" else { throw ShareError.unavailable }
            result.cards[index].artworkID = artwork.id
        }
        return result
    }

    func refresh(store: TripStore, now: Date = Date(), connection: () throws -> ShareConnection = { try ConnectionVault().loadOrCreate() }) async {
        for record in store.questions where record.preparedContent != nil && record.preparedRegistered != true && record.preparedUnavailable != true {
            guard !Task.isCancelled else { return }
            if pending[record.id] != nil || (nextChecks[record.id] ?? .distantPast) > now { continue }
            do { try await register(record.id, store: store, connection: connection()); nextChecks[record.id] = nil }
            catch { nextChecks[record.id] = now.addingTimeInterval(error is CancellationError ? 0 : 60) }
        }
    }
}
