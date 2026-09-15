import Foundation
import Observation

@MainActor @Observable
final class RecommendationStore {
    private struct State: Codable {
        var version = 1
        var seed = UUID().uuidString
        var banks: [String: RecommendationCatalog] = [:]
        var snapshots: [String: DailySnapshot] = [:]
        var history: [String: [String: Date]] = [:]
        var etags: [String: String] = [:]
        var synchronized: [String: Date] = [:]
        var retryAt: [String: Date] = [:]
        var withdrawals: Set<PreparedReference> = []
    }

    private var state: State
    private(set) var activeContext = ""
    @ObservationIgnored private let file: URL
    @ObservationIgnored private let bundled: [PreparedContent]
    @ObservationIgnored private let write: (Data, URL) throws -> Void
    @ObservationIgnored var client: RecommendationClient
    @ObservationIgnored private var syncing: [String: Task<Void, Never>] = [:]
    var items: [PreparedContent] { state.snapshots[activeContext]?.items ?? [] }
    var removedCount: Int { state.snapshots[activeContext]?.removedCount ?? 0 }

    func isWithdrawn(_ reference: PreparedReference) -> Bool { state.withdrawals.contains(reference) }

    init(file: URL, bundled: [PreparedContent]? = nil, client: RecommendationClient = RecommendationClient(), writer: ((Data, URL) throws -> Void)? = nil) {
        self.file = file
        self.client = client
        self.write = writer ?? { try $0.write(to: $1, options: .atomic) }
        self.bundled = bundled ?? Self.loadBundle()
        if let data = try? Data(contentsOf: file), data.count <= 4_000_000,
           let saved = try? JSONDecoder().decode(State.self, from: data), saved.version == 1,
           saved.banks.values.allSatisfy({ $0.items.allSatisfy(\.isValid) }),
           saved.snapshots.values.allSatisfy({ $0.items.allSatisfy(\.isValid) }) {
            state = saved
        } else { state = State() }
        try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
    }

    @discardableResult
    func activate(language: String, age: Int, now: Date = Date(), timeZone: TimeZone = .current) throws -> DailySnapshot {
        let context = DailySelection.context(language: language, age: age)
        activeContext = context
        let previous = state.snapshots[context]
        let candidates = state.banks[context]?.items ?? bundled
        let snapshot = DailySelection.make(candidates: candidates, previous: previous, history: state.history[context] ?? [:],
            language: language, age: age, now: now, timeZone: timeZone, seed: state.seed, withdrawals: state.withdrawals)
        if previous == snapshot { return snapshot }
        if snapshot.items.isEmpty && previous == nil { return snapshot }
        var next = state
        next.snapshots[context] = snapshot
        if previous?.createdAt != snapshot.createdAt {
            var history = next.history[context] ?? [:]
            for item in snapshot.items { history[item.topicID] = now }
            next.history[context] = history.filter { now.timeIntervalSince($0.value) <= 90 * 86400 }
        }
        try persist(next)
        return snapshot
    }

    func synchronize(base: URL, language: String, age: Int, now: Date = Date(), force: Bool = false) async {
        let context = DailySelection.context(language: language, age: age)
        if let pending = syncing[context] { await pending.value; return }
        guard !Task.isCancelled, (state.retryAt[context] ?? .distantPast) <= now else { return }
        if !force, state.banks[context] != nil, let last = state.synchronized[context], now >= last,
           now.timeIntervalSince(last) < Double(state.banks[context]?.refreshAfterSeconds ?? 21600) { return }
        let task = Task { @MainActor in
            defer { syncing[context] = nil }
            await download(base: base, language: language, age: age, context: context, now: now)
        }
        syncing[context] = task
        await task.value
    }

    private func download(base: URL, language: String, age: Int, context: String, now: Date) async {
        do {
            let download = try await client.fetch(base: base, language: language, age: age, etag: state.banks[context] == nil ? nil : state.etags[context])
            try Task.checkCancellation()
            var next = state
            if let catalog = download.catalog {
                next.banks[context] = catalog
                next.withdrawals.formUnion(catalog.withdrawals.map(\.reference))
                for (key, var snapshot) in next.snapshots {
                    let count = snapshot.items.count
                    snapshot.items.removeAll { next.withdrawals.contains($0.reference) }
                    snapshot.removedCount += count - snapshot.items.count
                    next.snapshots[key] = snapshot
                }
            } else if next.banks[context] == nil { throw RecommendationError.invalidCatalog }
            next.etags[context] = download.etag
            next.synchronized[context] = now
            next.retryAt[context] = nil
            let retained = Set(next.banks.keys.sorted { (next.synchronized[$0] ?? .distantPast) > (next.synchronized[$1] ?? .distantPast) }.prefix(2))
            next.banks = next.banks.filter { retained.contains($0.key) }
            try persist(next)
        } catch is CancellationError {}
        catch {
            var next = state
            let delay: TimeInterval
            if case RecommendationError.retryAfter(let value) = error { delay = value } else { delay = 60 }
            next.retryAt[context] = now.addingTimeInterval(delay)
            try? persist(next)
        }
    }

    func cancelSynchronization(language: String, age: Int) {
        syncing[DailySelection.context(language: language, age: age)]?.cancel()
    }

    func prefetch(base: URL, cache: PreparedAssets = PreparedAssets(), context: String? = nil) async {
        let key = context ?? activeContext
        let today = state.snapshots[key]?.items ?? []
        let selected = Set(today.map(\.topicID))
        let candidates = state.banks[key]?.items ?? bundled.filter { key.hasPrefix($0.language + ":") }
        let next = Array(candidates.filter { !selected.contains($0.topicID) && $0.expiry > Date() && !state.withdrawals.contains($0.reference) }.prefix(6))
        for item in today + next {
            if Task.isCancelled { break }
            _ = try? await cache.load(item.artwork, base: base, bundled: item.bundledArtwork)
            if let narration = item.narration { _ = try? await cache.load(narration, base: base) }
        }
        cache.prune(protecting: Set(today.flatMap { [$0.artwork] + [$0.narration].compactMap { $0 } }))
    }

    private func persist(_ next: State) throws {
        try write(JSONEncoder().encode(next), file)
        state = next
    }

    private static func loadBundle() -> [PreparedContent] {
        guard let url = Bundle.main.url(forResource: "prepared-discoveries", withExtension: "json"),
              let data = try? Data(contentsOf: url), let items = try? JSONDecoder().decode([PreparedContent].self, from: data) else { return [] }
        return items.filter(\.isValid)
    }
}
