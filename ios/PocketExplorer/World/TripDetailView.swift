import SwiftUI

struct TripDetailView: View {
    let store: TripStore
    let tripID: UUID
    @Environment(\.explorerNavigation) private var navigation
    @State private var error: String?
    private var trip: Trip? { store.state.trips.first { $0.id == tripID } }

    var body: some View {
        ScrollView {
            if let trip {
                VStack(alignment: .leading, spacing: 24) {
                    Eyebrow(text: trip.place?.name ?? "Somewhere wonderful")
                    Text(trip.title).font(.system(.largeTitle, design: .rounded, weight: .heavy)).accessibilityIdentifier("trip-title")
                    Text(L10n.date(trip.startedAt)).foregroundStyle(Theme.muted)
                    if trip.isExample { Text("A fictional sample adventure to explore the demo.").font(.footnote).foregroundStyle(Theme.muted) }
                    ForEach(store.discoveries(in: tripID)) { discovery in
                        NavigationLink(value: ExplorerRoute.card(discovery.id)) { DiscoveryCard(discovery: discovery, store: store) }.buttonStyle(.plain)
                    }
                    Button("Discover something else") { navigation?.open(.explore(.init(tripID: tripID)), in: .chat) }.buttonStyle(ExplorerButtonStyle(secondary: true))
                    Button(L10n.text(trip.memory == nil ? "Finish adventure & make a memory" : "Play this memory")) {
                        do { try store.finishTrip(tripID); navigation?.open(.memory(tripID)) }
                        catch { self.error = error.localizedDescription }
                    }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("make-memory")
                    if trip.memory != nil {
                        Button { navigation?.open(.share(tripID, nil)) } label: { Label("Share this little adventure", systemImage: "square.and.arrow.up") }
                            .buttonStyle(ExplorerButtonStyle(secondary: true)).accessibilityIdentifier("share-trip")
                    }
                    if let error { Text(error).foregroundStyle(Theme.ink) }
                }.padding(26)
            }
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
        .navigationTitle("My adventure").navigationBarTitleDisplayMode(.inline)
    }
}
