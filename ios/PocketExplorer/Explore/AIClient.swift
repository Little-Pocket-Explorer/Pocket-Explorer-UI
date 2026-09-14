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
}

struct ArtworkJob: Codable, Equatable, Identifiable {
    var id: String
    var status: String
    var attempts: Int
    var imagePath: String?
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
}

struct AIReceipt: Codable, Equatable {
    var id: UUID
    var question: String
    var status: String
    var reply: AIReply?
}

struct AIClient {
    var session: URLSession = .shared

    func ask(_ record: ExplorationRecord, photo: Data?, connection: ShareConnection) async throws -> AIReceipt {
        struct Input: Encodable { var id: String; var question: String; var language: String; var age: Int; var photo: String? }
        let photoInput = photo.flatMap(Self.imageInput)
        if photo != nil && photoInput == nil { throw AIClientError.photoUnreadable }
        let input = Input(id: record.id.uuidString.lowercased(), question: record.question, language: record.language, age: record.age, photo: photoInput)
        return try await decode(AIReceipt.self, path: "api/explorations", method: "POST", body: JSONEncoder().encode(input), connection: connection)
    }

    func read(_ id: UUID, connection: ShareConnection) async throws -> AIReceipt {
        try await decode(AIReceipt.self, path: "api/explorations/\(id.uuidString.lowercased())", connection: connection)
    }

    func createArtwork(_ id: UUID, connection: ShareConnection) async throws -> ArtworkJob {
        try await decode(ArtworkJob.self, path: "api/explorations/\(id.uuidString.lowercased())/artwork", method: "POST", connection: connection)
    }

    func artwork(_ id: String, retry: Bool = false, connection: ShareConnection) async throws -> ArtworkJob {
        guard UUID(uuidString: id) != nil else { throw AIClientError.invalidResponse }
        return try await decode(ArtworkJob.self, path: "api/artwork/\(id)" + (retry ? "/retry" : ""), method: retry ? "POST" : "GET", connection: connection)
    }

    func image(_ job: ArtworkJob, connection: ShareConnection) async throws -> Data {
        guard UUID(uuidString: job.id) != nil, job.status == "ready", job.imagePath == "/api/artwork/\(job.id)/image" else { throw AIClientError.invalidResponse }
        let data = try await send(path: "api/artwork/\(job.id)/image", method: "GET", body: nil, connection: connection)
        guard data.count <= 12000000, let image = UIImage(data: data), image.size.width == 1024, image.size.height == 1024 else { throw AIClientError.invalidResponse }
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

    private func decode<T: Decodable>(_ type: T.Type, path: String, method: String = "GET", body: Data? = nil, connection: ShareConnection) async throws -> T {
        let data = try await send(path: path, method: method, body: body, connection: connection)
        do { return try JSONDecoder().decode(type, from: data) }
        catch { throw AIClientError.invalidResponse }
    }

    private func send(path: String, method: String, body: Data?, connection: ShareConnection) async throws -> Data {
        guard let base = connection.validatedURL else { throw AIClientError.unavailable }
        var request = URLRequest(url: base.appendingPathComponent(path), timeoutInterval: 105)
        request.httpMethod = method; request.httpBody = body
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AIClientError.invalidResponse }
        if http.statusCode == 429 { throw AIClientError.rateLimited }
        guard (200...299).contains(http.statusCode) else { throw AIClientError.unavailable }
        return data
    }
}

enum AIClientError: LocalizedError {
    case unavailable, invalidResponse, rateLimited, pending, photoUnreadable
    var errorDescription: String? {
        switch self {
        case .unavailable: return L10n.text("Your question is saved. We could not reach your guide. Please try again.")
        case .invalidResponse: return L10n.text("The answer did not arrive correctly. Your question is safe. Please try again.")
        case .rateLimited: return L10n.text("Your guide needs a little break. Please try again later.")
        case .pending: return L10n.text("Your guide is still thinking. Open this question again in a moment.")
        case .photoUnreadable: return L10n.text("This photo could not be prepared. Choose another photo or remove it to ask with words.")
        }
    }
}
