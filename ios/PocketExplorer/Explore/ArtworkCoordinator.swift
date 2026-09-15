import Foundation
import Observation

@MainActor @Observable
final class ArtworkCoordinator {
    private(set) var errors: [UUID: String] = [:]
    private(set) var stopped = Set<UUID>()
    private(set) var busy = Set<UUID>()
    @ObservationIgnored private var nextChecks: [UUID: Date] = [:]
    @ObservationIgnored private var failures: [UUID: Int] = [:]
    var client = AIClient()

    func update(_ requested: Discovery, store: TripStore, retry: Bool = false, now: Date = Date()) async {
        guard !Task.isCancelled, let discovery = store.state.discoveries.first(where: { $0.id == requested.id }),
              let explorationID = discovery.explorationID, discovery.artworkFilename == nil,
              !busy.contains(discovery.id) else { return }
        if discovery.artwork?.status == "failed" && !retry { return }
        if retry, let job = discovery.artwork, job.status == "failed", !job.allowsRetry { return }
        busy.insert(discovery.id)
        defer { busy.remove(discovery.id) }
        do {
            let connection = try ConnectionVault().loadOrCreate()
            let job: ArtworkJob
            if let existing = discovery.artwork { job = try await client.artwork(existing.id, retry: retry && existing.allowsRetry, connection: connection) }
            else { job = try await client.createArtwork(explorationID, connection: connection) }
            try Task.checkCancellation()
            try store.saveArtwork(job, discoveryID: discovery.id)
            if job.status == "ready" {
                let data = try await client.image(job, connection: connection)
                try Task.checkCancellation()
                try store.saveArtwork(job, discoveryID: discovery.id, image: data)
            }
            if errors[discovery.id] != nil { errors[discovery.id] = nil }
            stopped.remove(discovery.id)
            failures[discovery.id] = nil
            let progress = ArtworkProgress.resolve(store.state.discoveries.first { $0.id == discovery.id } ?? discovery, now: now)
            nextChecks[discovery.id] = now.addingTimeInterval(progress == .slow || progress == .paused ? 20 : 5)
        } catch is CancellationError {}
        catch {
            if !Task.isCancelled {
                if let reason = error as? AIClientError, [.dailyLimit, .demoLimit, .artworkLimit, .notFound, .requestConflict, .invalidArtwork].contains(reason) {
                    stopped.insert(discovery.id)
                    errors[discovery.id] = [.notFound, .requestConflict].contains(reason)
                        ? L10n.text("This illustration is unavailable. Your card and words are still saved.") : reason.localizedDescription
                    nextChecks[discovery.id] = reason == .dailyLimit
                        ? Date(timeIntervalSince1970: (floor(now.timeIntervalSince1970 / 86400) + 1) * 86400) : .distantFuture
                } else {
                    errors[discovery.id] = L10n.text("We couldn't check your illustration. Your card is safe. We'll check again shortly.")
                    let count = min(4, (failures[discovery.id] ?? 0) + 1)
                    failures[discovery.id] = count
                    nextChecks[discovery.id] = now.addingTimeInterval(min(60, 5 * pow(2, Double(count))))
                }
            }
        }
    }

    func resume(store: TripStore) async {
        while !Task.isCancelled {
            await refresh(store: store)
            do { try await Task.sleep(for: .seconds(5)) } catch { return }
        }
    }

    func refresh(store: TripStore, now: Date = Date()) async {
        let pending = store.state.discoveries.filter {
            $0.ai != nil && $0.artworkFilename == nil && $0.artwork?.status != "failed" && (nextChecks[$0.id] ?? .distantPast) <= now
        }
        await withTaskGroup(of: Void.self) { group in
            var next = 0
            func enqueue() {
                let discovery = pending[next]
                next += 1
                group.addTask { @MainActor in await self.update(discovery, store: store, now: now) }
            }
            while next < min(3, pending.count) { enqueue() }
            for await _ in group {
                if Task.isCancelled { group.cancelAll(); break }
                if next < pending.count { enqueue() }
            }
        }
    }
}
