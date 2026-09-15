import MapKit
import SwiftUI

struct ChatHomeView: View {
    var explore: (String) -> Void
    var changeLanguage: () -> Void
    @State private var question = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: changeLanguage) { Image(systemName: "rectangle.split.3x1") }
                        .frame(width: 44, height: 44).background(Theme.paper.opacity(0.92), in: Circle())
                        .accessibilityLabel("Language").accessibilityIdentifier("choose-language")
                    Spacer()
                    BrandHeader()
                    Spacer()
                    Image("duck").resizable().scaledToFill().frame(width: 44, height: 44).clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2)).accessibilityHidden(true)
                }
                .padding(.horizontal, 20).padding(.top, 12)
                .background(LinearGradient(colors: [Theme.ocean.opacity(0.65), Theme.paper], startPoint: .top, endPoint: .bottom))
                Image("duck").resizable().scaledToFit().frame(maxWidth: 310, maxHeight: 220).padding(.top, 4)
                    .accessibilityHidden(true)
                VStack(spacing: 11) {
                    Text(L10n.text("What are you curious\nabout today?")).font(.system(.title, design: .rounded, weight: .heavy)).multilineTextAlignment(.center)
                    Text(L10n.text("Ask about anything you notice.")).font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                    VStack(spacing: 10) {
                        suggestion(L10n.text("Why is the sky blue?"), icon: "cloud.sun.fill")
                        suggestion(L10n.text("What kind of leaf is this?"), icon: "leaf.fill")
                        suggestion(L10n.text("How do bees find flowers?"), icon: "sun.max.fill")
                    }.padding(.top, 10)
                }
                .padding(22).background(Theme.paper.opacity(0.94), in: RoundedRectangle(cornerRadius: 30))
            }.padding(.bottom, 16)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                Button(action: { explore(question) }) { Image(systemName: "photo.on.rectangle") }.frame(width: 44, height: 44)
                Button(action: { explore(question) }) { Image(systemName: "camera") }.frame(width: 44, height: 44)
                TextField(L10n.text("Ask anything..."), text: $question).textFieldStyle(.plain).accessibilityIdentifier("home-question")
                Button(action: { explore(question) }) { Image(systemName: "mic.fill") }.frame(width: 44, height: 44)
                    .background(Theme.ocean, in: Circle()).accessibilityIdentifier("start-exploring")
            }
            .padding(9).background(.white, in: Capsule()).shadow(color: Theme.ink.opacity(0.12), radius: 10, y: 4)
            .padding(.horizontal, 20).padding(.vertical, 8).background(Theme.paper)
        }
        .background(Theme.paper).foregroundStyle(Theme.ink).toolbar(.hidden, for: .navigationBar)
    }

    private func suggestion(_ title: String, icon: String) -> some View {
        Button(action: { explore(title) }) {
            HStack(spacing: 13) {
                Image(systemName: icon).foregroundStyle(Theme.forest).frame(width: 29, height: 29).background(Theme.surface, in: Circle())
                Text(title).font(.system(.subheadline, design: .rounded, weight: .semibold)).multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(Theme.muted)
            }.padding(12).frame(maxWidth: .infinity, minHeight: 54).background(.white, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain).accessibilityIdentifier("suggestion-")
    }
}

struct WorldView: View {
    let store: TripStore
    var explore: () -> Void
    var changeLanguage: () -> Void
    @State private var selectedTripID: UUID?
    @State private var expanded = false
    @State private var showReminders = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            WorldMap(trips: store.state.trips, select: { selectedTripID = $0.id }, store: store)
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
        .navigationDestination(item: $selectedTripID) { id in TripDetailView(store: store, tripID: id) }
        .sheet(isPresented: $showReminders) { NavigationStack { DiscoveryRemindersView(store: store) } }
    }

    private var mapControls: some View {
        HStack(alignment: .top) {
            NavigationLink { CollectionView(store: store, explore: explore) } label: {
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
            Button { showReminders = true } label: {
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
            Button(action: explore) { Label("Find another wonder", systemImage: "mic.fill") }.buttonStyle(ExplorerButtonStyle())
        }.padding(18)
    }

    private var tripRows: some View {
        VStack(spacing: 10) {
            ForEach(store.state.trips) { trip in
                NavigationLink { TripDetailView(store: store, tripID: trip.id) } label: {
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
