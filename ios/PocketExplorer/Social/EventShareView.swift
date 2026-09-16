import SwiftUI

struct EventShareView: View {
    let store: TripStore
    let eventID: String
    @Environment(\.explorerNavigation) private var navigation
    @State private var event: ExplorerEvent?
    @State private var selected: String?
    @State private var working = false
    @State private var error: String?
    @State private var visible = false
    private var allowed: Bool { store.family.allows(.social) && store.family.allows(.sharing) }
    private var friends: [ExplorerFriend] { store.social.friends.filter(\.canInteract) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let event { EventRow(event: event) }
                Text("Who would enjoy this adventure?").font(.system(.title2, design: .rounded, weight: .bold))
                if allowed {
                    ForEach(friends) { friend in
                        Button { selected = friend.id } label: {
                            HStack(spacing: 16) {
                                ExplorerAvatar(size: 60, avatar: friend.avatar)
                                Text(friend.displayName).font(.headline); Spacer()
                                Image(systemName: selected == friend.id ? "checkmark.circle.fill" : "circle").font(.title2)
                            }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 24))
                        }.buttonStyle(.plain).disabled(working).accessibilityIdentifier("event-recipient-\(friend.id)")
                    }
                    if friends.isEmpty { Text("Your next adventure could start with a friend.") }
                    Button("Share with friend", action: share).buttonStyle(ExplorerButtonStyle()).disabled(selected == nil || event == nil || working)
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
