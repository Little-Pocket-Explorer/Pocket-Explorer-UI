import SwiftUI

struct EventDetailView: View {
    let store: TripStore
    @State private var settings = false
    @State var event: ExplorerEvent
    @State private var location = DiscoveryLocation()
    @State private var choice: Int?
    @State private var feedback: EventClaim?
    @State private var error: String?
    @State private var earnedID: UUID?
    @State private var revealed = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    EventRow(event: event)
                    Text(event.description).font(.body)
                    if store.family.family == nil || !store.family.allows(.events) {
                        Text("Ask a grown-up to set up your explorer profile and allow events.")
                        Button("Family settings") { settings = true }.buttonStyle(ExplorerButtonStyle())
                    }
                    Text(event.organizer).font(.headline)
                    Text(L10n.date(Date(timeIntervalSince1970: event.startsAt / 1000), includeTime: true) + " • " + L10n.date(Date(timeIntervalSince1970: event.endsAt / 1000), includeTime: true)).font(.caption).foregroundStyle(Theme.muted)
                    Text("Visit this place, notice something new, and answer a little question to collect its card.").foregroundStyle(Theme.muted)
                    Button { location.request() } label: { Label("Check my location", systemImage: "location.fill") }
                        .buttonStyle(ExplorerButtonStyle()).disabled(location.isLoading).accessibilityIdentifier("event-location")
                    if location.isLoading { ProgressView("Finding your place…") }
                    if let value = location.error { Text(value).font(.caption) }
                    Text(event.challenge.question).font(.title2.bold())
                    challengeChoices
                    Button("Collect the event card", action: claim).buttonStyle(ExplorerButtonStyle())
                        .disabled(choice == nil || store.events.busy || !store.family.allows(.events)).accessibilityIdentifier("event-claim")
                    if store.events.busy { ProgressView("Checking your discovery…") }
                    if let feedback, !feedback.correct { Text(feedback.explanation ?? "").padding(18).background(Theme.mint, in: RoundedRectangle(cornerRadius: 20)).accessibilityIdentifier("event-feedback") }
                    if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("event-error") }
                    Button("Refresh event") {
                        Task {
                            do { event = try await EventClient().read(event.id, language: AppLanguage.current.rawValue, connection: ConnectionVault().loadOrCreate()); error = nil; choice = nil; feedback = nil }
                            catch { self.error = error.localizedDescription }
                        }
                    }.frame(minHeight: 44)
                    if store.family.allows(.sharing), let base = try? ConnectionVault().loadOrCreate().validatedURL {
                        ShareLink(item: base.appendingPathComponent("events/\(event.id)")) { Label("Share event", systemImage: "square.and.arrow.up") }.frame(minHeight: 44)
                    }
                }.padding(22)
            }.background(ExplorerBackdrop()).navigationTitle("Event discovery").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Done") { dismiss() } }
                .navigationDestination(item: $earnedID) { id in
                    if let discovery = store.state.discoveries.first(where: { $0.id == id }) {
                        if revealed { NewCardView(store: store, discoveryID: id, close: { dismiss() }) }
                        else { CardUnlockView(discovery: discovery, onReveal: { revealed = true }, store: store) }
                    }
                }
        }.tint(Theme.forest).sheet(isPresented: $settings) { FamilySettingsView(family: store.family) }
    }
    private var challengeChoices: some View {
                    ForEach(event.challenge.choices.indices, id: \.self) { index in
                        Button { choice = index; feedback = nil } label: {
                            HStack { Image(systemName: choice == index ? "checkmark.circle.fill" : "circle"); Text(event.challenge.choices[index]); Spacer() }
                                .padding(18).background(choice == index ? Theme.mint : .white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain).accessibilityIdentifier("event-choice-\(index)")
                    }
    }

    private func claim() {
        guard let choice else { return }
        guard let reading = location.reading, reading.isFresh(radius: event.radius) else { error = EventError.location.localizedDescription; return }
        error = nil
        Task {
            do {
                let result = try await store.events.claim(event, choice: choice, reading: reading, store: store, connection: ConnectionVault().loadOrCreate())
                feedback = result
                if let card = result.collectible { earnedID = store.state.discoveries.first { $0.collectionID == card.id }?.id }
            } catch { self.error = error.localizedDescription }
        }
    }
}
