import MapKit
import SwiftUI

struct WorldView: View {
    let store: TripStore
    var explore: () -> Void
    var changeLanguage: () -> Void
    @State private var selectedTripID: UUID?
    @State private var expanded = false
    @State private var showReminders = false

    var body: some View {
        WorldMap(trips: store.state.trips, select: { selectedTripID = $0.id }, store: store)
            .overlay(alignment: .top) {
                HStack(alignment: .top) {
                    NavigationLink { CollectionView(store: store, explore: explore) } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "rectangle.stack.fill").font(.title2)
                            Text("\(store.state.discoveries.count)").font(.caption.bold())
                        }.frame(width: 56, height: 62).background(.white, in: RoundedRectangle(cornerRadius: 22))
                    }.accessibilityLabel("Open collection").accessibilityIdentifier("open-collection")
                    Spacer()
                    Text("My discovery map").font(.system(.subheadline, design: .rounded, weight: .bold))
                        .padding(14).background(.white, in: Capsule())
                    Spacer()
                    Button { showReminders = true } label: {
                        Image(systemName: "leaf.arrow.triangle.circlepath").font(.title2).frame(width: 52, height: 52).background(.white, in: Circle())
                    }.accessibilityLabel("Discovery reminders").accessibilityIdentifier("open-reminders")
                }.padding(16).shadow(color: .black.opacity(0.13), radius: 8, y: 3)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Capsule().fill(Theme.muted.opacity(0.3)).frame(width: 36, height: 4).frame(maxWidth: .infinity)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Places with a story").font(.system(.title3, design: .rounded, weight: .heavy))
                            Text("\(store.state.trips.count) little adventures").font(.caption).foregroundStyle(Theme.muted)
                        }
                        Spacer()
                        Button(L10n.text(expanded ? "Show less" : "See all")) { expanded.toggle() }.frame(minHeight: 44).accessibilityIdentifier("expand-trips")
                    }
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(store.state.trips) { trip in
                                NavigationLink { TripDetailView(store: store, tripID: trip.id) } label: {
                                    TripRow(trip: trip, discoveries: store.discoveries(in: trip.id), store: store)
                                }.buttonStyle(.plain).accessibilityIdentifier("trip-\(trip.id)")
                            }
                            if store.state.trips.isEmpty { Text("Your discoveries will appear here, even without a location.").padding().foregroundStyle(Theme.muted) }
                        }
                    }.frame(maxHeight: expanded ? 370 : 105)
                    Button(action: explore) { Label("Find another wonder", systemImage: "mic.fill") }.buttonStyle(ExplorerButtonStyle())
                }.padding(18).background(.regularMaterial, in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
            }
            .foregroundStyle(Theme.ink).toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedTripID) { id in TripDetailView(store: store, tripID: id) }
            .sheet(isPresented: $showReminders) { NavigationStack { DiscoveryRemindersView(store: store) } }
    }
}

struct TripRow: View {
    let trip: Trip
    let discoveries: [Discovery]
    var store: TripStore?
    var body: some View {
        HStack(spacing: 12) {
            if let discovery = discoveries.first {
                DiscoveryArtwork(discovery: discovery, store: store).frame(width: 64, height: 64).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(trip.title).font(.system(.subheadline, design: .rounded, weight: .bold))
                Text("\(discoveries.count) discoveries · \(trip.place?.name ?? L10n.text("No location saved"))").font(.caption).foregroundStyle(Theme.muted)
                if trip.isExample { Text("SAMPLE ADVENTURE").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(1).foregroundStyle(Theme.muted) }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption.bold())
        }.padding(10).background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 20))
    }
}
