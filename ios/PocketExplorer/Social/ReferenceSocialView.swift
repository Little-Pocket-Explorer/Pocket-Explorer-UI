import SwiftUI

struct SocialView: View {
    let store: TripStore
    @State private var tab = 0
    @State private var code = ""
    @State private var settings = false
    @State private var adding = false
    @State private var working = false
    @State private var error: String?
    private var allowed: Bool { store.family.family != nil && store.family.allows(.social) }

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
                do { try await store.social.refreshFriends(connection: ConnectionVault().loadOrCreate()) }
                catch { self.error = error.localizedDescription }
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
                            VStack(spacing: 6) { ExplorerAvatar(size: 60, avatar: friend.avatar); Text(friend.displayName).font(.caption).lineLimit(1) }
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
                } else {
                    NavigationLink(value: ExplorerRoute.friendProfile(friend.id)) { activityRow(friend) }.buttonStyle(.plain)
                }
            }
            if store.social.friends.isEmpty { Text("Curiosity is better together. Add a trusted explorer to share discoveries.").padding(16).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20)) }
            Button("Refresh friends") { refresh() }.accessibilityIdentifier("friends-refresh")
        }
    }

    private var messages: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Search messages", systemImage: "magnifyingglass").padding(12).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.94), in: Capsule())
            ForEach(store.social.friends) { friend in
                NavigationLink(value: ExplorerRoute.friend(friend.id, 0)) { activityRow(friend) }.buttonStyle(.plain)
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
        HStack(spacing: 12) { ExplorerAvatar(size: 46, avatar: friend.avatar); VStack(alignment: .leading, spacing: 3) { Text(friend.displayName).font(.headline); Text(friend.state == "outgoing" ? L10n.text("Waiting for your friend") : store.social.messages[friend.id]?.last?.text ?? L10n.text("Ready for an adventure")).font(.caption).foregroundStyle(Theme.muted).lineLimit(1) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }
            .padding(12).background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
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

    private func refresh() {
        Task { do { try await store.social.refreshFriends(connection: ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } }
    }

    private func act(_ action: String, _ friend: ExplorerFriend) {
        Task { do { try await store.social.action(action, friendID: friend.id, connection: ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } }
    }
}
