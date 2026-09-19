import MapKit
import SwiftUI

struct WorldView: View {
    let store: TripStore
    var explore: () -> Void
    var changeLanguage: () -> Void
    @Environment(\.explorerNavigation) private var navigation
    @State private var expanded = false
    @State private var scope = WorldMapScope.me
    @State private var location = DiscoveryLocation()
    @State private var focusRevision = 0

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var readyQuizCount: Int { store.state.discoveries.filter { ReminderPolicy.isEligible($0, now: Date()) }.count }
    private var notificationCount: Int {
        let requests = store.social.friends.filter { $0.state == "incoming" && !$0.blocked }.count
        let transfers = store.social.transfers.values.flatMap { $0 }.filter { !$0.outgoing && $0.state == "pending" }.count
        let events = store.events.events.contains { $0.endsAt > Date.now.timeIntervalSince1970 * 1000 } ? 1 : 0
        return requests + transfers + readyQuizCount + events
    }
    private var shareableDiscoveries: [Discovery] {
        store.state.discoveries.filter { discovery in
            discovery.isUnlocked && discovery.isVerified && discovery.collectible?.versions.allSatisfy { $0.audience == "public" } == true
        }
    }
    private var visibleTrips: [Trip] { scope == .me ? store.state.trips : [] }
    private var visibleEvents: [ExplorerEvent] { scope == .nearby ? store.events.events : [] }
    private var visibleSharedCards: [SharedMapCard] {
        switch scope {
        case .me: []
        case .nearby: store.events.nearbyShared
        case .friends: store.events.friendShared
        }
    }

