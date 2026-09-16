import MapKit
import SwiftUI

struct WorldView: View {
    let store: TripStore
    var explore: () -> Void
    var changeLanguage: () -> Void
    @Environment(\.explorerNavigation) private var navigation
    @State private var expanded = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            WorldMap(trips: store.state.trips, select: { navigation?.open(.trip($0.id)) }, store: store)
                .overlay(alignment: .top) { mapControls }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Group {
                        if dynamicTypeSize.isAccessibilitySize {
                            ScrollView { tripPanel }.frame(maxHeight: geometry.size.height * 0.6)
                        } else { tripPanel }
                    }.background(.regularMaterial, in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
                }
        }
        .foregroundStyle(Theme.ink).toolbar(.hidden, for: .navigationBar)
    }

    private var mapControls: some View {
        HStack(alignment: .top) {
            NavigationLink(value: ExplorerRoute.collection) {
                VStack(spacing: 3) {
                    Image(systemName: "rectangle.stack.fill").font(.system(size: 22))
                    if !dynamicTypeSize.isAccessibilitySize { Text("\(store.state.discoveries.count)").font(.caption.bold()) }
                }.frame(width: 56, height: 62).background(.white, in: RoundedRectangle(cornerRadius: 22))
            }.accessibilityLabel("Open collection").accessibilityIdentifier("open-collection")
            Spacer()
            if !dynamicTypeSize.isAccessibilitySize {
                Text("My discovery map").font(.system(.subheadline, design: .rounded, weight: .bold))
                    .padding(14).background(.white, in: Capsule())
                Spacer()
            }
            Button { navigation?.open(.reminders) } label: {
                Image(systemName: "leaf.arrow.triangle.circlepath").font(.system(size: 22)).frame(width: 52, height: 52).background(.white, in: Circle())
            }.accessibilityLabel("Discovery reminders").accessibilityIdentifier("open-reminders")
        }.padding(16).shadow(color: .black.opacity(0.13), radius: 8, y: 3)
    }

    private var tripPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Capsule().fill(Theme.muted.opacity(0.3)).frame(width: 36, height: 4).frame(maxWidth: .infinity)
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Places with a story").font(.system(.title3, design: .rounded, weight: .heavy))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(store.state.trips.count) little adventures").font(.caption).foregroundStyle(Theme.muted)
                }
                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer()
                    Button(L10n.text(expanded ? "Show less" : "See all")) { expanded.toggle() }.frame(minHeight: 44).accessibilityIdentifier("expand-trips")
                }
            }
            if dynamicTypeSize.isAccessibilitySize { tripRows }
            else { ScrollView { tripRows }.frame(maxHeight: expanded ? 370 : 105) }
            Button { navigation?.open(.nearby) } label: { Label("Nearby events & discoveries", systemImage: "map") }.frame(minHeight: 44).accessibilityIdentifier("open-nearby")
            Button(action: explore) { Label("Find another wonder", systemImage: "mic.fill") }.buttonStyle(ExplorerButtonStyle())
        }.padding(18)
    }

    private var tripRows: some View {
        VStack(spacing: 10) {
            ForEach(store.state.trips) { trip in
                NavigationLink(value: ExplorerRoute.trip(trip.id)) {
                    TripRow(trip: trip, discoveries: store.discoveries(in: trip.id), store: store)
                }.buttonStyle(.plain).accessibilityIdentifier("trip-\(trip.id)")
            }
            if store.state.trips.isEmpty { Text("Your discoveries will appear here, even without a location.").padding().foregroundStyle(Theme.muted) }
        }
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
