import MapKit
import SwiftUI
import ImageIO

struct WorldMap: UIViewRepresentable {
    let trips: [Trip]
    var select: (Trip) -> Void
    var store: TripStore?

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.mapType = .hybrid
        map.pointOfInterestFilter = .excludingAll
        map.showsCompass = true
        map.showsScale = true
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
        init(parent: WorldMap) {
            self.parent = parent
            markerImages.totalCostLimit = 2 * 1024 * 1024
            markerImages.countLimit = 128
        }

        func synchronize(_ map: MKMapView) {
            let located = parent.trips.filter { $0.place != nil }
            let existing = map.annotations.compactMap { $0 as? TripAnnotation }
            let changed = existing.count != located.count || located.contains { trip in
                !existing.contains { $0.trip.id == trip.id && $0.trip.place == trip.place }
            }
            if changed {
                map.removeAnnotations(existing)
                let annotations = located.map(TripAnnotation.init)
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
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? TripAnnotation else { return nil }
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "discovery") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "discovery")
            view.annotation = annotation
            configure(view, annotation: annotation)
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
            guard let annotation = view.annotation as? TripAnnotation else { return }
            parent.select(annotation.trip)
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

final class TripAnnotation: NSObject, MKAnnotation {
    var trip: Trip
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: trip.place?.latitude ?? 0, longitude: trip.place?.longitude ?? 0)
    }
    init(trip: Trip) { self.trip = trip }
}
