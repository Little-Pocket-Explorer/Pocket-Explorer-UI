import Foundation

struct DemoAccess: Codable, Equatable {
    var authorized: Bool
    var id: String?
    var label: String?
    var expiresAt: Double?

    func isValid(at date: Date) -> Bool {
        authorized && id.flatMap(UUID.init(uuidString:)) != nil &&
            (expiresAt?.isFinite ?? false) && (expiresAt ?? 0) > date.timeIntervalSince1970 * 1000
    }
}

struct DemoDownload: Codable {
    var access: DemoAccess
    var catalog: RecommendationCatalog
}

struct DemoActivation: Identifiable, Equatable {
    let token: String
    var id: String { token }

    init?(url: URL) {
        guard url.scheme == "pocketexplorer", url.host == "demo", url.path == "/activate",
              url.user == nil, url.password == nil, url.port == nil, url.query == nil,
              let token = url.fragment, token.range(of: "^[A-Za-z0-9_-]{43}$", options: .regularExpression) != nil else { return nil }
        self.token = token
    }
}

enum DemoError: Error, LocalizedError {
    case invitation, unauthorized, unavailable, invalidResponse
    var errorDescription: String? {
        switch self {
        case .invitation: return L10n.text("This demo invitation has expired or has already been used.")
        case .unauthorized: return L10n.text("Demo access has ended on this iPhone.")
        case .unavailable: return L10n.text("Demo content could not be downloaded. Please try again.")
        case .invalidResponse: return L10n.text("This demo content needs an update. Please try again.")
        }
    }
}

struct DemoClient {
    var session: URLSession = NarrationClient.session

    func activate(_ activation: DemoActivation, connection: ShareConnection) async throws -> DemoAccess {
        let body = try JSONEncoder().encode(["token": activation.token])
        return try await send("api/demo/activate", connection: connection, body: body)
    }

    func access(connection: ShareConnection) async throws -> DemoAccess {
        try await send("api/demo/access", connection: connection)
    }

    func catalog(connection: ShareConnection, language: String, age: Int) async throws -> DemoDownload {
        let result: DemoDownload = try await send("api/demo/catalog", connection: connection,
            query: [URLQueryItem(name: "language", value: language), URLQueryItem(name: "age", value: String(age))])
        let catalog = result.catalog
        guard catalog.schemaVersion == 1, catalog.serverTime.isFinite, !catalog.revision.isEmpty,
              catalog.items.count <= 60, Set(catalog.items.map(\.id)).count == catalog.items.count,
              catalog.items.allSatisfy({ $0.isEligible(language: language, age: age, at: Date(timeIntervalSince1970: catalog.serverTime / 1000)) && $0.narration != nil }) else { throw DemoError.invalidResponse }
        return result
    }

    private func send<T: Decodable>(_ path: String, connection: ShareConnection, body: Data? = nil, query: [URLQueryItem] = []) async throws -> T {
        guard let base = connection.validatedURL else { throw DemoError.unavailable }
        var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw DemoError.unavailable }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.httpMethod = body == nil ? "GET" : "POST"
        request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse else { throw DemoError.invalidResponse }
        if response.statusCode == 410 { throw DemoError.invitation }
        if response.statusCode == 401 || response.statusCode == 403 { throw DemoError.unauthorized }
        guard response.statusCode == 200, data.count <= 1_200_000 else { throw DemoError.unavailable }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw DemoError.invalidResponse }
    }
}
