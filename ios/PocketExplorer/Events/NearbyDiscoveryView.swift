import MapKit
import SwiftUI

struct NearbyDiscoveryView: View {
    let store: TripStore
    @State private var location = DiscoveryLocation()
    @State private var familySettings = false
    @State private var camera: MapCameraPosition = .automatic
    @Environment(\.explorerNavigation) private var navigation
    @Environment(\.dismiss) private var dismiss
    private var permitted: Bool { store.family.family != nil && store.family.allows(.events) }
    var body: some View {
        FeatureNavigation {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("A little adventure nearby").font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Discover events and shared cards within 2 km.").foregroundStyle(Theme.muted)
                    if !permitted {
                        Text("Ask a grown-up to set up your explorer profile and allow events.")
                        Button("Family settings") { familySettings = true }.buttonStyle(ExplorerButtonStyle())
                    } else {
                        Map(position: $camera) {
                            ForEach(store.events.events) { event in
                                Annotation(event.title, coordinate: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)) {
                                    Button { navigation?.open(.event(event.id)) } label: { Image(systemName: "sparkles").font(.title2).padding(12).background(Theme.sun, in: Circle()) }
                                        .accessibilityIdentifier("event-pin-\(event.id)")
                                }
                            }
                            ForEach(store.events.shared) { card in
                                if let cardLocation = card.location {
                                    Annotation(card.title, coordinate: CLLocationCoordinate2D(latitude: cardLocation.latitude, longitude: cardLocation.longitude)) {
                                        Button { navigation?.open(.sharedDiscovery(card.id)) } label: { Image(systemName: "rectangle.stack.fill").padding(12).background(Theme.mint, in: Circle()) }.accessibilityIdentifier("shared-map-pin-\(card.id)")
                                    }
                                }
                            }
                        }.mapStyle(.hybrid).frame(height: 230).clipShape(RoundedRectangle(cornerRadius: 26)).accessibilityIdentifier("nearby-map")
                        Button { location.request() } label: {
                            Label(L10n.text(location.isLoading ? "Finding your place…" : "Find nearby adventures"), systemImage: "location.fill")
                        }.buttonStyle(ExplorerButtonStyle()).disabled(location.isLoading || store.events.busy).accessibilityIdentifier("find-events")
                        if store.events.busy { ProgressView("Finding nearby adventures…") }
                        if let error = location.error ?? store.events.error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("events-error") }
                        ForEach(store.events.events) { event in
                            Button { navigation?.open(.event(event.id)) } label: { EventRow(event: event) }.buttonStyle(.plain).accessibilityIdentifier("nearby-event-\(event.id)")
                        }
                        if location.reading != nil && !store.events.busy && store.events.events.isEmpty {
                            Text("No events nearby right now. Your next discovery can still start anywhere.").foregroundStyle(Theme.muted)
                        }
                        if !store.events.shared.isEmpty {
                            Text("Discoveries shared with you").font(.title2.bold())
                            Text("Map pins show only a broad area. Some friends may share a card without any location.").font(.caption).foregroundStyle(Theme.muted)
                            ForEach(store.events.shared) { card in
                                Button { navigation?.open(.sharedDiscovery(card.id)) } label: {
                                    HStack { LeafBadge(); Text(card.title).font(.headline); Spacer(); Image(systemName: "chevron.right") }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
                                }.buttonStyle(.plain).accessibilityIdentifier("nearby-shared-\(card.id)")
                            }
                        }
                        if store.events.truncated { Text("There are more discoveries in this area. Try a closer location.").font(.caption) }
                    }
                }.padding(22)
            }.background(ExplorerBackdrop()).navigationTitle("Nearby").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Done") { if let navigation { navigation.back() } else { dismiss() } } }
                .sheet(isPresented: $familySettings) { FamilySettingsView(family: store.family) }
                .task(id: location.reading?.observedAt) {
                    guard permitted, let reading = location.reading, let connection = try? ConnectionVault().loadOrCreate() else { return }
                    await store.events.refresh(at: reading.coordinate, includeFriends: store.family.allows(.social), connection: connection)
                    camera = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: reading.coordinate.latitude, longitude: reading.coordinate.longitude), latitudinalMeters: 4500, longitudinalMeters: 4500))
                }
        }.tint(Theme.forest)
    }
}

struct EventRow: View {
    let event: ExplorerEvent
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image("event-\(event.background)").resizable().scaledToFill().frame(height: 135).clipped().clipShape(RoundedRectangle(cornerRadius: 22))
            Text(event.title).font(.title2.bold())
            Label(event.place, systemImage: "mappin.and.ellipse").font(.subheadline)
            if event.demonstration { Text("Demonstration event").font(.caption.bold()).foregroundStyle(Theme.muted) }
        }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(.white, in: RoundedRectangle(cornerRadius: 28))
    }
}

struct SharedMapCardView: View {
    let card: SharedMapCard
    @State private var bytes: Data?
    @State private var error: String?
    @Environment(\.explorerNavigation) private var navigation
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        FeatureNavigation {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if let bytes, let image = UIImage(data: bytes) { Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 26)).accessibilityLabel(card.title) }
                    LeafBadge(symbol: "map.fill")
                    Text(card.title).font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(card.question).font(.title2)
                    Text(card.answer)
                    Text(card.location == nil ? "Shared without a location" : "Shared in this area").font(.caption).foregroundStyle(Theme.muted)
                    if let error { Text(error).font(.caption).foregroundStyle(Theme.muted) }
                }.padding(24)
            }.background(ExplorerBackdrop()).toolbar { Button("Done") { if let navigation { navigation.back() } else { dismiss() } } }
        }.task {
            do { bytes = try await EventClient().mapArtwork(card, connection: ConnectionVault().loadOrCreate()) }
            catch { self.error = error.localizedDescription }
        }
    }
}
