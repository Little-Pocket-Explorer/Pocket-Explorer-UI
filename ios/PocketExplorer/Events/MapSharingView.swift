import SwiftUI

struct MapSharingView: View {
    let store: TripStore
    let discovery: Discovery
    @State private var publication: MapPublication?
    @State private var busy = false
    @State private var error: String?
    @State private var familySettings = false
    @State private var location = DiscoveryLocation()
    @State private var audience = MapAudience.publicApproximate
    @Environment(\.explorerNavigation) private var navigation
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        FeatureNavigation {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LeafBadge(symbol: "map.fill")
                    Text("Share a discovery on the map").font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Choose who can see this card. Your name, photo and exact location stay private.").foregroundStyle(Theme.muted)
                    if store.family.family != nil && store.family.allows(.mapSharing) {
                        audiencePicker
                        if audience.needsLocation, let place = discovery.place ?? location.place {
                            Label(place.name, systemImage: "location.fill").font(.headline).foregroundStyle(Theme.forest)
                        } else if audience.needsLocation {
                            Button("Use approximate location") { location.request() }.buttonStyle(ExplorerButtonStyle(secondary: true))
                                .disabled(location.isLoading).accessibilityIdentifier("map-share-location")
                            if location.isLoading { ProgressView("Finding your place…") }
                            if let error = location.error { Text(error).foregroundStyle(Theme.muted) }
                        }
                        Button("Share on map") { publish() }.buttonStyle(ExplorerButtonStyle())
                            .disabled(busy || !discovery.isVerified || audience.needsLocation && discovery.place == nil && location.place == nil)
                            .accessibilityIdentifier("publish-map-card")
                    } else {
                        Text("A grown-up can allow map sharing in family settings.")
                        Button("Family settings") { familySettings = true }.frame(minHeight: 44)
                    }
                    if let publication, publication.revoked == 0 {
                        Label("Shared on the map", systemImage: "checkmark.circle.fill").foregroundStyle(Theme.forest).accessibilityIdentifier("map-published")
                        Button("Explore nearby") { navigation?.open(.nearby, in: .map) }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("map-continue-nearby")
                        Button("Stop map sharing", role: .destructive, action: revoke).frame(minHeight: 44).disabled(busy).accessibilityIdentifier("revoke-map-card")
                    }
                    if busy { ProgressView() }
                    if let error { Text(error).font(.callout).foregroundStyle(Theme.muted).accessibilityIdentifier("map-sharing-error") }
                }.padding(24)
            }.background(ExplorerBackdrop()).toolbar { Button("Done") { if let navigation { navigation.back() } else { dismiss() } } }
                .sheet(isPresented: $familySettings) { FamilySettingsView(family: store.family) }
                .task { await refresh() }
        }.tint(Theme.forest)
    }
    private var audiencePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Who can see this?").font(.headline)
            ForEach(MapAudience.allCases, id: \.self) { option in
                Button {
                    audience = option
                    if !option.needsLocation { location.remove() }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: audience == option ? "largecircle.fill.circle" : "circle")
                            .font(.title3).foregroundStyle(Theme.forest)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title).font(.headline)
                            Text(option.detail).font(.caption).foregroundStyle(Theme.muted)
                        }
                        Spacer(minLength: 0)
                    }.padding(.vertical, 9).contentShape(Rectangle())
                }.buttonStyle(.plain).disabled(option.needsFriends && !store.family.allows(.social))
                    .accessibilityIdentifier("map-audience-\(option.rawValue)")
            }
            if !store.family.allows(.social) {
                Text("A grown-up can turn on friends in Family settings.").font(.caption).foregroundStyle(Theme.muted)
            }
        }
    }
    private func refresh() async {
        do { publication = try await EventClient().mine(connection: ConnectionVault().loadOrCreate()).first { $0.collectibleID == discovery.collectionID } }
        catch { self.error = error.localizedDescription }
    }
    private func publish() {
        let place = discovery.place ?? location.place
        let coordinate = audience.needsLocation ? place.map { ExplorerCoordinate(latitude: $0.latitude, longitude: $0.longitude) } : nil
        busy = true; error = nil
        Task {
            defer { busy = false }
            do {
                _ = try await EventClient().publish(discovery.collectionID, audience: audience, location: coordinate, connection: ConnectionVault().loadOrCreate())
                await refresh()
            } catch { self.error = error.localizedDescription }
        }
    }
    private func revoke() {
        guard let publication else { return }
        busy = true; error = nil
        Task {
            defer { busy = false }
            do { try await EventClient().revoke(publication.id, connection: ConnectionVault().loadOrCreate()); await refresh() }
            catch { self.error = error.localizedDescription }
        }
    }
}

private extension MapAudience {
    var title: String {
        switch self {
        case .friendsOnly: L10n.text("Friends only")
        case .friendsApproximate: L10n.text("Friends with location")
        case .public: L10n.text("Public")
        case .publicApproximate: L10n.text("Public with approximate location")
        }
    }
    var detail: String {
        switch self {
        case .friendsOnly: L10n.text("Accepted friends · No location")
        case .friendsApproximate: L10n.text("Accepted friends · Approximate location")
        case .public: L10n.text("Everyone · No location")
        case .publicApproximate: L10n.text("Everyone · Approximate location")
        }
    }
}
