import MapKit
import XCTest
@testable import PocketExplorer

@MainActor
final class WorldMapTests: XCTestCase {
    func testMapAnnotationsFollowSavedPlacesAndSelectionUsesTheMatchingTrip() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"))
        var selected: Trip?
        let parent = WorldMap(trips: store.state.trips, select: { selected = $0 }, store: store)
        let coordinator = parent.makeCoordinator()
        let map = MKMapView(frame: CGRect(x: 0, y: 0, width: 375, height: 360))
        map.delegate = coordinator
        coordinator.synchronize(map)
        let annotations = map.annotations.compactMap { $0 as? TripAnnotation }
        XCTAssertEqual(annotations.count, 3)
        let first = try XCTUnwrap(annotations.first)
        XCTAssertEqual(first.coordinate.latitude, first.trip.place?.latitude)
        let view = try XCTUnwrap(coordinator.mapView(map, viewFor: first))
        XCTAssertEqual(view.accessibilityIdentifier, "map-trip-\(first.trip.id)")
        XCTAssertEqual(view.image?.size.width, 54)
        coordinator.mapView(map, didSelect: view)
        XCTAssertEqual(selected?.id, first.trip.id)
        coordinator.synchronize(map)
        XCTAssertTrue(map.annotations.contains { ($0 as? TripAnnotation) === first })
        coordinator.parent = WorldMap(trips: [], select: { _ in })
        coordinator.synchronize(map)
        XCTAssertTrue(map.annotations.isEmpty)
    }

    func testUserLocationAndMissingImagesDoNotBecomeUnrelatedDiscoveries() throws {
        let coordinator = WorldMap(trips: [], select: { _ in }).makeCoordinator()
        let map = MKMapView()
        XCTAssertNil(coordinator.mapView(map, viewFor: MKUserLocation()))
        coordinator.mapView(map, didSelect: MKAnnotationView(annotation: MKUserLocation(), reuseIdentifier: nil))
        let trip = Trip(id: UUID(), title: "A private discovery", startedAt: Date(), isExample: false)
        let annotation = TripAnnotation(trip: trip)
        XCTAssertEqual(annotation.coordinate.latitude, 0)
        XCTAssertEqual(annotation.coordinate.longitude, 0)
        let view = try XCTUnwrap(coordinator.mapView(map, viewFor: annotation))
        XCTAssertEqual(view.image?.size.height, 54)
        XCTAssertTrue(view.accessibilityLabel?.contains(trip.title) == true)
    }

    func testPendingGeneratedCardUsesTheLeafArtworkInsteadOfAnEmptyMarker() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        var state = JournalState.examples()
        let trip = state.trips[0]
        state.discoveries = [Discovery(id: UUID(), tripID: trip.id, subject: .discovery,
                                     question: "Why?", observation: "Blue", explanation: "Light", createdAt: Date())]
        let store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: state)
        let map = MKMapView()
        let annotation = TripAnnotation(trip: trip)
        let pending = WorldMap(trips: [trip], select: { _ in }, store: store).makeCoordinator()
        let fallback = WorldMap(trips: [trip], select: { _ in }).makeCoordinator()
        let actual = try XCTUnwrap(pending.mapView(map, viewFor: annotation)?.image?.pngData())
        let expected = try XCTUnwrap(fallback.mapView(map, viewFor: annotation)?.image?.pngData())
        XCTAssertEqual(actual, expected)
    }
}
