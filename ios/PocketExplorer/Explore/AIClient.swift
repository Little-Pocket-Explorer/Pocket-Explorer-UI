import Foundation
import UIKit

struct DiscoveryQuiz: Codable, Equatable {
    var question: String
    var choices: [String]
    var correctIndex: Int
    var explanation: String

    var isValid: Bool { choices.count == 3 && choices.indices.contains(correctIndex) }
}

struct AIReply: Codable, Equatable {
    var title: String
    var answer: String
    var invitation: String
    var category: String
    var artworkPrompt: String
    var quiz: DiscoveryQuiz
    var advancesCard: Bool? = nil
}

struct ArtworkJob: Codable, Equatable, Identifiable {
    var id: String
    var status: String
    var attempts: Int
    var imagePath: String?
    var createdAt: Double? = nil
    var updatedAt: Double? = nil
    var expiresAt: Double? = nil
    var canRetry: Bool? = nil

    var allowsRetry: Bool { status == "failed" && attempts < 2 && canRetry != false }
}

struct ExplorationRecord: Codable, Equatable, Identifiable {
    var id: UUID
    var question: String
    var language: String
    var age: Int
    var createdAt: Date
    var photoFilename: String?
    var reply: AIReply?
    var cardID: UUID?
    var preparedContent: PreparedContent? = nil
    var preparedRegistered: Bool? = nil
    var preparedArtwork: ArtworkJob? = nil
    var preparedUnavailable: Bool? = nil
    var conversationID: UUID? = nil
    var parentID: UUID? = nil
    var evolveFrom: String? = nil
}

struct AIReceipt: Codable, Equatable {
    var id: UUID
    var question: String
    var status: String
    var reply: AIReply?
}

struct AIClient {
    var session: URLSession = .shared
    var permission: @Sendable (ShareConnection) throws -> Void = { try AIPermissionCache().require($0) }

    func answer(_ record: ExplorationRecord, photo: Data?, connection: ShareConnection,
                resume: Bool = false, deadline: Duration = .seconds(125), pollInterval: Duration = .seconds(3)) async throws -> AIReceipt {
        try await withThrowingTaskGroup(of: AIReceipt.self) { group in
            group.addTask {
                var receipt: AIReceipt
                if resume {
                    do { receipt = try await read(record.id, connection: connection) }
                    catch AIClientError.notFound { receipt = try await ask(record, photo: photo, connection: connection) }
                } else { receipt = try await ask(record, photo: photo, connection: connection) }
                while receipt.status == "thinking" {
                    try Task.checkCancellation()
                    guard receipt.id == record.id else { throw AIClientError.invalidResponse }
                    try await Task.sleep(for: pollInterval)
                    receipt = try await read(record.id, connection: connection)
                }
                try Task.checkCancellation()
                guard receipt.id == record.id else { throw AIClientError.invalidResponse }
                if receipt.status == "failed" { throw AIClientError.answerFailed }
                guard receipt.status == "ready", receipt.reply?.quiz.isValid == true else { throw AIClientError.invalidResponse }
                return receipt
            }
            group.addTask { try await Task.sleep(for: deadline); throw AIClientError.pending }
            defer { group.cancelAll() }
            guard let receipt = try await group.next() else { throw CancellationError() }
            return receipt
        }
    }

    func ask(_ record: ExplorationRecord, photo: Data?, connection: ShareConnection) async throws -> AIReceipt {
        if record.preparedContent == nil { try permission(connection) }
        struct Input: Encodable {
            var id: String; var question: String; var language: String; var age: Int; var photo: String?; var prepared: PreparedReference?
            var conversationID: String?; var parentID: String?; var evolveFrom: String?
        }
        guard record.photoFilename == nil || photo != nil else { throw AIClientError.photoUnreadable }
        let photoInput = photo.flatMap(Self.imageInput)
        if photo != nil && photoInput == nil { throw AIClientError.photoUnreadable }
        let input = Input(id: record.id.uuidString.lowercased(), question: record.question, language: record.language, age: record.age, photo: photoInput, prepared: record.preparedContent?.reference,
            conversationID: record.conversationID?.uuidString.lowercased(), parentID: record.parentID?.uuidString.lowercased(), evolveFrom: record.evolveFrom)
        return try await decode(AIReceipt.self, path: "api/explorations", method: "POST", body: JSONEncoder().encode(input), connection: connection, timeout: 105)
    }

    func read(_ id: UUID, connection: ShareConnection) async throws -> AIReceipt {
        try await decode(AIReceipt.self, path: "api/explorations/\(id.uuidString.lowercased())", connection: connection)
    }

    func createArtwork(_ id: UUID, connection: ShareConnection, prepared: Bool = false) async throws -> ArtworkJob {
        if !prepared { try permission(connection) }
        return try await decode(ArtworkJob.self, path: "api/explorations/\(id.uuidString.lowercased())/artwork", method: "POST", connection: connection)
    }

    func artwork(_ id: String, retry: Bool = false, connection: ShareConnection) async throws -> ArtworkJob {
        guard UUID(uuidString: id) != nil else { throw AIClientError.invalidResponse }
        if retry { try permission(connection) }
        return try await decode(ArtworkJob.self, path: "api/artwork/\(id)" + (retry ? "/retry" : ""), method: retry ? "POST" : "GET", connection: connection)
    }

