import Foundation
import Observation

@MainActor @Observable
final class DemoStore {
    private struct State: Codable {
        var access: DemoAccess?
        var enabled = false
        var catalogs: [String: RecommendationCatalog] = [:]
    }
    private var state: State
    private(set) var context = ""
    private(set) var busy = false
    private(set) var offlineReady = false
    private(set) var error: String?
    @ObservationIgnored private let file: URL
    @ObservationIgnored private let write: (Data, URL) throws -> Void
    @ObservationIgnored var now: () -> Date = Date.init
    @ObservationIgnored var client: DemoClient

    var authorized: Bool { state.access?.isValid(at: now()) ?? false }
    var enabled: Bool { authorized && state.enabled }
    var expiresAt: Date? { state.access?.expiresAt.map { Date(timeIntervalSince1970: $0 / 1000) } }
    var items: [PreparedContent] { enabled ? (state.catalogs[context]?.items ?? []).filter { $0.expiry > now() } : [] }
    var hasAccessRecord: Bool { state.access != nil }

    init(file: URL, client: DemoClient = DemoClient(), writer: ((Data, URL) throws -> Void)? = nil) {
        self.file = file
        self.client = client
        self.write = writer ?? { try $0.write(to: $1, options: .atomic) }
        if let data = try? Data(contentsOf: file), data.count <= 4_000_000,
           let saved = try? JSONDecoder().decode(State.self, from: data),
           saved.catalogs.values.allSatisfy({ $0.items.count <= 60 && $0.items.allSatisfy(\.isValid) }) { state = saved }
        else { state = State() }
    }

    func activate(_ activation: DemoActivation, connection: ShareConnection) async throws {
        let access = try await client.activate(activation, connection: connection)
        guard access.isValid(at: now()) else { throw DemoError.unauthorized }
        var next = state
        next.access = access
        next.enabled = false
        try persist(next)
        error = nil
    }

    func selectContext(language: String, age: Int, cache: PreparedAssets = PreparedAssets()) {
        context = DailySelection.context(language: language, age: age)
        updateReadiness(cache: cache)
    }

    func setEnabled(_ value: Bool) throws {
        guard !value || authorized else { throw DemoError.unauthorized }
        var next = state; next.enabled = value
        try persist(next)
        error = nil
    }

    func checkAccess(connection: ShareConnection) async {
        guard hasAccessRecord else { return }
        do {
            let access = try await client.access(connection: connection)
            if !access.isValid(at: now()) { try resetAccess(); return }
            var next = state
            next.access = access
            try persist(next)
        } catch DemoError.unauthorized { try? resetAccess() }
        catch { /* A previously authorized presentation remains available until its expiry while offline. */ }
    }

    func refresh(connection: ShareConnection, language: String, age: Int, cache: PreparedAssets = PreparedAssets()) async {
        guard authorized, !busy, let base = connection.validatedURL else { return }
        busy = true; error = nil
        defer { busy = false }
        let key = DailySelection.context(language: language, age: age)
        do {
            let result = try await client.catalog(connection: connection, language: language, age: age)
            guard result.access.isValid(at: now()) else { throw DemoError.unauthorized }
            for item in result.catalog.items {
                try Task.checkCancellation()
                _ = try await cache.load(item.artwork, base: base, authorization: connection.ownerKey)
                if let narration = item.narration { _ = try await cache.load(narration, base: base, authorization: connection.ownerKey) }
            }
            var next = state
            next.access = result.access
            next.catalogs[key] = result.catalog
            if next.catalogs.count > 2 {
                next.catalogs = next.catalogs.filter { $0.key == key || $0.key == context }
            }
            try persist(next)
            if context == key { updateReadiness(cache: cache) }
        } catch is CancellationError {}
        catch DemoError.unauthorized { try? resetAccess(); error = DemoError.unauthorized.localizedDescription }
        catch { self.error = (error as? DemoError)?.localizedDescription ?? DemoError.unavailable.localizedDescription }
    }

    func updateReadiness(cache: PreparedAssets = PreparedAssets()) {
        let candidates = state.catalogs[context]?.items ?? []
        offlineReady = authorized && !candidates.isEmpty && candidates.allSatisfy { item in
            item.expiry > now() && cache.cached(item.artwork) != nil && item.narration.map { cache.cached($0) != nil } == true
        }
    }

    private func resetAccess() throws {
        state = State()
        offlineReady = false
        do { try write(JSONEncoder().encode(state), file) }
        catch { try? FileManager.default.removeItem(at: file); throw error }
    }

    private func persist(_ next: State) throws {
        try write(JSONEncoder().encode(next), file)
        state = next
    }
}
