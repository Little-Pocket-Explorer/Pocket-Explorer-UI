import CryptoKit
import Foundation
import Observation

struct AIPermissionReceipt: Codable, Equatable {
    static let policyVersion = "2026-09-16"
    var policyVersion: String
    var granted: Bool
    var revision: Int
    var updatedAt: Double?

    var isValid: Bool { !policyVersion.isEmpty && revision >= 0 && (updatedAt == nil || updatedAt!.isFinite) }
    var allowsRequests: Bool { isValid && granted && policyVersion == Self.policyVersion && revision > 0 }
}

struct AIPermissionCache {
    var preferences: UserDefaults = ShareStorageScope.preferences
    private struct Saved: Codable { var receipt: AIPermissionReceipt?; var pendingWithdrawal: Bool }
    private func key(_ connection: ShareConnection) -> String {
        let identity = connection.baseURL + "\n" + connection.ownerKey
        return "ai-data-permission." + SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    private func saved(_ connection: ShareConnection) -> Saved {
        guard let data = preferences.data(forKey: key(connection)), let result = try? JSONDecoder().decode(Saved.self, from: data) else {
            return Saved(receipt: nil, pendingWithdrawal: false)
        }
        return result
    }
    func receipt(_ connection: ShareConnection) -> AIPermissionReceipt? { saved(connection).receipt }
    func pending(_ connection: ShareConnection) -> Bool { saved(connection).pendingWithdrawal }
    func allows(_ connection: ShareConnection) -> Bool { !pending(connection) && receipt(connection)?.allowsRequests == true }
    func require(_ connection: ShareConnection) throws {
        guard allows(connection) else { throw AIDataPermissionError.required }
    }
    func withdraw(_ connection: ShareConnection) throws {
        try write(Saved(receipt: receipt(connection), pendingWithdrawal: true), connection)
    }
    func accept(_ receipt: AIPermissionReceipt, connection: ShareConnection, withdrawal: Bool = false) throws {
        guard receipt.isValid else { throw FamilyError.invalidResponse }
        let current = saved(connection)
        guard receipt.revision >= (current.receipt?.revision ?? 0) else { return }
        if current.pendingWithdrawal && !withdrawal { return }
        guard !withdrawal || !receipt.granted else { throw FamilyError.invalidResponse }
        try write(Saved(receipt: receipt, pendingWithdrawal: false), connection)
    }
    private func write(_ saved: Saved, _ connection: ShareConnection) throws {
        let data = try JSONEncoder().encode(saved)
        preferences.set(data, forKey: key(connection))
        guard preferences.data(forKey: key(connection)) == data else { throw FamilyError.saveFailed }
        NotificationCenter.default.post(name: .aiDataPermissionChanged, object: nil)
    }
}

extension Notification.Name {
    static let aiDataPermissionChanged = Notification.Name("ai-data-permission-changed")
}

struct AIDataPermissionClient {
    var session: URLSession = NarrationClient.session

    func read(connection: ShareConnection) async throws -> AIPermissionReceipt {
        try await send(connection: connection)
    }
    func update(granted: Bool, revision: Int, parent: String?, connection: ShareConnection) async throws -> AIPermissionReceipt {
        struct Input: Encodable { var policyVersion = AIPermissionReceipt.policyVersion; var granted: Bool; var revision: Int }
        return try await send(body: JSONEncoder().encode(Input(granted: granted, revision: revision)), parent: parent, connection: connection)
    }
    private func send(body: Data? = nil, parent: String? = nil, connection: ShareConnection) async throws -> AIPermissionReceipt {
        guard let base = connection.validatedURL else { throw ShareError.configuration }
        var request = URLRequest(url: base.appendingPathComponent("api/privacy/ai"), timeoutInterval: 15)
        request.httpMethod = body == nil ? "GET" : "POST"; request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(parent, forHTTPHeaderField: "x-parent-session")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw FamilyError.invalidResponse }
        if http.statusCode == 403 { throw FamilyError.parentRequired }
        if http.statusCode == 409 { throw AIDataPermissionError.changed }
        guard http.statusCode == 200, let receipt = try? JSONDecoder().decode(AIPermissionReceipt.self, from: data), receipt.isValid else { throw FamilyError.unavailable }
        return receipt
    }
}

@MainActor @Observable final class AIDataPermission {
    let cache: AIPermissionCache
    private let client: AIDataPermissionClient
    private(set) var allowed = false
    private(set) var pendingWithdrawal = false
    private(set) var busy = false
    private(set) var error: String?

    init(cache: AIPermissionCache = AIPermissionCache(), client: AIDataPermissionClient = AIDataPermissionClient()) {
        self.cache = cache; self.client = client
    }
    func synchronize(connection: ShareConnection) async {
        guard !busy else { return }
        busy = true; error = nil; refresh(connection)
        defer { busy = false; refresh(connection) }
        do {
            if cache.pending(connection) {
                let receipt = try await client.update(granted: false, revision: cache.receipt(connection)?.revision ?? 0, parent: nil, connection: connection)
                try cache.accept(receipt, connection: connection, withdrawal: true)
            } else { try cache.accept(try await client.read(connection: connection), connection: connection) }
        } catch { self.error = L10n.text("Could not update the AI permission. Please try again when online.") }
    }
    func allow(parent: String, connection: ShareConnection) async {
        guard !busy, !cache.pending(connection) else { return }
        busy = true; error = nil
        defer { busy = false; refresh(connection) }
        do {
            let reviewed = try await client.read(connection: connection)
            guard reviewed.policyVersion == AIPermissionReceipt.policyVersion else { throw AIDataPermissionError.changed }
            let receipt = try await client.update(granted: true, revision: reviewed.revision, parent: parent, connection: connection)
            guard receipt.allowsRequests else { throw AIDataPermissionError.changed }
            try cache.accept(receipt, connection: connection)
        } catch { self.error = error.localizedDescription }
    }
    func withdraw(connection: ShareConnection) async {
        do { try cache.withdraw(connection); refresh(connection) }
        catch { self.error = error.localizedDescription; return }
        await synchronize(connection: connection)
    }
    private func refresh(_ connection: ShareConnection) {
        allowed = cache.allows(connection); pendingWithdrawal = cache.pending(connection)
    }
}

enum AIDataPermissionError: LocalizedError {
    case required, changed
    var errorDescription: String? {
        switch self {
        case .required: return L10n.text("Ask a grown-up to review cloud AI data use. Your question stays on this device until permission is given.")
        case .changed: return L10n.text("The AI permission has changed. Please review it again.")
        }
    }
}