    func image(_ job: ArtworkJob, connection: ShareConnection) async throws -> Data {
        guard UUID(uuidString: job.id) != nil, job.status == "ready", job.imagePath == "/api/artwork/\(job.id)/image" else { throw AIClientError.invalidResponse }
        let data = try await send(path: "api/artwork/\(job.id)/image", method: "GET", body: nil, connection: connection, timeout: 45)
        guard data.count <= 12000000, let image = UIImage(data: data), image.size.width == 1024, image.size.height == 1024 else { throw AIClientError.invalidArtwork }
        return data
    }

    static func imageInput(_ data: Data) -> String? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, 768 / max(image.size.width, image.size.height))
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        let size = CGSize(width: max(1, image.size.width * scale), height: max(1, image.size.height * scale))
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
        guard let jpeg = resized.jpegData(compressionQuality: 0.7), jpeg.count < 800000 else { return nil }
        return "data:image/jpeg;base64," + jpeg.base64EncodedString()
    }

    private func decode<T: Decodable>(_ type: T.Type, path: String, method: String = "GET", body: Data? = nil, connection: ShareConnection, timeout: TimeInterval = 20) async throws -> T {
        let data = try await send(path: path, method: method, body: body, connection: connection, timeout: timeout)
        do { return try JSONDecoder().decode(type, from: data) }
        catch { throw AIClientError.invalidResponse }
    }

    private func send(path: String, method: String, body: Data?, connection: ShareConnection, timeout: TimeInterval) async throws -> Data {
        guard let base = connection.validatedURL else { throw AIClientError.unavailable }
        var request = URLRequest(url: base.appendingPathComponent(path), timeoutInterval: timeout)
        request.httpMethod = method; request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: Data
        let response: URLResponse
        do { (data, response) = try await session.data(for: request) }
        catch let error as URLError {
            if Task.isCancelled || error.code == .cancelled { throw CancellationError() }
            if error.code == .timedOut { throw AIClientError.timedOut }
            if [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(error.code) { throw AIClientError.offline }
            throw AIClientError.unavailable
        }
        guard let http = response as? HTTPURLResponse else { throw AIClientError.invalidResponse }
        if http.statusCode == 403,
           (try? JSONDecoder().decode([String: String].self, from: data)["error"]) == "ai_permission_required" { throw AIDataPermissionError.required }
        if http.statusCode == 429 {
            struct Failure: Decodable { var error: String }
            let code = data.count <= 4096 ? (try? JSONDecoder().decode(Failure.self, from: data).error) : nil
            switch code {
            case "demo_limit": throw AIClientError.demoLimit
            case "daily_limit": throw AIClientError.dailyLimit
            case "image_retry_limit": throw AIClientError.artworkLimit
            default: throw AIClientError.rateLimited
            }
        }
        if http.statusCode == 409 {
            struct Failure: Decodable { var error: String }
            let code = data.count <= 4096 ? (try? JSONDecoder().decode(Failure.self, from: data).error) : nil
            throw code == "prepared_content_unavailable" ? AIClientError.preparedUnavailable : AIClientError.requestConflict
        }
        if http.statusCode == 404 { throw AIClientError.notFound }
        guard (200...299).contains(http.statusCode) else { throw AIClientError.unavailable }
        return data
    }
}

enum AIClientError: LocalizedError, Equatable {
    case unavailable, invalidResponse, rateLimited, pending, photoUnreadable
    case answerFailed, offline, timedOut, dailyLimit, demoLimit, artworkLimit, requestConflict, notFound, invalidArtwork, preparedUnavailable

    var allowsImmediateRetry: Bool { ![.dailyLimit, .demoLimit, .artworkLimit, .requestConflict, .preparedUnavailable].contains(self) }
    var errorDescription: String? {
        switch self {
        case .unavailable: return L10n.text("Your question is saved. We could not reach your guide. Please try again.")
        case .invalidResponse: return L10n.text("The answer did not arrive correctly. Your question is safe. Please try again.")
        case .invalidArtwork: return L10n.text("This illustration is unavailable. Your card and words are still saved.")
        case .rateLimited: return L10n.text("Your guide needs a little break. Please try again later.")
        case .pending: return L10n.text("Your guide is still thinking. Open this question again in a moment.")
        case .photoUnreadable: return L10n.text("This photo could not be prepared. Choose another photo or remove it to ask with words.")
        case .answerFailed: return L10n.text("Your guide couldn't finish this answer. Your question is saved, and you can ask again.")
        case .offline: return L10n.text("You're offline. Your question is saved. Try again when you're connected.")
        case .timedOut: return L10n.text("The connection took too long. Your question is saved. Check again in a moment.")
        case .dailyLimit: return L10n.text("Today's AI allowance is used. Your saved discoveries are still here.")
        case .demoLimit: return L10n.text("This demo's AI allowance is used. You can still enjoy your saved discoveries.")
        case .artworkLimit: return L10n.text("This picture can't be retried. Your discovery is still saved.")
        case .requestConflict: return L10n.text("This question has changed. Start a new question to explore it.")
        case .preparedUnavailable: return L10n.text("This saved discovery can no longer be shared. Your card and memories are safe.")
        case .notFound: return L10n.text("We couldn't find this saved answer. You can ask the question again.")
        }
    }
}
