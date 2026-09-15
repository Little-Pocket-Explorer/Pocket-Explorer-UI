import Foundation

struct CollectibleClient {
    struct Page: Codable { var items: [KnowledgeCard]; var next: Int? }
    var session: URLSession = .shared
    private struct Failure: Decodable { var error: String }

    func list(offset: Int = 0, connection: ShareConnection) async throws -> Page {
        guard (0...100000).contains(offset) else { throw CollectibleError.invalidResponse }
        let page: Page = try await send(path: "api/collectibles", query: [URLQueryItem(name: "offset", value: String(offset))], connection: connection)
        guard page.items.count <= 30, page.items.allSatisfy(\.isValid), Set(page.items.map(\.id)).count == page.items.count,
              page.next == nil || page.next! > offset && page.next! <= 100000 else { throw CollectibleError.invalidResponse }
        return page
    }

    func recall(_ attempt: RecallAttempt, connection: ShareConnection) async throws -> RecallReceipt {
        struct Input: Encodable { var id: String; var explorationID: String; var choice: Int }
        let body = try JSONEncoder().encode(Input(id: attempt.id.uuidString.lowercased(), explorationID: attempt.explorationID.uuidString.lowercased(), choice: attempt.choice))
        let receipt: RecallReceipt = try await send(path: "api/collectibles/recall", body: body, connection: connection)
        guard (0...2).contains(receipt.correctIndex), receipt.correct == (receipt.correctIndex == attempt.choice),
              receipt.correct == (receipt.collectible != nil), receipt.collectible?.isValid != false else { throw CollectibleError.invalidResponse }
        return receipt
    }
    func read(_ id: String, connection: ShareConnection) async throws -> KnowledgeCard {
        guard UUID(uuidString: id) != nil else { throw CollectibleError.invalidResponse }
        struct Result: Decodable { var collectible: KnowledgeCard }
        let result: Result = try await send(path: "api/collectibles/\(id)", connection: connection)
        guard result.collectible.isValid, result.collectible.id == id else { throw CollectibleError.invalidResponse }
        return result.collectible
    }
    func style(_ style: CardStyle, id: String, connection: ShareConnection) async throws -> KnowledgeCard {
        guard UUID(uuidString: id) != nil else { throw CollectibleError.invalidResponse }
        struct Result: Decodable { var collectible: KnowledgeCard }
        let result: Result = try await send(path: "api/collectibles/\(id)/style", body: JSONEncoder().encode(["style": style.rawValue]), connection: connection)
        guard result.collectible.isValid, result.collectible.id == id, result.collectible.style == style else { throw CollectibleError.invalidResponse }
        return result.collectible
    }
    private func send<T: Decodable>(path: String, body: Data? = nil, query: [URLQueryItem] = [], connection: ShareConnection) async throws -> T {
        guard let base = connection.validatedURL else { throw CollectibleError.unavailable }
        var url = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { url.queryItems = query }
        var request = URLRequest(url: url.url!, timeoutInterval: 20)
        request.httpMethod = body == nil ? "GET" : "POST"; request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: Data, response: URLResponse
        do { (data, response) = try await session.data(for: request) }
        catch {
            if Task.isCancelled || (error as? URLError)?.code == .cancelled { throw CancellationError() }
            throw CollectibleError.unavailable
        }
        guard let http = response as? HTTPURLResponse else { throw CollectibleError.invalidResponse }
        if !(200...299).contains(http.statusCode) {
            let code = (try? JSONDecoder().decode(Failure.self, from: data).error) ?? ""
            switch code {
            case "card_needs_new_discovery": throw CollectibleError.newDiscovery
            case "card_version_limit": throw CollectibleError.versionLimit
            case "quiz_request_conflict": throw CollectibleError.requestConflict
            case "card_not_unlocked": throw CollectibleError.pending
            case "family_feature_disabled", "family_time_finished", "parent_required", "family_required": throw FamilyError.from(code)
            default: throw CollectibleError.unavailable
            }
        }
        guard let result = try? JSONDecoder().decode(T.self, from: data) else { throw CollectibleError.invalidResponse }
        return result
    }
}
