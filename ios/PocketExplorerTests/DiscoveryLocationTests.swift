import CoreLocation
import XCTest
@testable import PocketExplorer

@MainActor
final class DiscoveryLocationTests: XCTestCase {
    func testPermissionRequestStartsOnlyFromExplicitActionAndDenialRecovers() {
        let manager = TestLocationManager()
        let location = DiscoveryLocation(manager: manager)
        XCTAssertEqual(manager.requests, 0)
        location.locationManagerDidChangeAuthorization(manager)
        XCTAssertEqual(manager.requests, 0)
        location.request(); location.request()
        XCTAssertEqual(manager.permissions, 1)
        manager.status = .denied
        location.locationManagerDidChangeAuthorization(manager)
        XCTAssertFalse(location.isLoading)
        XCTAssertNotNil(location.error)
        location.remove()
        XCTAssertNil(location.error)
        location.request()
        XCTAssertFalse(location.isLoading)
        XCTAssertNotNil(location.error)
    }

    func testAuthorizedLocationUsesBroadNameAndKeepsCoordinatesLocal() async throws {
        let manager = TestLocationManager()
        manager.status = .authorizedWhenInUse
        let location = DiscoveryLocation(manager: manager, geocode: { _ in "Sydney" })
        location.request()
        XCTAssertEqual(manager.requests, 1)
        location.locationManager(manager, didUpdateLocations: [CLLocation(latitude: -33.87, longitude: 151.21)])
        try await settle { location.place?.name == "Sydney" }
        XCTAssertEqual(location.place?.name, "Sydney")
        XCTAssertEqual(location.place?.latitude, -33.87)
        XCTAssertFalse(location.isLoading)
        location.locationManager(manager, didFailWithError: CLError(.locationUnknown))
        XCTAssertNil(location.error, "A late callback must not change a completed request.")
        location.remove()
        XCTAssertNil(location.place)
    }

    func testGrantThenFailureAndTimeoutNeverRequireALocationToContinue() async throws {
        let manager = TestLocationManager()
        let location = DiscoveryLocation(manager: manager, timeoutDuration: .milliseconds(10))
        location.request()
        manager.status = .authorizedAlways
        location.locationManagerDidChangeAuthorization(manager)
        XCTAssertEqual(manager.requests, 1)
        location.locationManager(manager, didUpdateLocations: [])
        location.locationManager(manager, didFailWithError: CLError(.locationUnknown))
        XCTAssertFalse(location.isLoading)
        XCTAssertNil(location.place)
        location.remove(); location.request()
        try await settle { !location.isLoading }
        XCTAssertNotNil(location.error)
    }

    func testGeocodingFailureUsesNeutralNameAndRemovalRejectsLateResult() async throws {
        let manager = TestLocationManager(); manager.status = .authorizedWhenInUse
        let location = DiscoveryLocation(manager: manager, geocode: { _ in throw CLError(.network) })
        location.request()
        location.locationManager(manager, didUpdateLocations: [CLLocation(latitude: 1, longitude: 2)])
        try await settle { location.place != nil }
        XCTAssertEqual(location.place?.name, L10n.text("My discovery"))
        let delayed = DiscoveryLocation(manager: TestLocationManager(authorized: true), geocode: { _ in
            try await Task.sleep(for: .milliseconds(20)); return "Discarded place"
        })
        delayed.request()
        delayed.locationManager(manager, didUpdateLocations: [CLLocation(latitude: 1, longitude: 2)])
        delayed.remove()
        try await Task.sleep(for: .milliseconds(40))
        XCTAssertNil(delayed.place)
        XCTAssertFalse(delayed.isLoading)
    }

    func testEventCoordinatesDoNotWaitForReverseGeocoding() async throws {
        let manager = TestLocationManager(authorized: true)
        let location = DiscoveryLocation(manager: manager, geocode: { _ in
            try await Task.sleep(for: .milliseconds(100)); return "Sydney"
        })
        location.request()
        location.locationManager(manager, didUpdateLocations: [CLLocation(coordinate: CLLocationCoordinate2D(latitude: -33.87, longitude: 151.21), altitude: 0, horizontalAccuracy: 20, verticalAccuracy: -1, timestamp: .now)])
        XCTAssertNotNil(location.reading)
        XCTAssertFalse(location.isLoading)
        try await settle { location.place?.name == "Sydney" }
    }

    private func settle(_ predicate: () -> Bool) async throws {
        for _ in 0..<50 { if predicate() { return }; try await Task.sleep(for: .milliseconds(10)) }
        XCTAssertTrue(predicate())
    }
}

private final class TestLocationManager: CLLocationManager {
    var status: CLAuthorizationStatus = .notDetermined
    var requests = 0
    var permissions = 0
    init(authorized: Bool = false) { super.init(); if authorized { status = .authorizedWhenInUse } }
    override var authorizationStatus: CLAuthorizationStatus { status }
    override func requestWhenInUseAuthorization() { permissions += 1 }
    override func requestLocation() { requests += 1 }
}
