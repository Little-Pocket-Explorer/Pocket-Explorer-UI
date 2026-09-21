import SwiftUI

struct FriendProfileView: View {
    let store: TripStore
    let friendID: String
    @Environment(\.explorerNavigation) private var navigation
    @State private var error: String?
    @State private var loading = false
    @State private var options = false
    @State private var reporting = false
    @State private var muted: Bool
    @State private var reported = false
    @State private var reportID = UUID()
    private var friend: ExplorerFriend? { store.social.friends.first { $0.id == friendID } }
    private var allowed: Bool { store.family.allows(.social) && friend?.canInteract == true }
    private var activity: [FriendActivity] { FriendActivity.recent(store.social.cards[friendID] ?? []) }
    private var cards: [KnowledgeCard] { activity.map(\.card) }

    init(store: TripStore, friendID: String) {
        self.store = store
        self.friendID = friendID
        _muted = State(initialValue: UserDefaults.standard.bool(forKey: "muted-friend-\(friendID)"))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                ExplorerAvatar(size: 124, avatar: friend?.avatar).overlay(alignment: .bottomTrailing) { FriendPresenceDot(available: friend?.available == true) }
                Text(friend?.displayName ?? L10n.text("Explorer friend")).font(.system(.largeTitle, design: .rounded, weight: .heavy))
                if let friend { FriendPresenceLabel(friend: friend) }
                Label(muted ? "Notifications muted" : "Family friend", systemImage: muted ? "bell.slash.fill" : "checkmark.shield.fill").foregroundStyle(Theme.muted)
                if allowed {
                    ViewThatFits(in: .horizontal) {
                        HStack { actions }
                        VStack { actions }
                    }
                    HStack(spacing: 0) {
                        metric(cards.count, "Cards", "rectangle.stack.fill")
                        metric(0, "Places", "mappin.circle.fill")
                        metric(cards.filter { $0.tier == .rare || $0.tier == .epic }.count, "Rare", "star.fill")
                    }.padding(.vertical, 14).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 23))
                    Button { navigation?.open(.friend(friendID, 1)) } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack { Label("Shared map", systemImage: "map.fill").font(.headline); Spacer(); Image(systemName: "chevron.right") }
                            ZStack {
                                RoundedRectangle(cornerRadius: 18).fill(Theme.mint)
                                Image(systemName: "map").font(.system(size: 54)).foregroundStyle(Theme.forest.opacity(0.3))
                                HStack(spacing: 30) {
                                    Image(systemName: "mappin.circle.fill").foregroundStyle(Theme.forest)
                                    Image(systemName: "lock.circle.fill").foregroundStyle(Theme.muted)
                                    Image(systemName: "mappin.circle.fill").foregroundStyle(Theme.forest)
                                }.font(.title)
                            }.frame(height: 120)
                            (Text(cards.count.formatted()) + Text(" shared cards · exact locations hidden")).font(.caption).foregroundStyle(Theme.muted)
                        }.padding(16).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 24))
                    }.buttonStyle(.plain).accessibilityIdentifier("friend-shared-map")
                    Button { navigation?.open(.friend(friendID, 1)) } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.stack.fill").foregroundStyle(Theme.forest).frame(width: 32)
                            VStack(alignment: .leading, spacing: 3) {
                                (Text("View cards shared with") + Text(" \(friend?.displayName ?? L10n.text("Explorer friend"))")).font(.headline)
                                Text("\(cards.count) cards").font(.caption).foregroundStyle(Theme.muted)
                            }
                            Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
                        }.padding(13).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).accessibilityIdentifier("friend-shared-cards")
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent activity").font(.system(.title2, design: .rounded, weight: .bold))
                        if !store.family.allows(.sharing) { Text("A grown-up can allow card sharing in Family settings.") }
                        else {
                            ForEach(activity.prefix(8)) { item in
                                Button { navigation?.open(.friendCard(friendID, item.card.id)) } label: {
                                    HStack(spacing: 14) {
                                        FriendArtworkView(store: store, friendID: friendID, card: item.card)
                                            .frame(width: 88, height: 108).clipped().clipShape(RoundedRectangle(cornerRadius: 18))
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text(item.label).font(.caption).foregroundStyle(Theme.muted)
                                            Text(item.card.versions.last?.reply.title ?? "").font(.headline)
                                            Text(L10n.date(item.date)).font(.caption).foregroundStyle(Theme.muted)
                                        }
                                        Spacer(minLength: 0); Image(systemName: "chevron.right")
                                    }.padding(14).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 24))
                                }.buttonStyle(.plain).accessibilityIdentifier("friend-activity-\(item.id)")
                            }
                            if !loading && activity.isEmpty { Text("More discoveries are on their way.").foregroundStyle(Theme.muted) }
                            Text("\(friend?.displayName ?? "Friend")'s collection").font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(cards.prefix(6)) { card in
                                        Button { navigation?.open(.friendCard(friendID, card.id)) } label: {
                                            VStack(alignment: .leading, spacing: 7) {
                                                FriendArtworkView(store: store, friendID: friendID, card: card).frame(width: 126, height: 142).clipped().clipShape(RoundedRectangle(cornerRadius: 18))
                                                Text(card.versions.last?.reply.title ?? "Discovery").font(.caption.bold()).lineLimit(2)
                                            }.frame(width: 126, alignment: .leading)
                                        }.buttonStyle(.plain).accessibilityIdentifier("friend-collection-\(card.id)")
                                    }
                                }
                            }
                            Button("See all cards") { navigation?.open(.friend(friendID, 1)) }.frame(minHeight: 44).accessibilityIdentifier("friend-profile-collection")
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                } else if !loading { Text("This friendship is unavailable. Ask a grown-up to check your settings.") }
                if loading { ProgressView() }
                if reported { Label("Your report was saved for review.", systemImage: "checkmark.shield.fill").accessibilityIdentifier("friend-profile-reported") }
                if let error { Text(error).foregroundStyle(Theme.muted); Button("Try again") { Task { await refresh() } } }
            }.padding(24)
        }.background(ProfileBackdrop()).navigationTitle("Friend profile").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button { options = true } label: { Image(systemName: "ellipsis.circle").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel("Friend options").accessibilityIdentifier("friend-options") }
            .confirmationDialog("Friend options", isPresented: $options) {
                Button(muted ? "Unmute notifications" : "Mute notifications") { toggleMute() }
                Button("Remove friend", role: .destructive) { action("remove") }
                Button("Block friend", role: .destructive) { action("block") }
                Button("Report a concern") { reporting = true }
            }
            .confirmationDialog("What would you like to report?", isPresented: $reporting) {
                ForEach(["unkind", "privacy", "unsafe", "other"], id: \.self) { reason in
                    Button(L10n.text(reason.capitalized)) { report(reason) }
                }
            }
            .task { await refresh() }.refreshable { await refresh() }
    }

    @ViewBuilder private var actions: some View {
        Button { navigation?.open(.friend(friendID, 0)) } label: { Label("Message", systemImage: "bubble.left.fill") }
            .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friend-profile-message")
        Button { navigation?.open(.exchange(friendID, nil)) } label: { Label("Give a card copy", systemImage: "gift.fill") }
            .buttonStyle(ExplorerButtonStyle(secondary: true)).disabled(!store.family.allows(.sharing))
    }

    private func metric(_ value: Int, _ label: String, _ icon: String) -> some View {
        VStack(spacing: 4) { Label(value.formatted(), systemImage: icon).font(.title3.bold()); Text(label).font(.caption).foregroundStyle(Theme.muted) }.frame(maxWidth: .infinity)
    }

    private func toggleMute() {
        muted.toggle()
        UserDefaults.standard.set(muted, forKey: "muted-friend-\(friendID)")
    }

    private func action(_ value: String) {
        Task {
            do {
                try await store.social.action(value, friendID: friendID, connection: ConnectionVault().loadOrCreate())
                navigation?.back()
            } catch { self.error = error.localizedDescription }
        }
    }

    private func report(_ reason: String) {
        let id = reportID
        Task {
            do {
                try await store.social.client.report(id, friendID: friendID, reason: reason, connection: ConnectionVault().loadOrCreate())
                reportID = UUID(); reported = true
            } catch { self.error = error.localizedDescription }
        }
    }

    private func refresh() async {
        guard !loading else { return }; loading = true; error = nil
        defer { loading = false }
        do {
            let connection = try ConnectionVault().loadOrCreate()
            try await store.social.refreshFriends(connection: connection)
            if allowed && store.family.allows(.sharing) { try await store.social.refreshCards(friendID, connection: connection) }
        } catch { self.error = error.localizedDescription }
    }
}

struct FriendArtworkView: View {
    let store: TripStore
    let friendID: String
    let card: KnowledgeCard
    @State private var bytes: Data?
    var body: some View {
        Group {
            if let bytes, let image = UIImage(data: bytes) { Image(uiImage: image).resizable().scaledToFit() }
            else { RoundedRectangle(cornerRadius: 18).fill(Theme.mint).overlay { Image(systemName: "leaf.fill").foregroundStyle(Theme.forest) } }
        }.accessibilityHidden(true).task(id: card.versions.last?.artworkID) {
            if let connection = try? ConnectionVault().loadOrCreate() { bytes = try? await store.social.artwork(card, friendID: friendID, connection: connection) }
        }
    }
}
