import SwiftUI

struct NewCardView: View {
    @Environment(\.explorerNavigation) private var navigation
    let store: TripStore
    let discoveryID: UUID
    var close: (() -> Void)? = nil
    @State private var error: String?
    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }

    var body: some View {
        CardDetailView(store: store, discoveryID: discoveryID, isNew: true)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Text("Your discovery is ready for its next adventure.").font(.caption).foregroundStyle(Theme.muted)
                    if discovery?.isVerified == true {
                        Button("Share on map") { navigation?.open(.mapShare(discoveryID)) }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("new-card-map")
                    }
                    Button("Make a memory") {
                        guard let discovery else { return }
                        do { try store.finishTrip(discovery.tripID); navigation?.open(.memory(discovery.tripID)) }
                        catch { self.error = error.localizedDescription }
                    }.buttonStyle(ExplorerButtonStyle(secondary: true)).accessibilityIdentifier("new-card-memory")
                    if let error { Text(error).font(.caption) }
                }.padding(20).background(Theme.paper)
            }
            .toolbar {
                if let close { ToolbarItem(placement: .topBarTrailing) { Button("Done", action: close).accessibilityIdentifier("exploration-close") } }
            }
    }
}
