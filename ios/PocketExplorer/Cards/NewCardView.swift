import SwiftUI

struct NewCardView: View {
    let store: TripStore
    let discoveryID: UUID
    var close: (() -> Void)? = nil
    @State private var showMemory = false
    @State private var error: String?
    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }

    var body: some View {
        CardDetailView(store: store, discoveryID: discoveryID, isNew: true)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Text("Saved to My finds. Turn it into a memory next.").font(.caption).foregroundStyle(Theme.muted)
                    Button("Make a memory") {
                        guard let discovery else { return }
                        do { try store.finishTrip(discovery.tripID); showMemory = true }
                        catch { self.error = error.localizedDescription }
                    }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("new-card-memory")
                    if let error { Text(error).font(.caption) }
                }.padding(20).background(Theme.paper)
            }
            .navigationDestination(isPresented: $showMemory) {
                if let discovery, let trip = store.state.trips.first(where: { $0.id == discovery.tripID }) {
                    MemoryPlayer(trip: trip, store: store)
                        .safeAreaInset(edge: .bottom) {
                            NavigationLink {
                                SharePreviewView(trip: trip, discoveries: store.discoveries(in: trip.id), store: store)
                            } label: { Label("Preview & share", systemImage: "square.and.arrow.up") }
                            .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("memory-share-preview")
                            .padding(20).background(Theme.paper)
                        }
                }
            }
            .toolbar {
                if let close { ToolbarItem(placement: .topBarTrailing) { Button("Done", action: close).accessibilityIdentifier("exploration-close") } }
            }
    }
}
