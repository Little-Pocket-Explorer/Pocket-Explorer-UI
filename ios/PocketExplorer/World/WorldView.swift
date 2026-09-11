import MapKit
import SwiftUI

struct WorldView: View {
    let store: TripStore
    var explore: () -> Void
    var changeLanguage: () -> Void
    @State private var selectedTripID: UUID?
    @State private var error: String?
    @State private var memoryTrip: Trip?
    @State private var daysAhead = 0

    private var reminderDate: Date { Date().addingTimeInterval(Double(daysAhead) * 86_400) }
    private var reminder: Trip? { store.state.trips.first { ReminderPolicy.isEligible($0, now: reminderDate) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    BrandHeader()
                    Button(action: changeLanguage) { Image(systemName: "character.bubble") }
                        .frame(width: 44, height: 44).accessibilityLabel("语言 / Language")
                        .accessibilityIdentifier("choose-language")
                }
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: "Your next little wonder")
                        Text("What would you\nlike to discover?").font(.system(.title, design: .rounded, weight: .heavy))
                    }
                    Image("duck").resizable().scaledToFit().frame(width: 105)
                        .clipShape(RoundedRectangle(cornerRadius: 24)).accessibilityHidden(true)
                }
                Button(action: explore) { Label("Start exploring", systemImage: "mic.fill") }
                    .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("start-exploring")
                Text("Ask a question. Notice something. Make your own card.")
                    .font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                WorldMap(trips: store.state.trips, select: { selectedTripID = $0.id })
                    .frame(height: 285).clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(alignment: .topLeading) {
                        Label("Your discovery map", systemImage: "location.circle")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .padding(12).background(Theme.paper.opacity(0.96), in: Capsule()).padding(14)
                    }
                HStack(spacing: 14) {
                    stat("\(store.state.discoveries.count)", "wonders kept")
                    stat("\(store.state.trips.count)", "little adventures")
                }
                if let trip = reminder {
                    VStack(alignment: .leading, spacing: 13) {
                        Eyebrow(text: "Remember this little adventure?")
                        Text(trip.title).font(.system(.title2, design: .rounded, weight: .bold))
                        Text("A little look back at the things you noticed.").font(.subheadline).foregroundStyle(Theme.muted)
                        Button("Open this memory") { memoryTrip = trip }.buttonStyle(ExplorerButtonStyle())
                        Button("Another day") {
                            do { try store.dismissReminder(trip.id, now: reminderDate) }
                            catch { self.error = error.localizedDescription }
                        }.frame(maxWidth: .infinity, minHeight: 44).accessibilityIdentifier("dismiss-reminder")
                    }.padding(22).background(Theme.surface, in: RoundedRectangle(cornerRadius: 26))
                }
                Eyebrow(text: "Places with a story")
                ForEach(store.state.trips) { trip in
                    NavigationLink { TripDetailView(store: store, tripID: trip.id) } label: {
                        TripRow(trip: trip, discoveries: store.discoveries(in: trip.id))
                    }.buttonStyle(.plain).accessibilityIdentifier("trip-\(trip.id)")
                }
                if let error { Text(error).font(.callout) }
                #if DEBUG
                DisclosureGroup("Demo time controls") {
                    Stepper("\(daysAhead) days ahead", value: $daysAhead, in: 0...30).padding(.vertical, 8)
                }.font(.caption).foregroundStyle(Theme.muted)
                #endif
            }.padding(26)
        }
        .background(Theme.paper).foregroundStyle(Theme.ink).toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedTripID) { id in TripDetailView(store: store, tripID: id) }
        .sheet(item: $memoryTrip) { trip in
            NavigationStack { MemoryPlayer(trip: trip).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { memoryTrip = nil } } } }
        }
    }

    private func stat(_ value: String, _ caption: String) -> some View {
        HStack(spacing: 9) {
            Text(value).font(.system(.title2, design: .rounded, weight: .heavy))
            Text(L10n.text(caption)).font(.system(.caption, design: .rounded, weight: .medium)).foregroundStyle(Theme.muted)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(14).background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct WorldMap: View {
    let trips: [Trip]
    var select: (Trip) -> Void
    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -32.5, longitude: 149), span: MKCoordinateSpan(latitudeDelta: 16, longitudeDelta: 17))), interactionModes: []) {
            ForEach(trips) { trip in
                if let place = trip.place {
                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                        Button { select(trip) } label: {
                            Image(systemName: "sparkles").font(.title3.bold())
                                .frame(width: 48, height: 48).background(Theme.paper, in: Circle())
                                .overlay(Circle().stroke(Theme.forest, lineWidth: 3))
                                .foregroundStyle(Theme.forest).shadow(color: Theme.ink.opacity(0.15), radius: 5, y: 3)
                        }.accessibilityLabel("Open \(trip.title) in \(place.name)")
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
        .accessibilityIdentifier("discovery-map")
    }
}

struct TripRow: View {
    let trip: Trip
    let discoveries: [Discovery]
    var body: some View {
        HStack(spacing: 15) {
            Image((discoveries.first?.subject ?? .duck).rawValue).resizable().scaledToFill()
                .frame(width: 70, height: 76).clipShape(RoundedRectangle(cornerRadius: 17))
            VStack(alignment: .leading, spacing: 6) {
                Text(trip.title).font(.system(.headline, design: .rounded))
                Text("\(discoveries.count) discoveries · \(trip.place?.name ?? L10n.text("Somewhere wonderful"))")
                    .font(.caption).foregroundStyle(Theme.muted)
                if trip.isExample { Text("SAMPLE ADVENTURE").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(1).foregroundStyle(Theme.muted) }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption.bold())
        }.padding(13).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 23))
    }
}
