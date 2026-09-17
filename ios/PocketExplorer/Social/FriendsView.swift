import SwiftUI

struct FriendDetailView: View {
    @Environment(\.explorerNavigation) private var navigation
    let store: TripStore
    let friendID: String
    @State var page = 0
    @State private var text = ""
    @FocusState private var messageFocused: Bool
    @State private var error: String?
    @State private var working = false
    @State private var safety = false
    @State private var report = false
    @State private var reported = false
    @State private var reportID = UUID()
    @Environment(\.scenePhase) private var phase
    var body: some View {
        VStack(spacing: 0) {
            conversationHeader
            if !allowed {
                ContentUnavailableView("This friendship is unavailable. Ask a grown-up to check your settings.", systemImage: "person.slash")
            } else if page == 0 { conversation }
            else { library }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { if allowed && page == 0 { composer } }
        .scrollDismissesKeyboard(.interactively).background(ExplorerBackdrop()).navigationBarTitleDisplayMode(.inline)
            .toolbar { Button { safety = true } label: { Image(systemName: "ellipsis.circle") }.accessibilityLabel("Friendship options") }
            .confirmationDialog("Friendship options", isPresented: $safety) {
                Button("Report a concern") { report = true }
                Button("Block friend", role: .destructive) { run { try await store.social.action("block", friendID: friendID, connection: $0) } }
                Button("Remove friend", role: .destructive) { run { try await store.social.action("remove", friendID: friendID, connection: $0) } }
            }
            .confirmationDialog("What would you like to report?", isPresented: $report) {
                ForEach(["unkind", "privacy", "unsafe", "other"], id: \.self) { reason in
                    Button(L10n.text(reason.capitalized)) { run { try await store.social.client.report(reportID, friendID: friendID, reason: reason, connection: $0); reported = true; reportID = UUID() } }
                }
            }
            .onAppear { text = store.social.draft(for: friendID) }
            .task(id: "\(page):\(phase == .active):\(allowed)") {
                guard allowed, phase == .active else { return }
                await loadPage()
                if page == 0 { try? store.social.markRead(friendID) }
                while page == 0 && !Task.isCancelled {
                    do { try await Task.sleep(for: .seconds(15)) } catch { return }
                    await loadPage()
                    try? store.social.markRead(friendID)
                }
            }
    }

    private var conversationHeader: some View {
        HStack(spacing: 12) {
            Button { navigation?.open(.friendProfile(friendID)) } label: {
                HStack(spacing: 10) {
                    ExplorerAvatar(size: 48, avatar: friend?.avatar).overlay(alignment: .bottomTrailing) { FriendPresenceDot(available: friend?.available == true) }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(friend?.displayName ?? L10n.text("Explorer friend")).font(.headline)
                        if let friend { FriendPresenceLabel(friend: friend) }
                        Text("Family friend").font(.caption2).foregroundStyle(Theme.muted)
                    }
                }
            }.buttonStyle(.plain).accessibilityIdentifier("conversation-profile")
            Spacer()
            Button { navigation?.open(.friendProfile(friendID)) } label: { Image(systemName: "info.circle").font(.title2).frame(width: 44, height: 44) }
                .accessibilityLabel("View profile").accessibilityIdentifier("open-friend-profile")
        }.padding(.horizontal, 18).padding(.vertical, 10).background(.white.opacity(0.92))
    }

