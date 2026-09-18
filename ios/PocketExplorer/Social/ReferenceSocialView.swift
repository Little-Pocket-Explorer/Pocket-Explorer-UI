import SwiftUI

struct SocialView: View {
    let store: TripStore
    @State private var tab = 0
    @State private var code = ""
    @State private var settings = false
    @State private var adding = false
    @State private var working = false
    @State private var error: String?
    @State private var messageSearch = ""
    private var allowed: Bool { store.family.family != nil && store.family.allows(.social) }
    private var visibleFriends: [ExplorerFriend] {
        let query = messageSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.social.friends }
        return store.social.friends.filter { friend in
            friend.displayName.localizedCaseInsensitiveContains(query) ||
            (store.social.messages[friend.id]?.last?.text.localizedCaseInsensitiveContains(query) == true)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "leaf.fill").font(.title2).foregroundStyle(Theme.forest)
                    Text("Social").font(.system(.largeTitle, design: .rounded, weight: .black))
                    Spacer()
                    ExplorerAvatar(size: 42, avatar: store.family.family?.profile.avatar)
                }
                Picker("Social", selection: $tab) {
                    Text("Friends").tag(0); Text("Messages").tag(1); Text("Shared with Me").tag(2)
                }.pickerStyle(.segmented).accessibilityIdentifier("social-tabs")
                if allowed {
                    if tab == 0 { friends }
                    else if tab == 1 { messages }
                    else { sharedCards }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Friends are approved by a parent", systemImage: "lock.shield.fill").font(.headline)
                        Text("A grown-up can turn on friends and text chat in Family settings.").foregroundStyle(Theme.muted)
                        Button("Family settings") { settings = true }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friends-family-settings")
                    }.padding(18).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24))
                }
                if let error { Text(error).font(.caption).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") }
            }.padding(20)
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).navigationTitle("Social").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $settings) { FamilySettingsView(family: store.family) }
            .sheet(isPresented: $adding) { addFriendSheet }
            .task(id: allowed) {
                guard allowed else { store.social.clearAccess(); return }
                await refreshSocial()
            }
    }

    private var friends: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { Text("Your explorers").font(.title3.bold()); Spacer(); Button { adding = true } label: { Label("Add friend", systemImage: "plus.circle.fill") }.accessibilityIdentifier("social-add-friend") }
            if let code = store.family.family?.friendCode {
                Label(code, systemImage: "lock.fill").font(.caption.monospaced()).foregroundStyle(Theme.muted).accessibilityIdentifier("friend-code")
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.social.friends) { friend in
                        NavigationLink(value: ExplorerRoute.friendProfile(friend.id)) {
                            VStack(spacing: 6) {
                                ExplorerAvatar(size: 60, avatar: friend.avatar).overlay(alignment: .bottomTrailing) { FriendPresenceDot(available: friend.available) }
                                Text(friend.displayName).font(.caption).lineLimit(1)
                            }
                        }.buttonStyle(.plain).accessibilityIdentifier("friend-open-\(friend.id)")
                    }
                    Button { adding = true } label: { VStack(spacing: 6) { Image(systemName: "plus").font(.title2).frame(width: 60, height: 60).background(Theme.mint, in: Circle()); Text("Add friend").font(.caption) } }
                        .buttonStyle(.plain)
                }
            }
            Text("Recent activity").font(.title3.bold())
            ForEach(store.social.friends) { friend in
                if friend.state == "incoming" && !friend.blocked {
                    VStack(alignment: .leading, spacing: 8) {
                        activityRow(friend)
                        HStack { Button("Accept friendship") { act("accept", friend) }.accessibilityIdentifier("friend-accept-\(friend.id)"); Button("Decline") { act("remove", friend) } }
                    }
                } else if let activity = FriendActivity.recent(store.social.cards[friend.id] ?? []).first {
                    NavigationLink(value: ExplorerRoute.friendProfile(friend.id)) { activityRow(friend, activity: activity) }.buttonStyle(.plain)
                        .accessibilityIdentifier("social-activity-\(activity.id)")
                } else {
                    NavigationLink(value: ExplorerRoute.friendProfile(friend.id)) { activityRow(friend) }.buttonStyle(.plain)
                }
            }
            if store.social.friends.isEmpty { Text("Curiosity is better together. Add a trusted explorer to share discoveries.").padding(16).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20)) }
            Button("Refresh friends") { Task { await refreshSocial() } }.accessibilityIdentifier("friends-refresh")
        }
    }

    private var messages: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Friends approved by a parent", systemImage: "lock.fill").font(.caption).foregroundStyle(Theme.muted).frame(maxWidth: .infinity)
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(Theme.muted)
                TextField("Search messages", text: $messageSearch).textInputAutocapitalization(.never)
            }.padding(12).background(.white.opacity(0.94), in: Capsule()).accessibilityIdentifier("social-message-search")
            ForEach(visibleFriends) { friend in
                NavigationLink(value: ExplorerRoute.friend(friend.id, 0)) { messageRow(friend) }.buttonStyle(.plain)
                    .accessibilityIdentifier("social-message-\(friend.id)")
            }
            if store.social.friends.isEmpty { Text("Add a friend to start a conversation.").foregroundStyle(Theme.muted) }
        }
    }

    private var sharedCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shared with Me").font(.title3.bold())
            ForEach(store.social.friends) { friend in
                if let cards = store.social.cards[friend.id] {
                    ForEach(cards) { card in
                        NavigationLink(value: ExplorerRoute.friendCard(friend.id, card.id)) {
                            HStack { ExplorerAvatar(size: 42, avatar: friend.avatar); VStack(alignment: .leading) { Text(card.versions.last?.reply.title ?? "Discovery").font(.headline); Text(friend.displayName).font(.caption).foregroundStyle(Theme.muted) }; Spacer(); Image(systemName: "chevron.right") }.padding(13).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain)
                    }
                }
            }
            if store.social.cards.values.flatMap({ $0 }).isEmpty { Text("Shared discoveries will appear here.").padding(16).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20)) }
        }
    }

    private func activityRow(_ friend: ExplorerFriend) -> some View {
        HStack(spacing: 12) { ExplorerAvatar(size: 46, avatar: friend.avatar).overlay(alignment: .bottomTrailing) { FriendPresenceDot(available: friend.available) }; VStack(alignment: .leading, spacing: 3) { Text(friend.displayName).font(.headline); Text(friend.state == "outgoing" ? L10n.text("Waiting for your friend") : store.social.messages[friend.id]?.last?.text ?? L10n.text("Ready for an adventure")).font(.caption).foregroundStyle(Theme.muted).lineLimit(1) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }
            .padding(12).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
    }

    private func activityRow(_ friend: ExplorerFriend, activity: FriendActivity) -> some View {
        HStack(spacing: 12) {
            ExplorerAvatar(size: 46, avatar: friend.avatar).overlay(alignment: .bottomTrailing) { FriendPresenceDot(available: friend.available) }
            VStack(alignment: .leading, spacing: 3) {
                Text(friend.displayName).font(.headline)
                Text(activity.label).font(.caption).foregroundStyle(Theme.muted)
                Text(activity.card.versions.last?.reply.title ?? "Discovery").font(.subheadline.bold()).lineLimit(1)
            }
            Spacer(minLength: 0)
            FriendArtworkView(store: store, friendID: friend.id, card: activity.card).frame(width: 58, height: 64).clipped().clipShape(RoundedRectangle(cornerRadius: 13))
            Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
        }.padding(12).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
    }

    private func messageRow(_ friend: ExplorerFriend) -> some View {
        let message = store.social.messages[friend.id]?.last
        let event = message.flatMap { message in
            (try? ConnectionVault().loadOrCreate().validatedURL).flatMap { base in EventMessage(text: message.text, base: base) }
        }
        let unread = store.social.unreadCount(for: friend.id)
        return HStack(spacing: 12) {
            ExplorerAvatar(size: 48, avatar: friend.avatar).overlay(alignment: .bottomTrailing) { FriendPresenceDot(available: friend.available) }
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.displayName).font(.headline)
                Text(event?.title ?? message?.text ?? "Ready for an adventure").font(.caption).foregroundStyle(Theme.muted).lineLimit(2)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 7) {
                if let message { Text(Date(timeIntervalSince1970: message.createdAt / 1000).formatted(date: .omitted, time: .shortened)).font(.caption2).foregroundStyle(Theme.muted) }
                if unread > 0 {
                    Text(min(unread, 99).formatted()).font(.caption2.bold()).foregroundStyle(.white).frame(minWidth: 20, minHeight: 20)
                        .background(.red, in: Capsule()).accessibilityIdentifier("social-unread-\(friend.id)")
                } else if event != nil { Image(systemName: "map.fill").foregroundStyle(Theme.forest) }
            }
            Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
        }.padding(12).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
    }

    private var addFriendSheet: some View {
        NavigationStack {
            Form {
                Section("Invite someone you know") {
                    TextField("Friend code", text: $code).textInputAutocapitalization(.characters).autocorrectionDisabled()
                        .accessibilityIdentifier("friend-code-input")
                    Text("Both explorers need a grown-up's approval before messaging or sharing cards.").font(.caption).foregroundStyle(Theme.muted)
                }
                if let error { Section { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") } }
            }.navigationTitle("Add friend").toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { adding = false; code = "" } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send invite") { invite() }.disabled(code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || working)
                        .accessibilityIdentifier("friend-invite")
                }
            }
        }.tint(Theme.forest)
    }

    private func invite() {
        guard !working else { return }; working = true; error = nil
        Task { defer { working = false }; do { try await store.social.invite(code, connection: ConnectionVault().loadOrCreate()); code = ""; adding = false } catch { self.error = error.localizedDescription } }
    }

    private func refreshSocial() async {
        error = nil
        do {
            let connection = try ConnectionVault().loadOrCreate()
            try await store.social.refreshFriends(connection: connection)
            for friend in store.social.friends.filter(\.canInteract).prefix(12) {
                try? await store.social.refreshMessages(friend.id, connection: connection)
                if store.family.allows(.sharing) { try? await store.social.refreshCards(friend.id, connection: connection) }
            }
        } catch {
            if let message = socialRefreshErrorMessage(error, taskCancelled: Task.isCancelled) { self.error = message }
        }
    }

    private func act(_ action: String, _ friend: ExplorerFriend) {
        Task { do { try await store.social.action(action, friendID: friend.id, connection: ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } }
    }
}

func socialRefreshErrorMessage(_ error: Error, taskCancelled: Bool) -> String? {
    guard !(error is CancellationError), !taskCancelled else { return nil }
    return error.localizedDescription
}

struct FriendPresenceDot: View {
    let available: Bool
    var body: some View {
        Circle().fill(available ? Color.green : Color.gray).frame(width: 14, height: 14).overlay(Circle().stroke(.white, lineWidth: 2))
            .accessibilityHidden(true)
    }
}

struct FriendPresenceLabel: View {
    let friend: ExplorerFriend
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(friend.available ? Color.green : Color.gray).frame(width: 7, height: 7)
            Text(L10n.text(friend.available ? "Online" : "Offline"))
        }.font(.caption2).foregroundStyle(friend.available ? Theme.forest : Theme.muted)
            .accessibilityElement(children: .combine).accessibilityIdentifier("friend-presence-\(friend.id)")
    }
}
