import CoreLocation
import Observation

@MainActor @Observable
final class DiscoveryLocation: NSObject, @preconcurrency CLLocationManagerDelegate {
    private(set) var place: Place?
    private(set) var isLoading = false
    private(set) var error: String?
    private let manager: CLLocationManager
    private let timeoutDuration: Duration
    private var requestID: UUID?
    private var timeout: Task<Void, Never>?
    private let geocode: (CLLocation) async throws -> String?

    init(manager: CLLocationManager? = nil, timeoutDuration: Duration = .seconds(20), geocode: @escaping (CLLocation) async throws -> String? = { location in
        let result = try await CLGeocoder().reverseGeocodeLocation(location)
        return result.first?.locality ?? result.first?.administrativeArea
    }) {
        self.geocode = geocode
        self.manager = manager ?? CLLocationManager()
        self.timeoutDuration = timeoutDuration
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        guard !isLoading else { return }
        error = nil; isLoading = true; requestID = UUID()
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        default: fail()
        }
        guard isLoading else { return }
        timeout = Task { @MainActor in
            do { try await Task.sleep(for: timeoutDuration); if isLoading { fail() } } catch {}
        }
    }

    func remove() { place = nil; requestID = nil; isLoading = false; timeout?.cancel(); error = nil }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isLoading else { return }
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways { manager.requestLocation() }
        else if manager.authorizationStatus != .notDetermined { fail() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let id = requestID, let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        Task { @MainActor in
            let name = (try? await geocode(location)) ?? L10n.text("My discovery")
            guard requestID == id else { return }
            place = Place(name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            isLoading = false; requestID = nil; timeout?.cancel()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { if isLoading { fail() } }

    private func fail() {
        error = L10n.text("Your location is unavailable. You can still keep your discovery without it.")
        isLoading = false; requestID = nil; timeout?.cancel()
    }
}
