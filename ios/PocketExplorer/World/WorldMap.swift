import MapKit
import SwiftUI
import ImageIO

struct WorldMap: UIViewRepresentable {
    let trips: [Trip]
    var events: [ExplorerEvent] = []
    var sharedCards: [SharedMapCard] = []
    var focus: ExplorerCoordinate?
    var focusRevision = 0
    var select: (Trip) -> Void
    var selectEvent: (ExplorerEvent) -> Void = { _ in }
    var selectSharedCard: (SharedMapCard) -> Void = { _ in }
    var store: TripStore?

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.mapType = .hybrid
        map.pointOfInterestFilter = .excludingAll
        map.showsCompass = true
        map.showsScale = true
        map.showsUserLocation = focus != nil
        map.delegate = context.coordinator
        map.accessibilityIdentifier = "discovery-map"
        return map
    }
    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.synchronize(map)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: WorldMap
        private let markerImages = NSCache<NSString, UIImage>()
        private var focusedRevision = -1
        init(parent: WorldMap) {
            self.parent = parent
            markerImages.totalCostLimit = 2 * 1024 * 1024
            markerImages.countLimit = 128
        }

        func synchronize(_ map: MKMapView) {
            let located = parent.trips.filter { $0.place != nil }
            let locatedCards = parent.sharedCards.filter { $0.location != nil }
            let existingTrips = map.annotations.compactMap { $0 as? TripAnnotation }
            let existingEvents = map.annotations.compactMap { $0 as? EventMapAnnotation }
            let existingCards = map.annotations.compactMap { $0 as? SharedCardAnnotation }
            let changed = existingTrips.count != located.count || existingEvents.count != parent.events.count || existingCards.count != locatedCards.count || located.contains { trip in
                !existingTrips.contains { $0.trip.id == trip.id && $0.trip.place == trip.place }
            } || parent.events.contains { event in
                !existingEvents.contains { $0.event.id == event.id && $0.event.location == event.location }
            } || locatedCards.contains { card in
                !existingCards.contains { $0.card.id == card.id && $0.card.location == card.location }
            }
            if changed {
                map.removeAnnotations(existingTrips + existingEvents + existingCards)
                let annotations: [MKAnnotation] = located.map(TripAnnotation.init) + parent.events.map(EventMapAnnotation.init) + locatedCards.map(SharedCardAnnotation.init)
                map.addAnnotations(annotations)
                if !annotations.isEmpty {
                    let rect = annotations.reduce(MKMapRect.null) { current, annotation in
                        let point = MKMapPoint(annotation.coordinate)
                        return current.union(MKMapRect(x: point.x - 1500, y: point.y - 1500, width: 3000, height: 3000))
                    }
                    map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 90, left: 40, bottom: 30, right: 40), animated: false)
                }
            }
            for annotation in map.annotations.compactMap({ $0 as? TripAnnotation }) {
                if let trip = located.first(where: { $0.id == annotation.trip.id }) { annotation.trip = trip }
                if let view = map.view(for: annotation) { configure(view, annotation: annotation) }
            }
            map.showsUserLocation = parent.focus != nil
            if focusedRevision != parent.focusRevision, let focus = parent.focus {
                focusedRevision = parent.focusRevision
                map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: focus.latitude, longitude: focus.longitude), latitudinalMeters: 5500, longitudinalMeters: 5500), animated: true)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? TripAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "discovery") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "discovery")
                view.annotation = annotation
                configure(view, annotation: annotation)
                return view
            }
            if let annotation = annotation as? EventMapAnnotation {
                return pin(annotation: annotation, identifier: "event", symbol: "calendar", color: .systemOrange, label: annotation.event.title)
            }
            if let annotation = annotation as? SharedCardAnnotation {
                return pin(annotation: annotation, identifier: "shared", symbol: "rectangle.stack.fill", color: .systemMint, label: annotation.card.title)
            }
            return nil
        }
        private func pin(annotation: MKAnnotation, identifier: String, symbol: String, color: UIColor, label: String) -> MKMarkerAnnotationView {
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.glyphImage = UIImage(systemName: symbol); view.markerTintColor = color; view.displayPriority = .required
            view.isAccessibilityElement = true; view.accessibilityTraits = .button; view.accessibilityLabel = label
            if let event = annotation as? EventMapAnnotation { view.accessibilityIdentifier = "map-event-\(event.event.id)" }
            if let card = annotation as? SharedCardAnnotation { view.accessibilityIdentifier = "map-shared-\(card.card.id)" }
            return view
        }
        func configure(_ view: MKAnnotationView, annotation: TripAnnotation) {
            let discovery = parent.store?.discoveries(in: annotation.trip.id).first
            let url = discovery?.artworkFilename.flatMap { parent.store?.mediaURL($0) }
            view.image = markerImage(url: url, subject: discovery?.subject.rawValue ?? "leaf", scale: max(1, view.traitCollection.displayScale))
            view.layer.shadowOpacity = 0.22; view.layer.shadowRadius = 5; view.layer.shadowOffset = CGSize(width: 0, height: 3)
            view.displayPriority = .required
            view.collisionMode = .circle
            view.isAccessibilityElement = true
            view.accessibilityTraits = .button
            view.accessibilityIdentifier = "map-trip-\(annotation.trip.id)"
            view.accessibilityLabel = annotation.trip.title + ", " + (annotation.trip.place?.name ?? "")
        }

        private func markerImage(url: URL?, subject: String, scale: CGFloat) -> UIImage {
            let attributes = url.flatMap { try? FileManager.default.attributesOfItem(atPath: $0.path) }
            let modified = (attributes?[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
            let sourceKey: String
            if let url, let attributes {
                sourceKey = "\(url.absoluteString)|\(modified)|\(attributes[.size] ?? 0)|\(attributes[.systemFileNumber] ?? 0)"
            } else { sourceKey = "asset:\(subject)" }
            let key = "\(sourceKey)|\(subject)|\(scale)" as NSString
            if let cached = markerImages.object(forKey: key) { return cached }
            var image: UIImage?
            if let url, attributes != nil, let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
               let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: Int(54 * scale)
               ] as CFDictionary) { image = UIImage(cgImage: thumbnail) }
            let artwork = image ?? UIImage(named: subject) ?? UIImage(named: "leaf")
            let format = UIGraphicsImageRendererFormat(); format.scale = scale
            let marker = UIGraphicsImageRenderer(size: CGSize(width: 54, height: 54), format: format).image { context in
                UIColor.white.setFill(); context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 54, height: 54))
                context.cgContext.addEllipse(in: CGRect(x: 4, y: 4, width: 46, height: 46)); context.cgContext.clip()
                artwork?.draw(in: CGRect(x: 4, y: 4, width: 46, height: 46))
            }
            markerImages.setObject(marker, forKey: key, cost: marker.cgImage.map { $0.bytesPerRow * $0.height } ?? 0)
            return marker
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? TripAnnotation { parent.select(annotation.trip) }
            if let annotation = view.annotation as? EventMapAnnotation { parent.selectEvent(annotation.event) }
            if let annotation = view.annotation as? SharedCardAnnotation { parent.selectSharedCard(annotation.card) }
            if let annotation = view.annotation { mapView.deselectAnnotation(annotation, animated: false) }
        }
    }
}

final class EventMapAnnotation: NSObject, MKAnnotation {
    let event: ExplorerEvent
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude) }
    init(event: ExplorerEvent) { self.event = event }
}

final class SharedCardAnnotation: NSObject, MKAnnotation {
    let card: SharedMapCard
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: card.location?.latitude ?? 0, longitude: card.location?.longitude ?? 0) }
    init(card: SharedMapCard) { self.card = card }
}

final class TripAnnotation: NSObject, MKAnnotation {
    var trip: Trip
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: trip.place?.latitude ?? 0, longitude: trip.place?.longitude ?? 0)
    }
    init(trip: Trip) { self.trip = trip }
}