    private var conversation: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if store.social.messageCursors[friendID] != nil { Button("More messages") { reload() } }
                ForEach(store.social.messages[friendID] ?? []) { message in messageRow(message) }
                if working { ProgressView() }
                if let error { Text(error).font(.caption).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") }
                if reported { Text("Your report was saved for review.").accessibilityIdentifier("social-reported") }
            }.padding(.horizontal, 16).padding(.vertical, 20)
        }.defaultScrollAnchor(.bottom)
    }

    @ViewBuilder private func messageRow(_ message: ExplorerMessage) -> some View {
        let isEvent = eventMessage(message) != nil
        HStack(alignment: .bottom, spacing: 8) {
            if !message.mine { ExplorerAvatar(size: 34, avatar: friend?.avatar) }
            if message.mine { Spacer(minLength: 58) }
            messageContent(message)
                .padding(isEvent ? 0 : 13)
                .background(isEvent ? Color.clear : message.mine ? Color(red: 0.86, green: 0.95, blue: 1) : .white,
                            in: RoundedRectangle(cornerRadius: 19))
                .frame(maxWidth: 280, alignment: message.mine ? .trailing : .leading)
                .accessibilityIdentifier("friend-message-\(message.sequence)")
            if !message.mine { Spacer(minLength: 58) }
        }.frame(maxWidth: .infinity)
    }

    private var composer: some View {
        HStack(spacing: 8) {
            Button { page = 2 } label: { Image(systemName: "plus").font(.title3).frame(width: 42, height: 42).background(Theme.mint, in: Circle()) }
                .accessibilityLabel("Gifts and exchanges").accessibilityIdentifier("friend-section-gifts")
            TextField("Write to your friend", text: $text, axis: .vertical).focused($messageFocused).lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 10).background(.white, in: Capsule()).accessibilityIdentifier("friend-message-input")
                .onChange(of: text) { _, value in
                    do { try store.social.saveDraft(value, friendID: friendID, connection: ConnectionVault().loadOrCreate()) }
                    catch { self.error = error.localizedDescription }
                }
            Button { page = 1 } label: { Image(systemName: "rectangle.stack").frame(width: 38, height: 42) }
                .accessibilityLabel("Friend cards").accessibilityIdentifier("friend-section-cards")
            Button { send() } label: { Image(systemName: "arrow.up.circle.fill").font(.title2).frame(width: 38, height: 42) }
                .accessibilityLabel("Send message").disabled(working || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("friend-message-send")
        }.padding(.horizontal, 12).padding(.vertical, 9).background(.ultraThinMaterial)
    }

    private var library: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button { page = 0 } label: { Label("Messages", systemImage: "bubble.left.fill") }.accessibilityIdentifier("friend-section-messages")
                    Spacer()
                    Button { page = page == 1 ? 2 : 1 } label: { Label(page == 1 ? "Gifts" : "Cards", systemImage: page == 1 ? "gift.fill" : "rectangle.stack.fill") }
                        .accessibilityIdentifier(page == 1 ? "friend-section-gifts" : "friend-section-cards").accessibilityAddTraits(.isSelected)
                }.buttonStyle(.bordered)
                if !store.family.allows(.sharing) { Text("A grown-up can allow card sharing in Family settings.") }
                else if page == 1 { cards }
                else { transfers }
                if working { ProgressView() }
                if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") }
                Button("Refresh friendship") { reload() }.accessibilityIdentifier("friend-refresh")
            }.padding(20)
        }
    }

    @ViewBuilder private var cards: some View {
        Text("Your friend's discoveries").font(.title2.bold())
        if store.social.cards[friendID]?.isEmpty == true { Text("More discoveries are on their way.") }
        ForEach(store.social.cards[friendID] ?? []) { card in
            Button { navigation?.open(.friendCard(friendID, card.id)) } label: {
                HStack { FriendArtworkView(store: store, friendID: friendID, card: card).frame(width: 70, height: 82).clipped().clipShape(RoundedRectangle(cornerRadius: 15)); Text(card.versions.last!.reply.title).font(.headline); Spacer(); Image(systemName: "chevron.right") }
                    .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 22))
            }.buttonStyle(.plain).accessibilityIdentifier("friend-card-\(card.id)")
        }
        if store.social.cardCursors[friendID] != nil { Button("More cards") { run { try await store.social.refreshCards(friendID, connection: $0, more: true) } } }
    }

    @ViewBuilder private var transfers: some View {
        Button("Give a card copy") { navigation?.open(.exchange(friendID, nil)) }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friend-give")
        ForEach(store.social.transfers[friendID] ?? []) { transfer in transferRow(transfer) }
        if store.social.transferCursors[friendID] != nil { Button("More gifts and exchanges") { run { try await store.social.refreshTransfers(friendID, store: store, connection: $0, more: true) } } }
    }

    private func transferRow(_ transfer: CardTransfer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10n.text(transfer.kind == "gift" ? "A discovery gift" : "A card exchange"), systemImage: transfer.kind == "gift" ? "gift.fill" : "arrow.left.arrow.right").font(.headline)
            Text(transfer.offered.title)
            if let wanted = transfer.wanted { Text("↔ \(wanted.title)") }
            Text(L10n.text(transfer.state.capitalized)).font(.caption).foregroundStyle(Theme.muted)
            if transfer.state == "pending" {
                if transfer.outgoing { Button("Cancel exchange") { decide("cancel", transfer) } }
                else { Button("Accept exchange") { decide("accept", transfer) }.accessibilityIdentifier("exchange-accept"); Button("Decline exchange") { decide("decline", transfer) } }
            }
            if let received = transfer.receivedCardID, let discovery = store.state.discoveries.first(where: { $0.collectionID == received }) {
                NavigationLink("Open received card", value: ExplorerRoute.card(discovery.id)).accessibilityIdentifier("received-card-\(received)")
            }
        }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private func send() {
        messageFocused = false
        run { connection in
            try store.social.saveDraft(text, friendID: friendID, connection: connection)
            try await store.social.send(friendID, connection: connection)
            text = store.social.draft(for: friendID)
        }
    }
    @ViewBuilder private func messageContent(_ message: ExplorerMessage) -> some View {
        if let invitation = eventMessage(message) {
            Button { navigation?.open(.event(invitation.eventID)) } label: {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18).fill(Theme.mint)
                        Image(systemName: "binoculars.fill").font(.system(size: 42)).foregroundStyle(Theme.forest.opacity(0.4))
                    }.frame(height: 112)
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Event invitation", systemImage: "map.fill").font(.caption).foregroundStyle(Theme.forest)
                        Text(invitation.title).font(.headline)
                        HStack { Text("Shared event").font(.caption).foregroundStyle(Theme.muted); Spacer(); Label("View", systemImage: "chevron.right").font(.subheadline.bold()).foregroundStyle(Theme.forest) }
                    }.padding(13)
                }.frame(width: 230, alignment: .leading).background(.white, in: RoundedRectangle(cornerRadius: 20))
            }.buttonStyle(.plain).accessibilityIdentifier("message-event-\(invitation.eventID)")
        } else { Text(message.text) }
    }

    private func eventMessage(_ message: ExplorerMessage) -> EventMessage? {
        guard let connection = try? ConnectionVault().loadOrCreate(), let base = connection.validatedURL else { return nil }
        return EventMessage(text: message.text, base: base)
    }

    private func decide(_ decision: String, _ transfer: CardTransfer) { run { try await store.social.decide(decision, transferID: transfer.id, store: store, connection: $0) } }
    private func reload() { run { connection in try await store.social.refreshFriends(connection: connection); await loadPage() } }
    private func loadPage() async {
        guard allowed else { return }
        do {
            let connection = try ConnectionVault().loadOrCreate()
            if page == 0 { try await store.social.refreshMessages(friendID, connection: connection) }
            else if store.family.allows(.sharing) {
                if page == 1 { try await store.social.refreshCards(friendID, connection: connection) }
                else { try await store.social.refreshTransfers(friendID, store: store, connection: connection) }
            }
        } catch { if !(error is CancellationError) { self.error = error.localizedDescription } }
    }
    private func run(_ work: @escaping (ShareConnection) async throws -> Void) {
        guard !working else { return }; working = true; error = nil
        Task { defer { working = false }; do { try await work(ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } }
    }
}

private extension FriendDetailView {
    var friend: ExplorerFriend? { store.social.friends.first { $0.id == friendID } }
    var allowed: Bool { store.family.allows(.social) && friend?.canInteract == true }
}
