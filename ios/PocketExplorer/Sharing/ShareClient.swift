import Foundation
import Security

struct ShareClient {
    var session: URLSession = .shared

    func create(_ story: PublicStory, connection: ShareConnection) async throws -> ShareReceipt {
        let (data, response) = try await send(path: "api/shares", method: "POST", body: JSONEncoder().encode(story), connection: connection)
        guard response.statusCode == 201 else { throw ShareError.unavailable }
        let receipt: ShareReceipt
        do { receipt = try JSONDecoder().decode(ShareReceipt.self, from: data) }
        catch { throw ShareError.invalidResponse }
        guard valid(receipt, connection: connection) else { throw ShareError.invalidResponse }
        return receipt
    }

    func revoke(_ receipt: ShareReceipt, connection: ShareConnection) async throws {
        guard valid(receipt, connection: connection) else { throw ShareError.invalidResponse }
        let (_, response) = try await send(path: "api/shares/\(receipt.token)", method: "DELETE", body: nil, connection: connection)
        guard response.statusCode == 204 else { throw ShareError.unavailable }
    }

    private func valid(_ receipt: ShareReceipt, connection: ShareConnection) -> Bool {
        guard receipt.token.range(of: "^[A-Za-z0-9_-]{32}$", options: .regularExpression) != nil,
              let origin = connection.validatedURL else { return false }
        return receipt.url.scheme == origin.scheme && receipt.url.host == origin.host && receipt.url.port == origin.port && receipt.url.user == nil && receipt.url.password == nil && receipt.url.path == "/s/\(receipt.token)" && receipt.url.query == nil && receipt.url.fragment == nil
    }

    private func send(path: String, method: String, body: Data?, connection: ShareConnection) async throws -> (Data, HTTPURLResponse) {
        guard let base = connection.validatedURL else { throw ShareError.configuration }
        var request = URLRequest(url: base.appendingPathComponent(path), timeoutInterval: 15)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: Data
        let response: URLResponse
        do { (data, response) = try await session.data(for: request) }
        catch {
            if Task.isCancelled || error is CancellationError || (error as? URLError)?.code == .cancelled { throw CancellationError() }
            throw ShareError.unavailable
        }
        guard let http = response as? HTTPURLResponse else { throw ShareError.invalidResponse }
        if http.statusCode == 401 || http.statusCode == 403 { throw ShareError.unauthorized }
        if http.statusCode == 429 { throw ShareError.rateLimited }
        return (data, http)
    }
}

struct ConnectionVault {
    var service = ShareStorageScope.service

    func loadOrCreate(baseURL: String = ShareStorageScope.baseURL) throws -> ShareConnection {
        if let existing = try read() { return existing }
        var bytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { throw ShareError.configuration }
        let key = "pe1_" + bytes.map { String(format: "%02x", $0) }.joined()
        let connection = ShareConnection(baseURL: baseURL, ownerKey: key)
        try save(connection)
        return connection
    }

    func read() throws -> ShareConnection? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else { throw ShareError.configuration }
        return try JSONDecoder().decode(ShareConnection.self, from: data)
    }

    func save(_ connection: ShareConnection) throws {
        guard connection.validatedURL != nil else { throw ShareError.configuration }
        let data = try JSONEncoder().encode(connection)
        let status = SecItemUpdate(baseQuery as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var item = baseQuery
            item[kSecValueData as String] = data
            item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else { throw ShareError.configuration }
        } else if status != errSecSuccess { throw ShareError.configuration }
        guard try read() == connection else { throw ShareError.configuration }
    }

    private var baseQuery: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: "owner"]
    }
}


enum ShareStorageScope {
    static var baseURL: String {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            return ProcessInfo.processInfo.environment["POCKET_SHARE_BASE_URL"] ?? "http://127.0.0.1:4176"
        }
        #endif
        return "https://pocket.changhai.me"
    }

    static var service: String {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") { return "com.haichang.pocketexplorer.sharing.uitests" }
        #endif
        return "com.haichang.pocketexplorer.sharing"
    }
    static var preferences: UserDefaults {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") { return UserDefaults(suiteName: "PocketExplorerUITests")! }
        #endif
        return .standard
    }
}
