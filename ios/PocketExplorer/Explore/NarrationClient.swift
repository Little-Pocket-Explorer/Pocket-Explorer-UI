import AVFoundation
import CryptoKit
import Foundation

struct NarrationClient {
    private static let redirects = NarrationRedirectPolicy()
    static let session = URLSession(configuration: .ephemeral, delegate: redirects, delegateQueue: nil)
    var session: URLSession = Self.session
    var directory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Narration")
    var now: Date = Date()
    static let maximumBytes = 12_000_000
    var preparedAssets = PreparedAssets()

    func audio(for record: ExplorationRecord, connection: ShareConnection) async throws -> Data {
        guard let base = connection.validatedURL, let answer = record.reply?.answer else { throw VoiceError.unavailable }
        if let prepared = record.preparedContent {
            guard let narration = prepared.narration else { throw VoiceError.unavailable }
            do { return try await preparedAssets.load(narration, base: base) }
            catch is CancellationError { throw CancellationError() }
            catch { if record.preparedRegistered != true { throw error } }
        }
        let identity = [base.absoluteString, connection.ownerKey, record.language, answer, "azure-neural-v2"].joined(separator: "\n")
        let key = SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
        let file = directory.appendingPathComponent(key).appendingPathExtension("wav")
        if let values = try? file.resourceValues(forKeys: [.contentModificationDateKey]),
           let date = values.contentModificationDate, now.timeIntervalSince(date) < 30 * 86400,
           let data = try? Data(contentsOf: file), Self.isAudio(data) {
            try Task.checkCancellation()
            return data
        }
        var request = URLRequest(url: base.appendingPathComponent("api/narration/\(record.id.uuidString.lowercased())"), timeoutInterval: 12)
        request.httpMethod = "POST"
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue("audio/wav", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              http.mimeType == "audio/wav", Self.isAudio(data) else { throw VoiceError.unavailable }
        // Audio is a disposable cache. A full disk must not prevent playback.
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: file, options: .atomic)
        prune()
        return data
    }

    static func isAudio(_ data: Data) -> Bool {
        guard data.count > 44, data.count <= maximumBytes,
              data.prefix(4) == Data("RIFF".utf8), data[8..<12] == Data("WAVE".utf8),
              let audio = try? AVAudioPlayer(data: data) else { return false }
        return audio.duration > 0 && audio.duration <= 300
    }

    private func prune() {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey])) ?? []
        let entries = files.compactMap { file -> (URL, Date, Int)? in
            guard let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]) else { return nil }
            return (file, values.contentModificationDate ?? .distantPast, values.fileSize ?? 0)
        }.sorted { $0.1 < $1.1 }
        var size = entries.reduce(0) { $0 + $1.2 }
        for entry in entries where size > 32_000_000 || now.timeIntervalSince(entry.1) >= 30 * 86400 {
            try? FileManager.default.removeItem(at: entry.0)
            size -= entry.2
        }
    }
}

final class NarrationRedirectPolicy: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
