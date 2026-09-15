import Foundation

struct RecommendationClient {
    var session: URLSession = NarrationClient.session

    struct Download {
        var catalog: RecommendationCatalog?
        var etag: String?
    }

    func fetch(base: URL, language: String, age: Int, etag: String?) async throws -> Download {
        var components = URLComponents(url: base.appendingPathComponent("api/recommendations"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "language", value: language), URLQueryItem(name: "age", value: String(age))]
        guard let url = components.url else { throw RecommendationError.unavailable }
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse else { throw RecommendationError.invalidCatalog }
        if http.statusCode == 429 || http.statusCode == 503 {
            let delay = Double(http.value(forHTTPHeaderField: "Retry-After") ?? "60") ?? 60
            throw RecommendationError.retryAfter(min(86400, max(60, delay)))
        }
        if http.statusCode == 304 { return Download(catalog: nil, etag: http.value(forHTTPHeaderField: "ETag") ?? etag) }
        guard http.statusCode == 200, data.count <= 1_200_000 else { throw RecommendationError.invalidCatalog }
        let catalog = try JSONDecoder().decode(RecommendationCatalog.self, from: data)
        guard catalog.schemaVersion == 1, !catalog.revision.isEmpty, catalog.items.count <= 60,
              catalog.serverTime.isFinite, catalog.refreshAfterSeconds >= 3600, catalog.refreshAfterSeconds <= 604800,
              Set(catalog.items.map(\.topicID)).count == catalog.items.count,
              catalog.items.allSatisfy({ $0.isEligible(language: language, age: age, at: Date(timeIntervalSince1970: catalog.serverTime / 1000)) && $0.narration != nil }) else { throw RecommendationError.invalidCatalog }
        return Download(catalog: catalog, etag: http.value(forHTTPHeaderField: "ETag"))
    }
}
