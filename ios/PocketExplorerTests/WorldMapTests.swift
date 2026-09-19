import MapKit
import XCTest
@testable import PocketExplorer

@MainActor
final class WorldMapTests: XCTestCase {
    func testMapRendersEventsAndSharedCardsAndRecentersOnLocationRequest() throws {
        let trip = JournalState.examples().trips[0]
        let eventID = "77777777-7777-4777-8777-777777777777"
        let event = ExplorerEvent(id: eventID, revision: 1, title: "Sky watchers", description: "Look up", language: "en", organizer: "Nature Club", place: "Park", location: ExplorerCoordinate(latitude: -33.86, longitude: 151.21), radius: 200, startsAt: 1, endsAt: 2, minAge: 5, maxAge: 18, background: "stargazing", demonstration: true, challenge: .init(question: "Why?", choices: ["A", "B", "C"]), artworkPath: "/api/events/\(eventID)/artwork?language=en")
        let cardID = "11111111-1111-4111-8111-111111111111"
        let card = SharedMapCard(id: cardID, audience: .friendsApproximate, location: ExplorerCoordinate(latitude: -33.87, longitude: 151.22), publishedAt: 1, title: "Moon", question: "Why?", answer: "Light", category: "space", language: "en", version: 1, tier: .common, artworkPath: nil)
        var selectedEvent: ExplorerEvent?, selectedCard: SharedMapCard?
        let parent = WorldMap(trips: [trip], events: [event], sharedCards: [card], focus: event.location, focusRevision: 1,
            select: { _ in }, selectEvent: { selectedEvent = $0 }, selectSharedCard: { selectedCard = $0 })
        let coordinator = parent.makeCoordinator(), map = MKMapView(frame: CGRect(x: 0, y: 0, width: 390, height: 600))
        map.delegate = coordinator; coordinator.synchronize(map)
        XCTAssertEqual(map.annotations.compactMap { $0 as? TripAnnotation }.count, 1)
        let eventAnnotation = try XCTUnwrap(map.annotations.compactMap { $0 as? EventMapAnnotation }.first)
        let cardAnnotation = try XCTUnwrap(map.annotations.compactMap { $0 as? SharedCardAnnotation }.first)
        let eventView = try XCTUnwrap(coordinator.mapView(map, viewFor: eventAnnotation))
        let cardView = try XCTUnwrap(coordinator.mapView(map, viewFor: cardAnnotation))
        XCTAssertEqual(eventView.accessibilityIdentifier, "map-event-\(eventID)")
        XCTAssertEqual(cardView.accessibilityIdentifier, "map-shared-\(cardID)")
        coordinator.mapView(map, didSelect: eventView); coordinator.mapView(map, didSelect: cardView)
        XCTAssertEqual(selectedEvent?.id, eventID); XCTAssertEqual(selectedCard?.id, cardID)
        XCTAssertEqual(map.region.center.latitude, event.location.latitude, accuracy: 0.01)
        coordinator.parent = WorldMap(trips: [], focus: card.location, focusRevision: 2, select: { _ in })
        coordinator.synchronize(map)
        XCTAssertTrue(map.annotations.compactMap { $0 as? EventMapAnnotation }.isEmpty)
        XCTAssertTrue(map.annotations.compactMap { $0 as? SharedCardAnnotation }.isEmpty)
        XCTAssertEqual(map.region.center.latitude, card.location!.latitude, accuracy: 0.01)
    }

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
