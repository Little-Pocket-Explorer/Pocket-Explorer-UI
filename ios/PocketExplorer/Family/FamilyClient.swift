import Foundation

struct FamilyClient {
    var session: URLSession = .shared

    func read(connection: ShareConnection) async throws -> FamilyResponse {
        try await send(path: "api/family", connection: connection)
    }
    func setup(profile: ExplorerProfile, pin: String, connection: ShareConnection) async throws -> FamilyResponse {
        guard profile.isValid, validPIN(pin) else { throw FamilyError.invalidProfile }
        struct Input: Encodable { var profile: ExplorerProfile; var pin: String }
        return try await send(path: "api/family", body: JSONEncoder().encode(Input(profile: profile, pin: pin)), connection: connection)
    }
    func unlock(pin: String, connection: ShareConnection) async throws -> FamilyResponse {
        guard validPIN(pin) else { throw FamilyError.invalidProfile }
        return try await send(path: "api/family/unlock", body: JSONEncoder().encode(["pin": pin]), connection: connection)
    }
    func recover(code: String, pin: String, connection: ShareConnection) async throws -> FamilyResponse {
        guard validPIN(pin), code.range(of: "^[A-Za-z0-9_-]{43}$", options: .regularExpression) != nil else { throw FamilyError.invalidProfile }
        return try await send(path: "api/family/recover", body: JSONEncoder().encode(["recoveryCode": code, "pin": pin]), connection: connection)
    }
    func update(_ family: ExplorerFamily, parent: String, connection: ShareConnection) async throws -> FamilyResponse {
        guard family.profile.isValid else { throw FamilyError.invalidProfile }
        struct Input: Encodable { var profile: ExplorerProfile; var policy: FamilyPolicy; var revision: Int }
        return try await send(path: "api/family/settings", body: JSONEncoder().encode(Input(profile: family.profile, policy: family.policy, revision: family.revision)), parent: parent, connection: connection)
    }
    func usage(_ entry: UsageEntry, connection: ShareConnection) async throws -> FamilyResponse {
        try await send(path: "api/family/usage", body: JSONEncoder().encode(entry), connection: connection)
    }
    func lock(parent: String, connection: ShareConnection) async throws {
        _ = try await send(path: "api/family/lock", body: Data("{}".utf8), parent: parent, connection: connection)
    }
    func validPIN(_ pin: String) -> Bool { pin.range(of: "^[0-9]{6}$", options: .regularExpression) != nil }

    private func send(path: String, body: Data? = nil, parent: String? = nil, connection: ShareConnection) async throws -> FamilyResponse {
        guard let base = connection.validatedURL else { throw FamilyError.unavailable }
        var request = URLRequest(url: base.appendingPathComponent(path), timeoutInterval: 15)
        request.httpMethod = body == nil ? "GET" : "POST"
        request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(parent, forHTTPHeaderField: "x-parent-session")
        let data: Data, response: URLResponse
        do { (data, response) = try await session.data(for: request) }
        catch {
            if Task.isCancelled || (error as? URLError)?.code == .cancelled { throw CancellationError() }
            throw FamilyError.unavailable
        }
        guard let http = response as? HTTPURLResponse else { throw FamilyError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            struct Failure: Decodable { var error: String }
            throw FamilyError.from((try? JSONDecoder().decode(Failure.self, from: data).error) ?? "unavailable")
        }
        guard let result = try? JSONDecoder().decode(FamilyResponse.self, from: data), result.family?.isValid != false else { throw FamilyError.invalidResponse }
        return result
    }
}
