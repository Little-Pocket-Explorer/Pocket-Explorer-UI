import CryptoKit
import Foundation
import UIKit

struct PreparedAssets {
    var directory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("PreparedDiscovery")
    var session: URLSession = NarrationClient.session

    func cached(_ asset: PreparedAsset, bundled: String? = nil) -> Data? {
        let file = directory.appendingPathComponent(asset.path.hasSuffix(".png") ? "artwork" : "narration")
            .appendingPathComponent(URL(fileURLWithPath: asset.path).lastPathComponent)
        if let data = try? Data(contentsOf: file), valid(data, for: asset) { return data }
        if let bundled, bundled.range(of: "^[a-z0-9-]+$", options: .regularExpression) != nil,
           let url = Bundle.main.url(forResource: bundled, withExtension: "png"),
           let data = try? Data(contentsOf: url), valid(data, for: asset) { return data }
        return nil
    }

    func load(_ asset: PreparedAsset, base: URL, bundled: String? = nil) async throws -> Data {
        if let data = cached(asset, bundled: bundled) { return data }
        let image = asset.path.hasSuffix(".png")
        guard asset.isValid(extension: image ? "png" : "wav") else { throw RecommendationError.invalidAsset }
        let url = base.appendingPathComponent(String(asset.path.dropFirst()))
        let (data, response) = try await session.data(for: URLRequest(url: url, timeoutInterval: 20))
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse, response.statusCode == 200,
              response.mimeType == (image ? "image/png" : "audio/wav"), valid(data, for: asset) else { throw RecommendationError.invalidAsset }
        let folder = directory.appendingPathComponent(image ? "artwork" : "narration")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? data.write(to: folder.appendingPathComponent(url.lastPathComponent), options: .atomic)
        return data
    }

    func valid(_ data: Data, for asset: PreparedAsset) -> Bool {
        guard data.count == asset.bytes, data.count <= 12_000_000,
              SHA256.hash(data: data).map({ String(format: "%02x", $0) }).joined() == asset.sha256 else { return false }
        if asset.path.hasSuffix(".png") {
            guard let image = UIImage(data: data) else { return false }
            return image.size.width == 1024 && image.size.height == 1024
        }
        return NarrationClient.isAudio(data)
    }

    func prune(protecting assets: Set<PreparedAsset>) {
        let protected = Set(assets.map { URL(fileURLWithPath: $0.path).lastPathComponent })
        for (kind, limit) in [("artwork", 64_000_000), ("narration", 32_000_000)] {
            let folder = directory.appendingPathComponent(kind)
            let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey])) ?? []
            let entries = files.compactMap { url -> (URL, Int, Date)? in
                guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]), let size = values.fileSize else { return nil }
                return (url, size, values.contentModificationDate ?? .distantPast)
            }.sorted { $0.2 < $1.2 }
            var total = entries.reduce(0) { $0 + $1.1 }
            for entry in entries where total > limit && !protected.contains(entry.0.lastPathComponent) {
                try? FileManager.default.removeItem(at: entry.0); total -= entry.1
            }
        }
    }
}
