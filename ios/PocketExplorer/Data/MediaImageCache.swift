import Foundation
import ImageIO
import UIKit

actor MediaImageCache {
    static let shared = MediaImageCache()
    private let cache = NSCache<NSString, UIImage>()

    init() {
        cache.totalCostLimit = 32 * 1024 * 1024
        cache.countLimit = 64
    }

    func image(at url: URL, maximumPixelSize: Int = 1024) -> UIImage? {
        // URL resource values can remain cached across an atomic file replacement.
        guard let values = try? FileManager.default.attributesOfItem(atPath: url.path) else { return nil }
        let size = min(2048, max(16, maximumPixelSize))
        let modified = (values[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
        let key = "\(url.absoluteString)|\(modified)|\(values[.size] ?? 0)|\(values[.systemFileNumber] ?? 0)|\(size)" as NSString
        if let image = cache.object(forKey: key) { return image }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: size
              ] as CFDictionary) else { return nil }
        let image = UIImage(cgImage: thumbnail)
        cache.setObject(image, forKey: key, cost: thumbnail.bytesPerRow * thumbnail.height)
        return image
    }
}