    var body: some View {
        GeometryReader { geometry in
            WorldMap(trips: visibleTrips, events: visibleEvents, sharedCards: visibleSharedCards,
                focus: location.reading?.coordinate, focusRevision: focusRevision,
                select: { navigation?.open(.trip($0.id)) },
                selectEvent: { navigation?.open(.event($0.id)) },
                selectSharedCard: { navigation?.open(.sharedDiscovery($0.id)) }, store: store)
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
        .task(id: scope) { await refreshScope() }
        .task(id: location.reading?.observedAt) {
            guard let reading = location.reading else { return }
            focusRevision += 1
            await refreshScope(at: reading.coordinate)
        }
    }

    private var mapControls: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 10) {
                NavigationLink(value: ExplorerRoute.collection) {
                    VStack(spacing: 3) {
                        Image(systemName: "rectangle.stack.fill").font(.system(size: 22))
                        if !dynamicTypeSize.isAccessibilitySize { Text("\(store.state.discoveries.count)").font(.caption.bold()) }
                    }.frame(width: 56, height: 62).background(.white, in: RoundedRectangle(cornerRadius: 22))
                }.accessibilityLabel("Open collection").accessibilityIdentifier("open-collection")
                Menu {
                    if shareableDiscoveries.isEmpty {
                        Button("Make a verified card first") {}.disabled(true)
                    } else {
                        ForEach(shareableDiscoveries) { discovery in
                            Button(discovery.title) { navigation?.open(.mapShare(discovery.id)) }
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 21)).frame(width: 52, height: 52).background(.white, in: Circle())
                }.accessibilityLabel("Share a card on the map").accessibilityIdentifier("map-share-menu")
            }
            if !dynamicTypeSize.isAccessibilitySize {
                Picker("Map discoveries", selection: $scope) {
                    ForEach(WorldMapScope.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.segmented).frame(maxWidth: 230).padding(.top, 8).accessibilityIdentifier("map-scope")
            } else { Spacer(minLength: 0) }
            VStack(spacing: 10) {
                Button { location.request() } label: {
                    Image(systemName: location.isLoading ? "location.circle" : "location.fill").font(.system(size: 22)).frame(width: 52, height: 52).background(.white, in: Circle())
                }.disabled(location.isLoading).accessibilityLabel("Find my location").accessibilityIdentifier("map-location")
                Button { navigation?.open(.notifications) } label: {
                    Image(systemName: "bell.fill").font(.system(size: 22)).frame(width: 52, height: 52).background(.white, in: Circle())
                        .overlay(alignment: .topTrailing) {
                            if notificationCount > 0 {
                                Text(min(notificationCount, 99).formatted()).font(.caption2.bold()).foregroundStyle(Theme.forest)
                                    .frame(minWidth: 22, minHeight: 22).background(Theme.mint, in: Circle()).overlay(Circle().stroke(.white, lineWidth: 2))
                                    .accessibilityIdentifier("map-notification-count")
                            }
                        }
                }.accessibilityLabel("Notifications").accessibilityIdentifier("open-notifications")
            }
        }.padding(16).shadow(color: .black.opacity(0.13), radius: 8, y: 3)
    }

    private var tripPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Capsule().fill(Theme.muted.opacity(0.3)).frame(width: 36, height: 4).frame(maxWidth: .infinity)
            if dynamicTypeSize.isAccessibilitySize {
                Picker("Map discoveries", selection: $scope) {
                    ForEach(WorldMapScope.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.menu).accessibilityIdentifier("map-scope")
            }
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(scope.panelTitle).font(.system(.title3, design: .rounded, weight: .heavy))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(scopeSummary).font(.caption).foregroundStyle(Theme.muted)
                }
                if scope == .me && !dynamicTypeSize.isAccessibilitySize {
                    Spacer()
                    Button(L10n.text(expanded ? "Show less" : "See all")) { expanded.toggle() }.frame(minHeight: 44).accessibilityIdentifier("expand-trips")
                }
            }
            if dynamicTypeSize.isAccessibilitySize { scopeRows }
            else { ScrollView { scopeRows }.frame(maxHeight: scope == .me && expanded ? 370 : 150) }
            if scope == .me {
                Button { navigation?.open(.nearby) } label: { Label("Nearby events & discoveries", systemImage: "map") }.frame(minHeight: 44).accessibilityIdentifier("open-nearby")
            } else if scope == .nearby {
                Button { location.request() } label: { Label("Refresh nearby", systemImage: "location.fill") }.frame(minHeight: 44).disabled(location.isLoading).accessibilityIdentifier("refresh-nearby")
            }
            if let error = location.error ?? store.events.error { Text(error).font(.caption).foregroundStyle(Theme.muted).accessibilityIdentifier("map-error") }
            Button(action: explore) { Label("Find another wonder", systemImage: "mic.fill") }.buttonStyle(ExplorerButtonStyle())
        }.padding(18)
    }

    @ViewBuilder private var scopeRows: some View {
        VStack(spacing: 10) {
            if scope == .me {
                ForEach(store.state.trips) { trip in
                    NavigationLink(value: ExplorerRoute.trip(trip.id)) {
                        TripRow(trip: trip, discoveries: store.discoveries(in: trip.id), store: store)
                    }.buttonStyle(.plain).accessibilityIdentifier("trip-\(trip.id)")
                }
                if store.state.trips.isEmpty { Text("Your discoveries will appear here, even without a location.").padding().foregroundStyle(Theme.muted) }
            } else if scope == .nearby {
                ForEach(store.events.events) { event in
                    Button { navigation?.open(.event(event.id)) } label: { MapEventRow(event: event) }.buttonStyle(.plain).accessibilityIdentifier("map-nearby-event-\(event.id)")
                }
                ForEach(store.events.nearbyShared) { card in
                    Button { navigation?.open(.sharedDiscovery(card.id)) } label: { MapSharedCardRow(card: card) }.buttonStyle(.plain).accessibilityIdentifier("map-nearby-card-\(card.id)")
                }
                if store.events.events.isEmpty && store.events.nearbyShared.isEmpty {
                    Text(store.family.allows(.events) ? "Use the location button to find nearby events and discoveries." : "A grown-up can allow nearby events in Family settings.").padding().foregroundStyle(Theme.muted)
                }
            } else {
                ForEach(store.events.friendShared) { card in
                    Button { navigation?.open(.sharedDiscovery(card.id)) } label: { MapSharedCardRow(card: card) }.buttonStyle(.plain).accessibilityIdentifier("map-friend-card-\(card.id)")
                }
                if store.events.friendShared.isEmpty {
                    Text(store.family.allows(.social) ? "Discoveries shared by accepted friends will appear here." : "A grown-up can turn on friends in Family settings.").padding().foregroundStyle(Theme.muted)
                }
            }
        }
    }

    private var scopeSummary: String {
        switch scope {
        case .me: String(format: L10n.text("%d little adventures"), store.state.trips.count)
        case .nearby: String(format: L10n.text("%d nearby"), store.events.events.count + store.events.nearbyShared.count)
        case .friends: String(format: L10n.text("%d from friends"), store.events.friendShared.count)
        }
    }

    private func refreshScope(at coordinate: ExplorerCoordinate? = nil) async {
        guard let connection = try? ConnectionVault().loadOrCreate() else { return }
        switch scope {
        case .me: return
        case .nearby:
            guard store.family.allows(.events) else { return }
            if let coordinate = coordinate ?? location.reading?.coordinate { await store.events.refresh(at: coordinate, connection: connection) }
        case .friends:
            guard store.family.allows(.social) else { return }
            await store.events.refreshFriends(connection: connection)
        }
    }
}

private enum WorldMapScope: String, CaseIterable, Identifiable {
    case me, nearby, friends
    var id: Self { self }
    var title: String { L10n.text(rawValue.capitalized) }
    var panelTitle: String {
        switch self {
        case .me: L10n.text("Places with a story")
        case .nearby: L10n.text("Nearby events & discoveries")
        case .friends: L10n.text("Friends' discoveries")
        }
    }
}

private struct MapEventRow: View {
    let event: ExplorerEvent
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar").font(.title2).foregroundStyle(Theme.forest).frame(width: 54, height: 54).background(Theme.sun.opacity(0.35), in: RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) { Text(event.title).font(.headline); Text(event.place).font(.caption).foregroundStyle(Theme.muted) }
            Spacer(); Image(systemName: "chevron.right").font(.caption.bold())
        }.padding(10).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct MapSharedCardRow: View {
    let card: SharedMapCard
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.stack.fill").font(.title2).foregroundStyle(Theme.forest).frame(width: 54, height: 54).background(Theme.mint.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) { Text(card.title).font(.headline); Text(card.location == nil ? "No location shared" : "Approximate location").font(.caption).foregroundStyle(Theme.muted) }
            Spacer(); Image(systemName: "chevron.right").font(.caption.bold())
        }.padding(10).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
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
