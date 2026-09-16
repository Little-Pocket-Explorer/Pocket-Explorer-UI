import CryptoKit
import Foundation

struct ExplorationDraft: Codable, Equatable {
    var question = ""
    var observation = ""
    var recordID: UUID?
    var parentID: UUID?
    var photo: Data?
    var photoChanged = false
    var isEmpty: Bool { question.isEmpty && observation.isEmpty && recordID == nil && photo == nil }
}

struct ExplorationDraftFile {
    let url: URL
    var writer: (Data, URL) throws -> Void = { try $0.write(to: $1, options: .atomic) }

    init(journal: URL, context: [String]) {
        let bytes = (try? JSONEncoder().encode(context)) ?? Data()
        let name = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
        url = journal.deletingLastPathComponent().appendingPathComponent("drafts/\(name).json")
    }

    func load() throws -> ExplorationDraft? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        guard data.count <= 8_000_000 else { throw CocoaError(.coderReadCorrupt) }
        return try JSONDecoder().decode(ExplorationDraft.self, from: data)
    }

    func save(_ draft: ExplorationDraft) throws {
        if draft.isEmpty { try remove(); return }
        let data = try JSONEncoder().encode(draft)
        guard data.count <= 8_000_000 else { throw PhotoError.tooLarge }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try writer(data, url)
    }

    func remove() throws {
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    }
}
