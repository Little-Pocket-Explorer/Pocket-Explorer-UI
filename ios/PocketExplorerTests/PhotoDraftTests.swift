import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import PocketExplorer

@MainActor final class PhotoDraftTests: XCTestCase {
    func testPreparationDownsamplesCorrectsOrientationAndRemovesMetadata() async throws {
        let original = makePhoto(size: CGSize(width: 2400, height: 1200), rotated: true)
        let prepared = try await PhotoPreparation.shared.prepare(original)
        let source = try XCTUnwrap(CGImageSourceCreateWithData(prepared.data as CFData, nil))
        let properties = try XCTUnwrap(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 800)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 1600)
        XCTAssertNil(properties[kCGImagePropertyGPSDictionary])
        XCTAssertEqual(CGImageSourceGetType(source) as String?, UTType.jpeg.identifier)
        XCTAssertEqual(prepared.image.imageOrientation, .up)
        XCTAssertLessThan(prepared.data.count, 1_000_000)
    }
    func testPreparationRejectsCorruptAndOversizedInputs() async {
        for (data, expected) in [(Data("not an image".utf8), PhotoError.unreadable), (Data(repeating: 0, count: 30_000_001), .tooLarge)] {
            do { _ = try await PhotoPreparation.shared.prepare(data); XCTFail("Invalid image accepted") }
            catch { XCTAssertEqual(error.localizedDescription, expected.localizedDescription) }
        }
    }
    func testSuccessfulSelectionPreparesOneReusablePreview() async throws {
        let draft = PhotoDraft()
        let original = makePhoto()
        let work = draft.load { original }
        XCTAssertTrue(draft.isLoading)
        await work.value
        XCTAssertFalse(draft.isLoading)
        XCTAssertNotNil(draft.image)
        XCTAssertNotNil(draft.data)
        XCTAssertTrue(draft.hasChanges)
        draft.markSaved()
        XCTAssertFalse(draft.hasChanges)
        XCTAssertNil(draft.error)
        let source = try XCTUnwrap(CGImageSourceCreateWithData(try XCTUnwrap(draft.data) as CFData, nil))
        XCTAssertNotNil(CGImageSourceCreateImageAtIndex(source, 0, nil))
    }
    func testRestoringASavedPhotoPreservesRequestBytes() async {
        let original = makePhoto(rotated: true)
        let draft = PhotoDraft()
        await draft.load(preservingData: true) { original }.value
        XCTAssertEqual(draft.data, original)
        XCTAssertFalse(draft.hasChanges)
        XCTAssertNotNil(draft.image)
    }
    func testASecondSelectionCannotBeOverwrittenByAnOlderCompletion() async throws {
        let pending = PendingPhoto()
        let draft = PhotoDraft()
        let old = draft.load { await pending.load() }
        await pending.waitUntilStarted()
        let original = makePhoto()
        await draft.load { original }.value
        let expected = draft.data
        await pending.complete(Data("late invalid photo".utf8))
        await old.value
        XCTAssertEqual(draft.data, expected)
        XCTAssertNil(draft.error)
        XCTAssertFalse(draft.isLoading)
    }
    func testRemovingAPhotoCancelsASelectionEvenWhenItsLoaderIgnoresCancellation() async {
        let pending = PendingPhoto()
        let draft = PhotoDraft()
        let work = draft.load { await pending.load() }
        await pending.waitUntilStarted()
        draft.clear()
        await pending.complete(makePhoto())
        await work.value
        XCTAssertNil(draft.data)
        XCTAssertNil(draft.image)
        XCTAssertTrue(draft.hasChanges)
        XCTAssertFalse(draft.isLoading)
        XCTAssertNil(draft.error)
    }
    func testTimeoutRestoresControlsAndRejectsLatePhotoWithoutDroppingThePreviousOne() async throws {
        let draft = PhotoDraft()
        let original = makePhoto()
        await draft.load { original }.value
        let expected = draft.data
        let pending = PendingPhoto()
        let work = draft.load(timeout: .milliseconds(30)) { await pending.load() }
        await pending.waitUntilStarted()
        try await Task.sleep(for: .milliseconds(80))
        XCTAssertFalse(draft.isLoading)
        XCTAssertEqual(draft.error, PhotoError.timedOut.localizedDescription)
        XCTAssertEqual(draft.data, expected)
        await pending.complete(makePhoto(rotated: true))
        await work.value
        XCTAssertEqual(draft.data, expected)
        XCTAssertEqual(draft.error, PhotoError.timedOut.localizedDescription)
    }
    func testNilOrFailedSelectionRetainsTheLastPhotoAndReportsRecovery() async {
        let draft = PhotoDraft()
        let original = makePhoto()
        await draft.load { original }.value
        let expected = draft.data
        await draft.load { nil }.value
        XCTAssertEqual(draft.data, expected)
        XCTAssertEqual(draft.error, PhotoError.unreadable.localizedDescription)
        await draft.load { throw URLError(.notConnectedToInternet) }.value
        XCTAssertEqual(draft.error, PhotoError.downloadUnavailable.localizedDescription)
        XCTAssertEqual(draft.data, expected)
        XCTAssertFalse(draft.isLoading)
        draft.cancel()
        XCTAssertNil(draft.error)
        XCTAssertEqual(draft.data, expected)
        draft.clear()
        XCTAssertNil(draft.data)
    }
    func testFailedRestoreIsNotAnIntentionalPhotoChangeAndCanRetryTheSameBytes() async {
        let draft = PhotoDraft()
        await draft.load(preservingData: true) { Data("damaged saved photo".utf8) }.value
        XCTAssertFalse(draft.hasChanges)
        XCTAssertNotNil(draft.error)
        let original = makePhoto()
        await draft.load(preservingData: true) { original }.value
        XCTAssertFalse(draft.hasChanges)
        XCTAssertEqual(draft.data, original)
        XCTAssertNil(draft.error)
        draft.clear()
        XCTAssertTrue(draft.hasChanges)
    }
    private func makePhoto(size: CGSize = CGSize(width: 180, height: 90), rotated: Bool = false) -> Data {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.systemGreen.setFill(); context.fill(CGRect(origin: .zero, size: size))
        }
        let output = NSMutableData()
        let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image.cgImage!, [kCGImagePropertyOrientation: rotated ? 6 : 1, kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 30, kCGImagePropertyGPSLatitudeRef: "N"]] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return output as Data
    }
}

private actor PendingPhoto {
    private var continuation: CheckedContinuation<Data?, Never>?
    func load() async -> Data? { await withCheckedContinuation { continuation = $0 } }
    func complete(_ data: Data?) { continuation?.resume(returning: data); continuation = nil }
    func waitUntilStarted() async {
        for _ in 0..<100 {
            if continuation != nil { return }
            try? await Task.sleep(for: .milliseconds(5))
        }
        XCTFail("Photo loader did not start")
    }
}
