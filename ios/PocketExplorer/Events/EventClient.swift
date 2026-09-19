import Foundation

struct EventClient {
    var session: URLSession = .shared
    private struct Failure: Decodable { var error: String }
    func nearby(_ location: ExplorerCoordinate, language: String, connection: ShareConnection) async throws -> NearbyEvents {
        guard location.isValid, AppLanguage(rawValue: language) != nil else { throw EventError.invalidResponse }
        let result: NearbyEvents = try await send("api/events", query: coordinates(location) + [URLQueryItem(name: "language", value: language)], connection: connection)
        guard result.items.allSatisfy({ $0.isValid && $0.language == language }) else { throw EventError.invalidResponse }
        return result
    }
    func read(_ id: String, language: String, connection: ShareConnection) async throws -> ExplorerEvent {
        guard UUID(uuidString: id) != nil, AppLanguage(rawValue: language) != nil else { throw EventError.invalidResponse }
        let result: ExplorerEvent = try await send("api/events/\(id)", query: [URLQueryItem(name: "language", value: language)], connection: connection)
        guard result.isValid, result.id == id, result.language == language else { throw EventError.invalidResponse }
        return result
    }
    func claim(_ event: ExplorerEvent, id: UUID, choice: Int, reading: LocationReading, connection: ShareConnection) async throws -> EventClaim {
        guard event.isValid, event.challenge.choices.indices.contains(choice) else { throw EventError.invalidResponse }
        guard reading.isFresh(radius: event.radius) else { throw EventError.location }
        struct Input: Encodable { var id: String; var revision: Int; var choice: Int; var language: String; var latitude: Double; var longitude: Double; var accuracy: Double; var observedAt: Double }
        let input = Input(id: id.uuidString.lowercased(), revision: event.revision, choice: choice, language: event.language, latitude: reading.coordinate.latitude, longitude: reading.coordinate.longitude, accuracy: reading.accuracy, observedAt: floor(reading.observedAt.timeIntervalSince1970 * 1000))
        let result: EventClaim = try await send("api/events/\(event.id)/claim", body: JSONEncoder().encode(input), connection: connection)
        guard result.correct == (result.collectible != nil), result.collectible?.isValid != false,
              result.collectible == nil || result.collectible?.origin?.sourceID == event.id && result.collectible?.origin?.kind == "event",
              result.correct || result.correctIndex.map({ (0...2).contains($0) && $0 != choice }) == true else { throw EventError.invalidResponse }
        return result
    }
    func nearbyCards(_ location: ExplorerCoordinate, connection: ShareConnection) async throws -> NearbyCards {
        guard location.isValid else { throw EventError.invalidResponse }
        let result: NearbyCards = try await send("api/map-discoveries", query: coordinates(location), connection: connection)
        guard result.items.allSatisfy(\.isValid) else { throw EventError.invalidResponse }; return result
    }
    func friendCards(connection: ShareConnection) async throws -> [SharedMapCard] {
        struct Result: Decodable { var items: [SharedMapCard] }
        let result: Result = try await send("api/map-discoveries/friends", connection: connection)
        guard result.items.allSatisfy({ $0.isValid && $0.audience.needsFriends }) else { throw EventError.invalidResponse }
        return result.items
    }
    func publish(_ id: String, audience: MapAudience, location: ExplorerCoordinate?, connection: ShareConnection) async throws -> SharedMapCard {
        guard UUID(uuidString: id) != nil, audience.needsLocation == (location != nil), location?.isValid != false else { throw EventError.invalidResponse }
        struct Input: Encodable { var collectibleID: String; var audience: MapAudience; var location: ExplorerCoordinate? }
        let result: SharedMapCard = try await send("api/map-discoveries", body: JSONEncoder().encode(Input(collectibleID: id, audience: audience, location: location?.approximate)), connection: connection)
        guard result.isValid else { throw EventError.invalidResponse }; return result
    }
    func mine(connection: ShareConnection) async throws -> [MapPublication] {
        struct Result: Decodable { var items: [MapPublication] }
        let result: Result = try await send("api/map-discoveries/mine", connection: connection)
        guard result.items.allSatisfy({ UUID(uuidString: $0.id) != nil && UUID(uuidString: $0.collectibleID) != nil && [0, 1].contains($0.revoked) && $0.audience.needsLocation == ($0.latitude != nil && $0.longitude != nil) }) else { throw EventError.invalidResponse }
        return result.items
    }
    func revoke(_ id: String, connection: ShareConnection) async throws {
        guard UUID(uuidString: id) != nil else { throw EventError.invalidResponse }
        _ = try await data("api/map-discoveries/\(id)", method: "DELETE", connection: connection)
    }
    func mapArtwork(_ card: SharedMapCard, connection: ShareConnection) async throws -> Data? {
        guard card.isValid else { throw EventError.invalidResponse }
        guard let path = card.artworkPath else { return nil }
        let bytes = try await data(String(path.dropFirst()), method: "GET", connection: connection)
        guard bytes.count < 6_000_000 else { throw EventError.invalidResponse }; return bytes
    }
    func mapCard(_ id: String, connection: ShareConnection) async throws -> SharedMapCard {
        guard UUID(uuidString: id) != nil else { throw EventError.invalidResponse }
        let card: SharedMapCard = try await send("api/map-discoveries/\(id)", connection: connection)
        guard card.isValid, card.id == id else { throw EventError.invalidResponse }; return card
    }
    private func coordinates(_ location: ExplorerCoordinate) -> [URLQueryItem] {
        [URLQueryItem(name: "latitude", value: String(location.latitude)), URLQueryItem(name: "longitude", value: String(location.longitude))]
    }
    private func send<T: Decodable>(_ path: String, query: [URLQueryItem] = [], body: Data? = nil, connection: ShareConnection) async throws -> T {
        let bytes = try await data(path, method: body == nil ? "GET" : "POST", query: query, body: body, connection: connection)
        guard let value = try? JSONDecoder().decode(T.self, from: bytes) else { throw EventError.invalidResponse }; return value
    }
    private func data(_ path: String, method: String, query: [URLQueryItem] = [], body: Data? = nil, connection: ShareConnection) async throws -> Data {
        guard let base = connection.validatedURL, var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false) else { throw EventError.unavailable }
        components.queryItems = query.isEmpty ? nil : query
        guard let url = components.url else { throw EventError.invalidResponse }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = method; request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bytes: Data, response: URLResponse
        do { (bytes, response) = try await session.data(for: request) }
        catch {
            if Task.isCancelled || (error as? URLError)?.code == .cancelled { throw CancellationError() }
            throw EventError.unavailable
        }
        guard let http = response as? HTTPURLResponse else { throw EventError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw EventError.from((try? JSONDecoder().decode(Failure.self, from: bytes).error) ?? "unknown") }
        return bytes
    }
}
