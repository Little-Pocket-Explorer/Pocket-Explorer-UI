import SwiftUI

struct FriendDetailView: View {
    let store: TripStore
    let friendID: String
    @State private var page = 0
    @State private var text = ""
    @State private var error: String?
    @State private var working = false
    @State private var gift = false
    @State private var safety = false
    @State private var report = false
    @State private var reported = false
    @State private var reportID = UUID()
    @State private var selected: KnowledgeCard?
    @State private var profile = false
    @Environment(\.scenePhase) private var phase
    private var friend: ExplorerFriend? { store.social.friends.first { $0.id == friendID } }
    private var allowed: Bool { store.family.allows(.social) && friend?.canInteract == true }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Picker("Friendship", selection: $page) { Text("Messages").tag(0); Text("Cards").tag(1); Text("Gifts").tag(2) }.pickerStyle(.segmented).accessibilityIdentifier("friend-pages")
                if !allowed { Text("This friendship is unavailable. Ask a grown-up to check your settings.") }
                else if page == 0 {
                    Button { profile = true } label: {
                        HStack(spacing: 10) {
                            ExplorerAvatar(size: 42, avatar: friend?.avatar)
                            VStack(alignment: .leading, spacing: 2) { Text(friend?.displayName ?? "Explorer friend").font(.headline); Text("Family friend").font(.caption).foregroundStyle(Theme.muted) }
                            Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
                        }.padding(11).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).accessibilityIdentifier("open-friend-profile")
                    Text("Say hello and share something you discovered.").font(.subheadline).foregroundStyle(Theme.muted)
                    ForEach(store.social.messages[friendID] ?? []) { message in
                        HStack {
                            if message.mine { Spacer(minLength: 45) }
                            Text(message.text).padding(15).background(message.mine ? Theme.mint : .white, in: RoundedRectangle(cornerRadius: 21))
                                .frame(maxWidth: .infinity, alignment: message.mine ? .trailing : .leading).accessibilityIdentifier("friend-message-\(message.sequence)")
                            if !message.mine { Spacer(minLength: 45) }
                        }
                    }
                    if store.social.messageCursors[friendID] != nil { Button("More messages") { reload() } }
                    TextField("Write to your friend", text: $text, axis: .vertical).lineLimit(1...4).textFieldStyle(.roundedBorder).accessibilityIdentifier("friend-message-input")
                        .onChange(of: text) { _, value in
                            do { try store.social.saveDraft(value, friendID: friendID, connection: ConnectionVault().loadOrCreate()) }
                            catch { self.error = error.localizedDescription }
                        }
                    Button("Send message") { run { connection in
                        try store.social.saveDraft(text, friendID: friendID, connection: connection)
                        try await store.social.send(friendID, connection: connection); text = store.social.draft(for: friendID)
                    } }.buttonStyle(ExplorerButtonStyle()).disabled(working || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityIdentifier("friend-message-send")
                } else if !store.family.allows(.sharing) { Text("A grown-up can allow card sharing in Family settings.") }
                else if page == 1 {
                    Text("Your friend's discoveries").font(.title2.bold())
                    if store.social.cards[friendID]?.isEmpty == true { Text("More discoveries are on their way.") }
                    ForEach(store.social.cards[friendID] ?? []) { card in
                        Button { selected = card } label: {
                            HStack { LeafBadge(); Text(card.versions.last!.reply.title).font(.headline); Spacer(); Image(systemName: "chevron.right") }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 24))
                        }.buttonStyle(.plain).accessibilityIdentifier("friend-card-\(card.id)")
                    }
                    if store.social.cardCursors[friendID] != nil { Button("More cards") { run { try await store.social.refreshCards(friendID, connection: $0, more: true) } } }
                } else {
                    Button("Give a card copy") { gift = true }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friend-give")
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
                                NavigationLink("Open received card") { CardDetailView(store: store, discoveryID: discovery.id) }.accessibilityIdentifier("received-card-\(received)")
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
        }.background(ExplorerBackdrop()).navigationTitle(friend?.displayName ?? L10n.text("Explorer friend"))
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
            .sheet(isPresented: $gift) { GiftComposerView(store: store, friendID: friendID) }
            .sheet(item: $selected) { card in FriendCardView(store: store, friendID: friendID, card: card) }
            .sheet(isPresented: $profile) { if let friend { FriendProfileView(store: store, friend: friend, openGift: { gift = true }) } }
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

struct FriendProfileView: View {
    let store: TripStore
    let friend: ExplorerFriend
    var openGift: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var muted = false
    private var cards: [KnowledgeCard] { store.social.cards[friend.id] ?? [] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ExplorerAvatar(size: 104, avatar: friend.avatar)
                    Text(friend.displayName).font(.system(.largeTitle, design: .rounded, weight: .black))
                    Text("Family friend").foregroundStyle(Theme.muted)
                    HStack(spacing: 10) {
                        Button { dismiss() } label: { Label("Message", systemImage: "message.fill") }.buttonStyle(ExplorerButtonStyle())
                        Button(action: openGift) { Label("Gift a card", systemImage: "gift.fill") }.buttonStyle(ExplorerButtonStyle()).disabled(!store.family.allows(.sharing))
                    }
                    HStack(spacing: 0) {
                        metric(cards.count, "Cards", "rectangle.stack.fill")
                        metric(0, "Places", "mappin.circle.fill")
                        metric(0, "Rare", "star.fill")
                    }.padding(.vertical, 14).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 23))
                    section("Recent activity") { Text("New discoveries and card updates from \(friend.displayName) appear here.").foregroundStyle(Theme.muted) }
                    section("\(friend.displayName)'s collection") {
                        if cards.isEmpty { Text("New discoveries will appear here.").foregroundStyle(Theme.muted) }
                        ForEach(cards) { card in Text(card.versions.last?.reply.title ?? "Discovery").frame(maxWidth: .infinity, alignment: .leading).padding(12).background(Theme.mint, in: RoundedRectangle(cornerRadius: 16)) }
                    }
                    Button(muted ? "Notifications muted" : "Mute notifications") { muted.toggle() }
                        .frame(minHeight: 44).foregroundStyle(muted ? .red : Theme.muted).accessibilityIdentifier("friend-mute")
                }.padding(22)
            }.background(ExplorerBackdrop()).toolbar { Button("Done") { dismiss() } }
        }.tint(Theme.forest)
    }

    private func metric(_ value: Int, _ label: String, _ icon: String) -> some View {
        VStack(spacing: 4) { Label(value.formatted(), systemImage: icon).font(.title3.bold()); Text(label).font(.caption).foregroundStyle(Theme.muted) }.frame(maxWidth: .infinity)
    }
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) { Text(title).font(.headline); content() }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22))
    }
}
