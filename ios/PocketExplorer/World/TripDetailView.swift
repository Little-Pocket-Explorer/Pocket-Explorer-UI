import SwiftUI

struct TripDetailView: View {
    let store: TripStore
    let tripID: UUID
    @State private var exploring = false
    @State private var showMemory = false
    @State private var showShare = false
    @State private var error: String?
    private var trip: Trip? { store.state.trips.first { $0.id == tripID } }

    var body: some View {
        ScrollView {
            if let trip {
                VStack(alignment: .leading, spacing: 24) {
                    Eyebrow(text: trip.place?.name ?? "Somewhere wonderful")
                    Text(trip.title).font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    Text(trip.startedAt.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(Theme.muted)
                    if trip.isExample { Text("A fictional sample adventure to explore the demo.").font(.footnote).foregroundStyle(Theme.muted) }
                    ForEach(store.discoveries(in: tripID)) { discovery in
                        NavigationLink { CardDetailView(store: store, discoveryID: discovery.id) } label: { DiscoveryCard(discovery: discovery, store: store) }.buttonStyle(.plain)
                    }
                    Button("Discover something else") { exploring = true }.buttonStyle(ExplorerButtonStyle(secondary: true))
                    Button(L10n.text(trip.memory == nil ? "Finish adventure & make a memory" : "Play this memory")) {
                        do { try store.finishTrip(tripID); showMemory = true }
                        catch { self.error = error.localizedDescription }
                    }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("make-memory")
                    if trip.memory != nil {
                        Button { showShare = true } label: { Label("Share this little adventure", systemImage: "square.and.arrow.up") }
                            .buttonStyle(ExplorerButtonStyle(secondary: true)).accessibilityIdentifier("share-trip")
                    }
                    if let error { Text(error).foregroundStyle(Theme.ink) }
                }.padding(26)
            }
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
        .navigationTitle("My adventure").navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $exploring) { ExplorationFlow(store: store, tripID: tripID) }
        .sheet(isPresented: $showMemory) {
            if let trip {
                NavigationStack { MemoryPlayer(trip: trip, store: store).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { showMemory = false } } } }
            }
        }
        .sheet(isPresented: $showShare) {
            if let trip { SharePreviewView(trip: trip, discoveries: store.discoveries(in: tripID), store: store) }
        }
    }
}
