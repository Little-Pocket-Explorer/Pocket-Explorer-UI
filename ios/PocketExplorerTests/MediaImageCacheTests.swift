import UIKit
import XCTest
@testable import PocketExplorer

final class MediaImageCacheTests: XCTestCase {
    func testRepeatedViewsReuseDecodedPixelsAndLargePhotosAreDownsampled() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).png")
        defer { try? FileManager.default.removeItem(at: url) }
        try photo(width: 2400, height: 1200, color: .green).write(to: url, options: .atomic)
        let cache = MediaImageCache()
        let first = await cache.image(at: url, maximumPixelSize: 512)
        let second = await cache.image(at: url, maximumPixelSize: 512)
        XCTAssertNotNil(first)
        XCTAssertTrue(first === second, "Repeated card renders must reuse already-decoded image pixels.")
        XCTAssertEqual(first?.size, CGSize(width: 512, height: 256))
        let tiny = await cache.image(at: url, maximumPixelSize: 1)
        XCTAssertEqual(tiny?.size.width, 16)
        let bounded = await cache.image(at: url, maximumPixelSize: 9000)
        XCTAssertEqual(bounded?.size.width, 2048)
    }

    func testReplacedMissingAndCorruptMediaCannotShowAStaleCachedImage() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).png")
        defer { try? FileManager.default.removeItem(at: url) }
        let cache = MediaImageCache()
        let missing = await cache.image(at: url)
        XCTAssertNil(missing)
        try photo(width: 40, height: 20, color: .green).write(to: url, options: .atomic)
        let original = await cache.image(at: url)
        XCTAssertEqual(original?.size.width, 40)
        try photo(width: 60, height: 30, color: .blue).write(to: url, options: .atomic)
        let replaced = await cache.image(at: url)
        XCTAssertEqual(replaced?.size.width, 60)
        XCTAssertFalse(original === replaced)
        try Data("broken image".utf8).write(to: url, options: .atomic)
        let corrupt = await cache.image(at: url)
        XCTAssertNil(corrupt)
        try FileManager.default.removeItem(at: url)
        let removed = await cache.image(at: url)
        XCTAssertNil(removed)
    }

    private func photo(width: Int, height: Int, color: UIColor) throws -> Data {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        return try XCTUnwrap(UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { context in
            color.setFill(); context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }.pngData())
    }
}
