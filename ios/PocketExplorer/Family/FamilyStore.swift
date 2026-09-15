import Foundation
import Observation

private struct FamilyCache: Codable {
    var family: ExplorerFamily?
    var pending: [UsageEntry] = []
    var totals: [String: Int] = [:]
    var latestDate = Date.distantPast
}

@MainActor @Observable
final class FamilyStore {
    private var cache: FamilyCache
    private var parent: ParentSession?
    private var parentDeadline: TimeInterval = 0
    private var lastTick: TimeInterval?
    private var clockOffset: TimeInterval = 0
    private var synchronizing = false
    private let file: URL
    private let client: FamilyClient
    private let writer: (Data, URL) throws -> Void
    var now: () -> Date = Date.init
    var uptime: () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }
    private(set) var busy = false
    private(set) var storageFailed = false
    private(set) var error: String?
    private(set) var recoveryCode: String?

    init(file: URL, client: FamilyClient = FamilyClient(), writer: ((Data, URL) throws -> Void)? = nil) throws {
        self.file = file; self.client = client
        self.writer = writer ?? { try $0.write(to: $1, options: .atomic) }
        if FileManager.default.fileExists(atPath: file.path) {
            cache = try JSONDecoder().decode(FamilyCache.self, from: Data(contentsOf: file))
            guard cache.family?.isValid != false else { throw FamilyError.invalidResponse }
        } else { cache = FamilyCache() }
    }

    var family: ExplorerFamily? { cache.family }
    var parentUnlocked: Bool { parent != nil && uptime() < parentDeadline }
    var pendingUsage: [UsageEntry] { cache.pending }
    var today: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: family?.profile.timeZone ?? TimeZone.current.identifier)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: max(now().addingTimeInterval(clockOffset), cache.latestDate))
    }
    var usedSeconds: Int { cache.totals[today, default: 0] }
    var timeFinished: Bool {
        guard let family, family.policy.dailyMinutes > 0 else { return false }
        return usedSeconds >= family.policy.dailyMinutes * 60
    }
    func allows(_ feature: FamilyFeature) -> Bool {
        !storageFailed && !timeFinished && (family?.permits(feature) ?? true)
    }

    func setup(profile: ExplorerProfile, pin: String, connection: ShareConnection) async throws {
        guard !busy else { return }
        busy = true; defer { busy = false }
        let response = try await client.setup(profile: profile, pin: pin, connection: connection)
        guard let family = response.family, response.recoveryCode != nil else { throw FamilyError.invalidResponse }
        try setParent(response)
        recoveryCode = response.recoveryCode
        try accept(family)
    }
    func unlock(pin: String, connection: ShareConnection) async throws {
        try setParent(try await client.unlock(pin: pin, connection: connection))
    }
    func recover(code: String, pin: String, connection: ShareConnection) async throws {
        let response = try await client.recover(code: code, pin: pin, connection: connection)
        guard response.recoveryCode != nil else { throw FamilyError.invalidResponse }
        try setParent(response); recoveryCode = response.recoveryCode
    }
    func save(profile: ExplorerProfile, policy: FamilyPolicy, connection: ShareConnection) async throws {
        guard parentUnlocked, let parent, var family else { throw FamilyError.parentRequired }
        family.profile = profile; family.policy = policy
        let response = try await client.update(family, parent: parent.token, connection: connection)
        guard let saved = response.family else { throw FamilyError.invalidResponse }
        try accept(saved)
    }
    func clearRecoveryCode() { recoveryCode = nil }
    func lock(connection: ShareConnection? = nil) async {
        let token = parent?.token
        parent = nil; parentDeadline = 0; recoveryCode = nil
        if let token, let connection { try? await client.lock(parent: token, connection: connection) }
    }
    func beginActive() { lastTick = uptime() }
    func endActive() throws { try tick(); lastTick = nil; parent = nil; parentDeadline = 0 }

    func tick() throws {
        guard let start = lastTick else { return }
        let end = uptime(), delta = min(60, max(0, Int(end - start)))
        guard delta > 0 else { return }
        lastTick = end
        guard family != nil, !timeFinished else { return }
        cache.latestDate = max(cache.latestDate, now().addingTimeInterval(clockOffset))
        let day = today
        cache.totals[day, default: 0] += delta
        cache.pending.append(UsageEntry(day: day, seconds: delta))
        try persist()
    }

    func synchronize(connection: ShareConnection) async {
        guard !synchronizing else { return }
        synchronizing = true; defer { synchronizing = false }
        do {
            if let remote = try await client.read(connection: connection).family { try accept(remote) }
            else if family != nil { throw FamilyError.invalidResponse }
            guard let family else { return }
            // A previous day's usage is retained locally. The API only accepts the current server day.
            cache.pending.removeAll { $0.day < family.usage.day }
            for entry in cache.pending where entry.day == family.usage.day {
                let response = try await client.usage(entry, connection: connection)
                guard let updated = response.family else { throw FamilyError.invalidResponse }
                cache.pending.removeAll { $0.id == entry.id }
                try accept(updated)
            }
            try persist(); error = nil
        } catch {
            if !Task.isCancelled { self.error = error.localizedDescription }
        }
    }

    private func setParent(_ response: FamilyResponse) throws {
        guard let session = response.parent, session.token.range(of: "^[A-Za-z0-9_-]{43}$", options: .regularExpression) != nil,
              session.expiresAt.isFinite else { throw FamilyError.invalidResponse }
        parent = session; parentDeadline = uptime() + 600
    }
    private func accept(_ family: ExplorerFamily) throws {
        guard family.isValid else { throw FamilyError.invalidResponse }
        if let previous = cache.family, previous.id != family.id || previous.revision > family.revision { throw FamilyError.changed }
        cache.family = family
        let serverDate = Date(timeIntervalSince1970: family.usage.serverTime / 1000)
        clockOffset = serverDate.timeIntervalSince(now()); cache.latestDate = serverDate
        cache.totals[family.usage.day] = max(cache.totals[family.usage.day, default: 0], family.usage.seconds)
        for key in cache.totals.keys.sorted().dropLast(31) { cache.totals.removeValue(forKey: key) }
        try persist()
    }
    private func persist() throws {
        do {
            try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(cache)
            try writer(data, file)
            guard try Data(contentsOf: file) == data else { throw FamilyError.saveFailed }
            storageFailed = false
        } catch { storageFailed = true; throw FamilyError.saveFailed }
    }
}
