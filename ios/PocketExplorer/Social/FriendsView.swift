import SwiftUI

struct FriendsView: View {
    let store: TripStore
    @State private var code = ""
    @FocusState private var codeFocused: Bool
    @State private var settings = false
    @State private var working = false
    @State private var error: String?
    private var allowed: Bool { store.family.family != nil && store.family.allows(.social) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Adventure is better together").font(.system(.largeTitle, design: .rounded, weight: .bold))
                        Text("Share discoveries with people you know.").foregroundStyle(Theme.muted)
                    }
                    ExplorerAvatar(size: 84, avatar: "aj")
                }
                if allowed, let family = store.family.family {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your private friend code").font(.headline)
                        Text(family.friendCode).font(.system(.title2, design: .monospaced, weight: .bold)).textSelection(.enabled).accessibilityIdentifier("friend-code")
                        Text("Share this code only with someone you know. Both of you choose to become friends.").font(.caption).foregroundStyle(Theme.muted)
                    }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(Theme.mint, in: RoundedRectangle(cornerRadius: 26))
                    VStack(spacing: 12) {
                        TextField("Enter a friend's code", text: $code).focused($codeFocused).textInputAutocapitalization(.characters).autocorrectionDisabled().textFieldStyle(.roundedBorder).accessibilityIdentifier("friend-code-input")
                        Button("Ask to be friends") { codeFocused = false; run { connection in try await store.social.invite(code, connection: connection); code = "" } }
                            .buttonStyle(ExplorerButtonStyle()).disabled(code.isEmpty || working).accessibilityIdentifier("friend-invite")
                    }
                    if store.social.friends.isEmpty { Text("Your next adventure could start with a friend.").foregroundStyle(Theme.muted) }
                    ForEach(store.social.friends) { friend in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 14) {
                                ExplorerAvatar(size: 58, avatar: friend.avatar)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(friend.displayName).font(.headline)
                                    Text(L10n.text(friend.blocked ? "Blocked" : friend.state == "incoming" ? "Wants to be your friend" : friend.state == "outgoing" ? "Waiting for your friend" : friend.state == "removed" ? "Friendship removed" : "Explorer friend")).font(.caption).foregroundStyle(Theme.muted)
                                }
                                Spacer()
                            }
                            if friend.canInteract {
                                NavigationLink(value: ExplorerRoute.friendProfile(friend.id)) { Label("Open friendship", systemImage: "bubble.left.and.bubble.right.fill") }
                                    .accessibilityIdentifier("friend-open-\(friend.id)")
                            } else if friend.state == "incoming" && !friend.blocked {
                                HStack {
                                    Button("Accept friendship") { act("accept", friend: friend) }.accessibilityIdentifier("friend-accept-\(friend.id)")
                                    Spacer(); Button("Decline") { act("remove", friend: friend) }
                                }
                            } else if friend.blocked { Button("Unblock friend") { act("unblock", friend: friend) } }
                        }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 26)).disabled(working)
                    }
                    if store.social.friendCursor != nil { Button("More friends") { run { try await store.social.refreshFriends(connection: $0, more: true) } } }
                    Button("Refresh friends") { run { try await store.social.refreshFriends(connection: $0) } }.accessibilityIdentifier("friends-refresh")
                } else {
                    Text("A grown-up can turn on friendships in Family settings.")
                    Button("Family settings") { settings = true }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friends-family-settings")
                }
                if working { ProgressView() }
                if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") }
            }.padding(22)
        }.scrollDismissesKeyboard(.interactively).background(ExplorerBackdrop()).navigationTitle("Friends").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button { settings = true } label: { Image(systemName: "gearshape") }.accessibilityLabel("Family settings") }
            .sheet(isPresented: $settings) { FamilySettingsView(family: store.family) }
            .task(id: allowed) {
                guard allowed else { store.social.clearAccess(); return }
                do { try await store.social.refreshFriends(connection: ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription }
            }
            .refreshable { if allowed { do { try await store.social.refreshFriends(connection: ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } } }
    }
    private func act(_ action: String, friend: ExplorerFriend) { run { try await store.social.action(action, friendID: friend.id, connection: $0) } }
    private func run(_ work: @escaping (ShareConnection) async throws -> Void) {
        guard !working else { return }; working = true; error = nil
        Task { defer { working = false }; do { try await work(ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } }
    }
}

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
    private var friend: ExplorerFriend? { store.social.friends.first { $0.id == friendID } }
    private var allowed: Bool { store.family.allows(.social) && friend?.canInteract == true }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Button { navigation?.open(.friendProfile(friendID)) } label: {
                    HStack(spacing: 14) {
                        ExplorerAvatar(size: 64, avatar: friend?.avatar)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(friend?.displayName ?? L10n.text("Explorer friend")).font(.title2.bold())
                            Text("View profile").font(.subheadline).foregroundStyle(Theme.muted)
                        }
                        Spacer(); Image(systemName: "chevron.right")
                    }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 24))
                }.buttonStyle(.plain).accessibilityIdentifier("conversation-profile")
                Picker("Friendship", selection: $page) { Text("Messages").tag(0); Text("Cards").tag(1); Text("Gifts").tag(2) }.pickerStyle(.segmented).accessibilityIdentifier("friend-pages")
                if !allowed { Text("This friendship is unavailable. Ask a grown-up to check your settings.") }
                else if page == 0 {
                    Text("Say hello and share something you discovered.").font(.subheadline).foregroundStyle(Theme.muted)
                    ForEach(store.social.messages[friendID] ?? []) { message in
                        HStack {
                            if message.mine { Spacer(minLength: 45) }
                            messageContent(message).padding(15).background(message.mine ? Theme.mint : .white, in: RoundedRectangle(cornerRadius: 21))
                                .frame(maxWidth: .infinity, alignment: message.mine ? .trailing : .leading).accessibilityIdentifier("friend-message-\(message.sequence)")
                            if !message.mine { Spacer(minLength: 45) }
                        }
                    }
                    if store.social.messageCursors[friendID] != nil { Button("More messages") { reload() } }
                    TextField("Write to your friend", text: $text, axis: .vertical).focused($messageFocused).lineLimit(1...4).textFieldStyle(.roundedBorder).accessibilityIdentifier("friend-message-input")
                        .onChange(of: text) { _, value in
                            do { try store.social.saveDraft(value, friendID: friendID, connection: ConnectionVault().loadOrCreate()) }
                            catch { self.error = error.localizedDescription }
                        }
                    Button("Send message") { messageFocused = false; run { connection in
                        try store.social.saveDraft(text, friendID: friendID, connection: connection)
                        try await store.social.send(friendID, connection: connection); text = store.social.draft(for: friendID)
                    } }.buttonStyle(ExplorerButtonStyle()).disabled(working || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityIdentifier("friend-message-send")
                } else if !store.family.allows(.sharing) { Text("A grown-up can allow card sharing in Family settings.") }
                else if page == 1 {
                    Text("Your friend's discoveries").font(.title2.bold())
                    if store.social.cards[friendID]?.isEmpty == true { Text("More discoveries are on their way.") }
                    ForEach(store.social.cards[friendID] ?? []) { card in
                        Button { navigation?.open(.friendCard(friendID, card.id)) } label: {
                            HStack { LeafBadge(); Text(card.versions.last!.reply.title).font(.headline); Spacer(); Image(systemName: "chevron.right") }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 24))
                        }.buttonStyle(.plain).accessibilityIdentifier("friend-card-\(card.id)")
                    }
                    if store.social.cardCursors[friendID] != nil { Button("More cards") { run { try await store.social.refreshCards(friendID, connection: $0, more: true) } } }
                } else {
                    Button("Give a card copy") { navigation?.open(.exchange(friendID, nil)) }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friend-give")
                    ForEach(store.social.transfers[friendID] ?? []) { transfer in
                        VStack(alignment: .leading, spacing: 12) {
                            Label(L10n.text(transfer.kind == "gift" ? "A discovery gift" : "A card exchange"), systemImage: transfer.kind == "gift" ? "gift.fill" : "arrow.left.arrow.right")
                                .font(.headline)
                            Text(transfer.offered.title)
                            if let wanted = transfer.wanted { Text("↔ \(wanted.title)") }
                            Text(L10n.text(transfer.state.capitalized)).font(.caption).foregroundStyle(Theme.muted)
                            if transfer.state == "pending" {
                                if transfer.outgoing { Button("Cancel exchange") { decide("cancel", transfer) } }
                                else {
                                    Text("Both of you keep your original cards and receive a copy.").font(.caption)
                                    Button("Accept exchange") { decide("accept", transfer) }.accessibilityIdentifier("exchange-accept")
                                    Button("Decline exchange") { decide("decline", transfer) }
                                }
                            }
                            if let received = transfer.receivedCardID, let discovery = store.state.discoveries.first(where: { $0.collectionID == received }) {
                                NavigationLink("Open received card", value: ExplorerRoute.card(discovery.id)).accessibilityIdentifier("received-card-\(received)")
                            }
                        }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(.white, in: RoundedRectangle(cornerRadius: 26))
                    }
                    if store.social.transferCursors[friendID] != nil { Button("More gifts and exchanges") { run { try await store.social.refreshTransfers(friendID, store: store, connection: $0, more: true) } } }
                }
                if working { ProgressView() }
                if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") }
                if reported { Text("Your report was saved for review.").accessibilityIdentifier("social-reported") }
                Button("Refresh friendship") { reload() }.accessibilityIdentifier("friend-refresh")
            }.padding(22)
        }.scrollDismissesKeyboard(.interactively).background(ExplorerBackdrop()).navigationTitle(friend?.displayName ?? L10n.text("Explorer friend"))
            .navigationBarTitleDisplayMode(.inline)
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
                while page == 0 && !Task.isCancelled {
                    do { try await Task.sleep(for: .seconds(15)) } catch { return }
                    await loadPage()
                }
            }
    }
    @ViewBuilder private func messageContent(_ message: ExplorerMessage) -> some View {
        if let base = try? ConnectionVault().loadOrCreate().validatedURL, let invitation = EventMessage(text: message.text, base: base) {
            Button { navigation?.open(.event(invitation.eventID)) } label: {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Event invitation", systemImage: "map.fill").font(.caption).foregroundStyle(Theme.forest)
                    Text(invitation.title).font(.headline)
                    Label("View event", systemImage: "arrow.right.circle.fill").font(.subheadline.bold())
                }.frame(maxWidth: .infinity, alignment: .leading).padding(6)
            }.buttonStyle(.plain).accessibilityIdentifier("message-event-\(invitation.eventID)")
        } else { Text(message.text) }
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
