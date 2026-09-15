import Foundation
import ImageIO
import Observation
import UIKit
import UniformTypeIdentifiers

actor PhotoPreparation {
    static let shared = PhotoPreparation()
    struct Result {
        var data: Data
        var image: UIImage
    }
    func prepare(_ data: Data) throws -> Result {
        guard data.count <= 30_000_000 else { throw PhotoError.tooLarge }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 1600,
                kCGImageSourceShouldCacheImmediately: true
              ] as CFDictionary) else { throw PhotoError.unreadable }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else { throw PhotoError.unreadable }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.82] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw PhotoError.unreadable }
        return Result(data: output as Data, image: UIImage(cgImage: image))
    }
}

enum PhotoError: LocalizedError {
    case unreadable, timedOut, downloadUnavailable, tooLarge
    var errorDescription: String? {
        switch self {
        case .unreadable: return L10n.text("This photo couldn't be opened. Try choosing another photo.")
        case .timedOut: return L10n.text("This photo is taking too long. Try again or choose another one.")
        case .downloadUnavailable: return L10n.text("This photo may need to download. Check your connection and try again.")
        case .tooLarge: return L10n.text("This photo is too large. Try choosing a smaller one.")
        }
    }
}

@MainActor @Observable
final class PhotoDraft {
    private(set) var data: Data?
    private(set) var image: UIImage?
    private(set) var isLoading = false
    private(set) var error: String?
    private(set) var hasChanges = false
    private var generation = UUID()
    private var task: Task<Void, Never>?
    private var timeoutTask: Task<Void, Never>?

    @discardableResult
    func load(preservingData: Bool = false, timeout: Duration = .seconds(30), using loader: @escaping @Sendable () async throws -> Data?) -> Task<Void, Never> {
        cancel()
        isLoading = true
        let token = generation
        let work = Task { [weak self] in
            do {
                guard let data = try await loader() else { throw PhotoError.unreadable }
                try Task.checkCancellation()
                let prepared = try await PhotoPreparation.shared.prepare(data)
                try Task.checkCancellation()
                guard let self, self.generation == token else { return }
                self.data = preservingData ? data : prepared.data; self.image = prepared.image
                self.hasChanges = !preservingData
            } catch {
                guard let self, self.generation == token, !Task.isCancelled else { return }
                self.error = (error as? PhotoError ?? (error is URLError ? .downloadUnavailable : .unreadable)).localizedDescription
            }
            guard let self, self.generation == token else { return }
            self.isLoading = false; self.timeoutTask?.cancel()
        }
        task = work
        timeoutTask = Task { [weak self] in
            do { try await Task.sleep(for: timeout) } catch { return }
            guard let self, self.generation == token else { return }
            self.cancel(); self.error = PhotoError.timedOut.localizedDescription
        }
        return work
    }
    func cancel() {
        generation = UUID(); task?.cancel(); timeoutTask?.cancel()
        task = nil; timeoutTask = nil; isLoading = false; error = nil
    }
    func markSaved() { hasChanges = false }
    func clear() { cancel(); data = nil; image = nil; hasChanges = true }
}
