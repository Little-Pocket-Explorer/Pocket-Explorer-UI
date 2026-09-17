import SwiftUI

struct EventDetailView: View {
    let store: TripStore
    @State private var settings = false
    @State private var sharing = false
    @State private var openingFriendShare = false
    @State private var shareMessage: String?
    @State var event: ExplorerEvent
    @State private var location = DiscoveryLocation()
    @State private var choice: Int?
    @State private var feedback: EventClaim?
    @State private var error: String?
    @State private var earnedID: UUID?
    @State private var revealed = false
    @Environment(\.explorerNavigation) private var navigation
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        FeatureNavigation {
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
                }.padding(22)
            }.background(ExplorerBackdrop()).navigationTitle("Event discovery").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if navigation == nil {
                        ToolbarItem(placement: .topBarLeading) {
                            Button { dismiss() } label: { Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44) }
                                .accessibilityLabel("Done")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { sharing = true } label: { Image(systemName: "square.and.arrow.up").frame(minWidth: 44, minHeight: 44) }
                            .accessibilityLabel("Share event").accessibilityIdentifier("event-share-options")
                    }
                }
                .navigationDestination(item: $earnedID) { id in
                    if let discovery = store.state.discoveries.first(where: { $0.id == id }) {
                        if revealed { NewCardView(store: store, discoveryID: id, close: { dismiss() }) }
                        else { CardUnlockView(discovery: discovery, onReveal: { revealed = true }, store: store) }
                    }
                }
        }.tint(Theme.forest)
            .sheet(isPresented: $settings) { FamilySettingsView(family: store.family) }
            .sheet(isPresented: $sharing, onDismiss: {
                if openingFriendShare {
                    openingFriendShare = false
                    navigation?.open(.eventShare(event.id))
                }
            }) {
                EventShareOptions(event: event, message: $shareMessage,
                    allowsSharing: store.family.allows(.sharing), allowsFriends: store.family.allows(.sharing) && store.family.allows(.social), onFriend: {
                    openingFriendShare = true
                    sharing = false
                })
                .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
            }
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

private struct EventShareOptions: View {
    let event: ExplorerEvent
    @Binding var message: String?
    let allowsSharing: Bool
    let allowsFriends: Bool
    let onFriend: () -> Void
    @Environment(\.dismiss) private var dismiss
    private var url: URL? { try? ConnectionVault().loadOrCreate().validatedURL?.appendingPathComponent("events/\(event.id)") }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    EventSharePreview(event: event)
                    if let message { Text(message).font(.caption).foregroundStyle(Theme.muted).accessibilityIdentifier("event-share-message") }
                    if allowsFriends {
                        Button(action: onFriend) { shareRow("Share to friend", detail: "Send privately in Messages", symbol: "person.2.fill") }
                            .buttonStyle(.plain).accessibilityIdentifier("event-share-friend")
                    }
                    if let url, allowsSharing {
                        Button {
                            UIPasteboard.general.url = url
                            message = L10n.text("Link copied.")
                        } label: { shareRow("Copy link", detail: "Share outside Pocket Explorer", symbol: "link") }
                            .buttonStyle(.plain).accessibilityIdentifier("event-copy-link")
                    }
                    if !allowsSharing {
                        Text("A grown-up can turn on sharing in Family settings.").font(.callout).foregroundStyle(Theme.muted)
                    }
                    Spacer(minLength: 0)
                }.padding(20)
            }.background(Theme.paper)
                .navigationTitle("Share event").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }.tint(Theme.forest)
    }

    private func shareRow(_ title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).font(.title2).frame(width: 48, height: 48).background(Theme.mint, in: Circle())
            VStack(alignment: .leading, spacing: 3) { Text(L10n.text(title)).font(.headline); Text(L10n.text(detail)).font(.caption).foregroundStyle(Theme.muted) }
            Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
        }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct EventSharePreview: View {
    let event: ExplorerEvent
    var body: some View {
        HStack(spacing: 12) {
            Image("event-\(event.background)").resizable().scaledToFill().frame(width: 84, height: 64).clipped().clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title).font(.headline).lineLimit(1)
                Label("Event", systemImage: "leaf.fill").font(.caption.bold()).foregroundStyle(Theme.forest)
                Text(L10n.date(Date(timeIntervalSince1970: event.startsAt / 1000), includeTime: true) + " · " + event.place).font(.caption).foregroundStyle(Theme.muted).lineLimit(1)
            }
            Spacer(minLength: 0)
        }.padding(10).background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}
