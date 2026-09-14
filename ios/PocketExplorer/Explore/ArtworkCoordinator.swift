import Foundation
import Observation

@MainActor @Observable
final class ArtworkCoordinator {
    private(set) var errors: [UUID: String] = [:]
    private var busy = Set<UUID>()
    var client = AIClient()

    func update(_ discovery: Discovery, store: TripStore, retry: Bool = false) async {
        guard let explorationID = discovery.explorationID, discovery.artworkFilename == nil,
              !busy.contains(discovery.id), retry || errors[discovery.id] == nil else { return }
        if discovery.artwork?.status == "failed" && !retry { return }
        busy.insert(discovery.id)
        defer { busy.remove(discovery.id) }
        errors[discovery.id] = nil
        do {
            let connection = try ConnectionVault().loadOrCreate()
            let job: ArtworkJob
            if let existing = discovery.artwork { job = try await client.artwork(existing.id, retry: retry, connection: connection) }
            else { job = try await client.createArtwork(explorationID, connection: connection) }
            let data = job.status == "ready" ? try await client.image(job, connection: connection) : nil
            try Task.checkCancellation()
            try store.saveArtwork(job, discoveryID: discovery.id, image: data)
        } catch is CancellationError {}
        catch { if !Task.isCancelled { errors[discovery.id] = error.localizedDescription } }
    }

    func resume(store: TripStore) async {
        while !Task.isCancelled {
            for discovery in store.state.discoveries where discovery.ai != nil && discovery.artworkFilename == nil {
                await update(discovery, store: store)
            }
            do { try await Task.sleep(for: .seconds(5)) } catch { return }
        }
    }
}
