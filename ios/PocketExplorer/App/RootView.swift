import SwiftUI

struct RootView: View {
    let store: TripStore
    var changeLanguage: () -> Void
    @State private var tab = 0
    @State private var exploring = false

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { WorldView(store: store, explore: { exploring = true }, changeLanguage: changeLanguage) }
                .tabItem { Label("My world", systemImage: "globe.europe.africa.fill") }.tag(0)
            NavigationStack { CollectionView(store: store, explore: { exploring = true }) }
                .tabItem { Label("My finds", systemImage: "rectangle.stack.fill") }.tag(1)
            NavigationStack { MemoriesView(store: store) }
                .tabItem { Label("Memories", systemImage: "sparkles.tv.fill") }.tag(2)
        }
        .tint(Theme.forest)
        .sheet(isPresented: $exploring) { ExplorationFlow(store: store, tripID: nil) }
    }
}

struct ExplorationFlow: View {
    let store: TripStore
    let tripID: UUID?
    @Environment(\.dismiss) private var dismiss
    @State private var saved: Discovery?
    @State private var revealed = false
    @State private var showMemory = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if let saved {
                    if revealed {
                        CardDetailView(store: store, discoveryID: saved.id, isNew: true)
                            .safeAreaInset(edge: .bottom) {
                                VStack(spacing: 8) {
                                    Text("Saved to My finds. Turn it into a memory next.").font(.caption).foregroundStyle(Theme.muted)
                                    Button("Make a memory") {
                                        do { try store.finishTrip(saved.tripID); showMemory = true }
                                        catch { self.error = error.localizedDescription }
                                    }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("new-card-memory")
                                    if let error { Text(error).font(.caption) }
                                }.padding(20).background(Theme.paper)
                            }
                    } else {
                        CardUnlockView(discovery: saved) { revealed = true }
                    }
                }
                else { ExploreView(store: store, tripID: tripID, onSave: { saved = $0 }) }
            }
            .navigationDestination(isPresented: $showMemory) {
                if let saved, let trip = store.state.trips.first(where: { $0.id == saved.tripID }) {
                    MemoryPlayer(trip: trip)
                        .safeAreaInset(edge: .bottom) {
                            NavigationLink {
                                SharePreviewView(trip: trip, discoveries: store.discoveries(in: trip.id))
                            } label: { Label("Preview & share", systemImage: "square.and.arrow.up") }
                            .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("memory-share-preview")
                            .padding(20).background(Theme.paper)
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.text(saved == nil ? "Close" : "Done")) { dismiss() }.frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .tint(Theme.forest)
    }
}
