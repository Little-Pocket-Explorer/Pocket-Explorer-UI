import MapKit
import XCTest
@testable import PocketExplorer

@MainActor
final class MapRenderingTests: XCTestCase {
    func testMarkerChangesAfterAtomicReplacementAndFallsBackAfterRemovalOrCorruption() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        var state = JournalState.examples()
        let trip = state.trips[0]
        state.discoveries = [Discovery(id: UUID(), tripID: trip.id, subject: .discovery,
            question: "Why?", observation: "Blue", explanation: "Light", createdAt: Date(), artworkFilename: "marker.png")]
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: state)
        let url = store.mediaURL("marker.png")
        let coordinator = WorldMap(trips: [trip], select: { _ in }, store: store).makeCoordinator()
        let annotation = TripAnnotation(trip: trip)
        let view = try XCTUnwrap(coordinator.mapView(MKMapView(), viewFor: annotation))
        let fallback = try XCTUnwrap(view.image?.pngData())
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        func save(_ color: UIColor) throws {
            let image = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024), format: format).image { context in
                color.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
            }
            try XCTUnwrap(image.pngData()).write(to: url, options: .atomic)
        }
        try save(.blue)
        coordinator.configure(view, annotation: annotation)
        let blue = try XCTUnwrap(view.image?.pngData())
        XCTAssertNotEqual(blue, fallback)
        try save(.red)
        coordinator.configure(view, annotation: annotation)
        XCTAssertNotEqual(view.image?.pngData(), blue)
        XCTAssertNotEqual(view.image?.pngData(), fallback)
        try Data("damaged image".utf8).write(to: url, options: .atomic)
        coordinator.configure(view, annotation: annotation)
        XCTAssertEqual(view.image?.pngData(), fallback)
        try FileManager.default.removeItem(at: url)
        coordinator.configure(view, annotation: annotation)
        XCTAssertEqual(view.image?.pngData(), fallback)
        var updated = trip
        updated.title = "My new trip title"
        let unchangedImage = view.image
        coordinator.configure(view, annotation: TripAnnotation(trip: updated))
        XCTAssertTrue(view.image === unchangedImage)
        XCTAssertTrue(view.accessibilityLabel?.contains(updated.title) == true)
    }

    func testReusedAnnotationSwitchesArtworkAndKeepsTheMatchingTrip() throws {
        let store = try TripStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("journal.json"))
        defer { try? FileManager.default.removeItem(at: store.fileURL.deletingLastPathComponent()) }
        let coordinator = WorldMap(trips: store.state.trips, select: { _ in }, store: store).makeCoordinator()
        let first = TripAnnotation(trip: store.state.trips[0])
        let second = TripAnnotation(trip: store.state.trips[1])
        let view = try XCTUnwrap(coordinator.mapView(MKMapView(), viewFor: first))
        let initial = view.image
        coordinator.configure(view, annotation: second)
        XCTAssertFalse(view.image === initial)
        XCTAssertEqual(view.accessibilityIdentifier, "map-trip-\(second.trip.id)")
        coordinator.configure(view, annotation: first)
        XCTAssertTrue(view.image === initial)
    }

    func testRefreshingUnchangedArtworkReusesItsRenderedPixels() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        var state = JournalState.examples()
        let trip = state.trips[0]
        let name = "generated-marker.png"
        state.discoveries = [Discovery(id: UUID(), tripID: trip.id, subject: .discovery,
            question: "Why is the sky blue?", observation: "Blue light", explanation: "Light scatters.",
            createdAt: Date(), artworkFilename: name)]
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: state)
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        let source = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024), format: format).image { context in
            UIColor.blue.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
            for index in 0..<32 {
                UIColor(red: CGFloat(index) / 32, green: 0.3, blue: 0.8, alpha: 1).setFill()
                context.fill(CGRect(x: index * 32, y: 0, width: 16, height: 100))
            }
        }
        try XCTUnwrap(source.pngData()).write(to: store.mediaURL(name), options: .atomic)
        let coordinator = WorldMap(trips: [trip], select: { _ in }, store: store).makeCoordinator()
        let annotation = TripAnnotation(trip: trip)
        let view = try XCTUnwrap(coordinator.mapView(MKMapView(), viewFor: annotation))
        let initial = try XCTUnwrap(view.image)
        let started = ContinuousClock.now
        var reused = 0
        for _ in 0..<100 {
            coordinator.configure(view, annotation: annotation)
            if view.image === initial { reused += 1 }
        }
        let attachment = XCTAttachment(string: "100 identical marker refreshes: \(started.duration(to: .now)). Reused rendered image: \(reused)/100.")
        attachment.name = "map-marker-repeat-cost"; attachment.lifetime = .keepAlways; add(attachment)
        XCTAssertEqual(reused, 100, "Unchanged map content should retain decoded marker pixels when SwiftUI refreshes the surrounding controls.")
        XCTAssertEqual(view.image?.size, CGSize(width: 54, height: 54))
    }
}
