import SwiftUI

struct FriendProfileView: View {
    let store: TripStore
    let friendID: String
    @Environment(\.explorerNavigation) private var navigation
    @State private var error: String?
    @State private var loading = false
    private var friend: ExplorerFriend? { store.social.friends.first { $0.id == friendID } }
    private var allowed: Bool { store.family.allows(.social) && friend?.canInteract == true }
    private var activity: [FriendActivity] { FriendActivity.recent(store.social.cards[friendID] ?? []) }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                ExplorerAvatar(size: 124, avatar: friend?.avatar)
                Text(friend?.displayName ?? L10n.text("Explorer friend")).font(.system(.largeTitle, design: .rounded, weight: .heavy))
                Text("Adventure is better together").foregroundStyle(Theme.muted)
                if allowed {
                    ViewThatFits(in: .horizontal) {
                        HStack { actions }
                        VStack { actions }
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent discoveries").font(.system(.title2, design: .rounded, weight: .bold))
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
                            Button("See collection") { navigation?.open(.friend(friendID, 1)) }.frame(minHeight: 44).accessibilityIdentifier("friend-profile-collection")
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                } else if !loading { Text("This friendship is unavailable. Ask a grown-up to check your settings.") }
                if loading { ProgressView() }
                if let error { Text(error).foregroundStyle(Theme.muted); Button("Try again") { Task { await refresh() } } }
            }.padding(24)
        }.background(ProfileBackdrop()).navigationTitle("Friend profile").navigationBarTitleDisplayMode(.inline)
            .task { await refresh() }.refreshable { await refresh() }
    }

    @ViewBuilder private var actions: some View {
        Button { navigation?.open(.friend(friendID, 0)) } label: { Label("Message", systemImage: "bubble.left.fill") }
            .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friend-profile-message")
        Button { navigation?.open(.exchange(friendID, nil)) } label: { Label("Give a card copy", systemImage: "gift.fill") }
            .buttonStyle(ExplorerButtonStyle(secondary: true)).disabled(!store.family.allows(.sharing))
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
            if let connection = try? ConnectionVault().loadOrCreate() { bytes = try? await store.social.client.artwork(card, friendID: friendID, connection: connection) }
        }
    }
}
