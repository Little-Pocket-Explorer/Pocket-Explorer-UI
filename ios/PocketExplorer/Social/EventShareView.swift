import SwiftUI

struct EventShareView: View {
    let store: TripStore
    let eventID: String
    @Environment(\.explorerNavigation) private var navigation
    @State private var event: ExplorerEvent?
    @State private var selected: String?
    @State private var query = ""
    @State private var working = false
    @State private var error: String?
    @State private var visible = false
    private var allowed: Bool { store.family.allows(.social) && store.family.allows(.sharing) }
    private var friends: [ExplorerFriend] { store.social.friends.filter(\.canInteract) }
    private var visibleFriends: [ExplorerFriend] {
        let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return search.isEmpty ? friends : friends.filter { $0.displayName.localizedCaseInsensitiveContains(search) }
    }
    private var selectedFriend: ExplorerFriend? { friends.first { $0.id == selected } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let event { EventSharePreview(event: event) }
                Text("Who would enjoy this adventure?").font(.system(.title2, design: .rounded, weight: .bold))
                if allowed {
                    Label {
                        TextField("Search friends", text: $query).textInputAutocapitalization(.never).autocorrectionDisabled()
                            .accessibilityIdentifier("event-friend-search")
                    } icon: { Image(systemName: "magnifyingglass").foregroundStyle(Theme.muted) }
                        .padding(.horizontal, 14).frame(minHeight: 48).background(.white, in: Capsule())
                    ForEach(visibleFriends) { friend in
                        Button { selected = friend.id } label: {
                            HStack(spacing: 16) {
                                ExplorerAvatar(size: 54, avatar: friend.avatar)
                                VStack(alignment: .leading, spacing: 3) { Text(friend.displayName).font(.headline); Text("Friend").font(.caption).foregroundStyle(Theme.muted) }
                                Spacer()
                                Image(systemName: selected == friend.id ? "checkmark.circle.fill" : "circle").font(.title2).foregroundStyle(selected == friend.id ? Theme.forest : Theme.muted)
                            }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain).disabled(working).accessibilityIdentifier("event-recipient-\(friend.id)")
                    }
                    if friends.isEmpty { Text("Your next adventure could start with a friend.") }
                    else if visibleFriends.isEmpty { Text("No friends match your search.").foregroundStyle(Theme.muted) }
                    Button(selectedFriend.map { String(format: L10n.text("Send to %@"), $0.displayName) } ?? L10n.text("Choose a friend"), action: share).buttonStyle(ExplorerButtonStyle()).disabled(selected == nil || event == nil || working)
                        .accessibilityIdentifier("event-share-send")
                } else { Text("A grown-up can turn on friendships in Family settings.") }
                if working { ProgressView() }
                if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("event-share-error"); Button("Try again") { Task { await load() } } }
            }.padding(22)
        }.background(ExplorerBackdrop()).navigationTitle("Share event").navigationBarTitleDisplayMode(.inline)
            .onAppear { visible = true }.onDisappear { visible = false }
            .task { await load() }
    }

    private func load() async {
        error = nil
        do {
            let connection = try ConnectionVault().loadOrCreate()
            event = try await EventClient().read(eventID, language: AppLanguage.current.rawValue, connection: connection)
            try await store.social.refreshFriends(connection: connection)
        } catch { self.error = error.localizedDescription }
    }

    private func share() {
        guard allowed, let event, let selected, friends.contains(where: { $0.id == selected }) else { return }
        working = true; error = nil
        Task {
            defer { working = false }
            do {
                let connection = try ConnectionVault().loadOrCreate()
                _ = try await EventClient().read(event.id, language: AppLanguage.current.rawValue, connection: connection)
                try await store.social.shareEvent(event, friendID: selected, connection: connection)
                if visible && navigation?.current == .eventShare(eventID) { navigation?.open(.friend(selected, 0), in: .social) }
            } catch { self.error = error.localizedDescription }
        }
    }
}
