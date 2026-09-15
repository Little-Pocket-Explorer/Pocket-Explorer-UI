import SwiftUI

struct MapSharingView: View {
    let store: TripStore
    let discovery: Discovery
    @State private var publication: MapPublication?
    @State private var busy = false
    @State private var error: String?
    @State private var familySettings = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LeafBadge(symbol: "map.fill")
                    Text("Share a discovery on the map").font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Only your card and a broad area are shared. Your name, photo and exact location stay private.").foregroundStyle(Theme.muted)
                    if let place = discovery.place {
                        Text(place.name).font(.headline)
                        if store.family.family != nil && store.family.allows(.mapSharing) {
                            Button("Share on map") { publish(place) }.buttonStyle(ExplorerButtonStyle()).disabled(busy || !discovery.isVerified).accessibilityIdentifier("publish-map-card")
                        } else {
                            Text("A grown-up can allow map sharing in family settings.")
                            Button("Family settings") { familySettings = true }.frame(minHeight: 44)
                        }
                    } else { Text("This discovery has no saved place. You can still share it with a link.") }
                    if let publication, publication.revoked == 0 {
                        Label("Shared on the map", systemImage: "checkmark.circle.fill").foregroundStyle(Theme.forest).accessibilityIdentifier("map-published")
                        Button("Stop map sharing", role: .destructive, action: revoke).frame(minHeight: 44).disabled(busy).accessibilityIdentifier("revoke-map-card")
                    }
                    if busy { ProgressView() }
                    if let error { Text(error).font(.callout).foregroundStyle(Theme.muted).accessibilityIdentifier("map-sharing-error") }
                }.padding(24)
            }.background(ExplorerBackdrop()).toolbar { Button("Done") { dismiss() } }
                .sheet(isPresented: $familySettings) { FamilySettingsView(family: store.family) }
                .task { await refresh() }
        }.tint(Theme.forest)
    }
    private func refresh() async {
        do { publication = try await EventClient().mine(connection: ConnectionVault().loadOrCreate()).first { $0.collectibleID == discovery.collectionID } }
        catch { self.error = error.localizedDescription }
    }
    private func publish(_ place: Place) {
        busy = true; error = nil
        Task {
            defer { busy = false }
            do {
                _ = try await EventClient().publish(discovery.collectionID, location: ExplorerCoordinate(latitude: place.latitude, longitude: place.longitude), connection: ConnectionVault().loadOrCreate())
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
