import SwiftUI

struct ExplorerNotificationsView: View {
    let store: TripStore
    @Environment(\.explorerNavigation) private var navigation
    @State private var working = false
    @State private var error: String?

    private var friendRequests: [ExplorerFriend] {
        store.social.friends.filter { $0.state == "incoming" && !$0.blocked }
    }
    private var transfers: [NotificationTransfer] {
        store.social.transfers.flatMap { friendID, values in
            values.filter { !$0.outgoing && ($0.state == "pending" || $0.receivedCardID != nil) }
                .map { NotificationTransfer(friendID: friendID, transfer: $0) }
        }.sorted { $0.transfer.createdAt > $1.transfer.createdAt }
    }
    private var events: [ExplorerEvent] {
        store.events.events.filter { $0.endsAt > Date.now.timeIntervalSince1970 * 1000 }.sorted { $0.startsAt < $1.startsAt }
    }
    private var quizzes: [Discovery] {
        store.state.discoveries.filter { ReminderPolicy.isEligible($0, now: Date()) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill").font(.title).foregroundStyle(Theme.forest)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications").font(.system(.largeTitle, design: .rounded, weight: .black))
                        Text("Requests, gifts and updates.").font(.subheadline).foregroundStyle(Theme.muted)
                    }
                }
                NavigationLink(value: ExplorerRoute.reminders) {
                    Label("Notification settings", systemImage: "gearshape.fill").frame(maxWidth: .infinity, minHeight: 44)
                }.buttonStyle(.bordered).accessibilityIdentifier("notification-settings")
                if isEmpty {
                    ContentUnavailableView("No new updates", systemImage: "bell", description: Text("Friend requests, gifts, events and discovery quizzes will appear here."))
                }
                if !friendRequests.isEmpty {
                    noticeSection("Friend requests") {
                        ForEach(friendRequests) { friend in
                            noticeRow(avatar: friend.avatar, symbol: "person.badge.plus", title: friend.displayName, detail: "Wants to explore together") {
                                HStack {
                                    Button("Decline") { friendship("remove", friend) }.buttonStyle(.bordered)
                                        .accessibilityIdentifier("notification-friend-decline-\(friend.id)")
                                    Button("Accept friendship") { friendship("accept", friend) }.buttonStyle(.borderedProminent)
                                        .accessibilityIdentifier("notification-friend-accept-\(friend.id)")
                                }
                            }.accessibilityIdentifier("notification-friend-\(friend.id)")
                        }
                    }
                }
                if !transfers.isEmpty {
                    noticeSection("Cards and exchanges") {
                        ForEach(transfers) { item in transferRow(item) }
                    }
                }
                if !events.isEmpty {
                    noticeSection("Events near you") {
                        ForEach(events.prefix(3)) { event in
                            Button { navigation?.open(.event(event.id), in: .map) } label: {
                                noticeRow(symbol: "calendar", title: event.title, detail: event.organizer + " · " + L10n.date(Date(timeIntervalSince1970: event.startsAt / 1000), includeTime: true))
                            }.buttonStyle(.plain).accessibilityIdentifier("notification-event-\(event.id)")
                        }
                    }
                }
                if !quizzes.isEmpty {
                    noticeSection("Discovery Quizzes") {
                        ForEach(quizzes) { discovery in
                            Button { navigation?.open(.recall(discovery.id), in: .chat) } label: {
                                noticeRow(symbol: "leaf.arrow.triangle.circlepath", title: discovery.title, detail: discovery.ai?.quiz.question ?? L10n.text("Ready when you are"))
                            }.buttonStyle(.plain).accessibilityIdentifier("notification-quiz-\(discovery.id)")
                        }
                    }
                }
                if working { ProgressView().frame(maxWidth: .infinity) }
                if let error { Text(error).font(.caption).foregroundStyle(Theme.muted).accessibilityIdentifier("notification-error") }
            }.padding(20)
        }
        .background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
        .navigationTitle("Notifications").navigationBarTitleDisplayMode(.inline)
        .task { await refresh() }
    }

    private var isEmpty: Bool { friendRequests.isEmpty && transfers.isEmpty && events.isEmpty && quizzes.isEmpty }

    @ViewBuilder private func noticeSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(.title3, design: .rounded, weight: .bold))
            content()
        }
    }

    private func noticeRow<Actions: View>(avatar: String? = nil, symbol: String, title: String, detail: String, @ViewBuilder actions: () -> Actions) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                if let avatar { ExplorerAvatar(size: 48, avatar: avatar) }
                else { Image(systemName: symbol).font(.title2).foregroundStyle(Theme.forest).frame(width: 48, height: 48).background(Theme.mint, in: Circle()) }
                VStack(alignment: .leading, spacing: 3) { Text(title).font(.headline); Text(detail).font(.caption).foregroundStyle(Theme.muted) }
                Spacer(minLength: 0); Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
            }
            actions()
        }.padding(14).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 22))
    }

    private func noticeRow(avatar: String? = nil, symbol: String, title: String, detail: String) -> some View {
        noticeRow(avatar: avatar, symbol: symbol, title: title, detail: detail) { EmptyView() }
    }

    @ViewBuilder private func transferRow(_ item: NotificationTransfer) -> some View {
        let friend = store.social.friends.first { $0.id == item.friendID }
        let title = item.transfer.kind == "gift" ? item.transfer.offered.title : L10n.text("A card exchange")
        noticeRow(avatar: friend?.avatar, symbol: "gift.fill", title: title,
                  detail: item.transfer.state == "pending" ? L10n.text("Waiting for your answer") : L10n.text("A discovery gift")) {
            if item.transfer.state == "pending" {
                HStack {
                    Button("Decline exchange") { decide("decline", item) }.buttonStyle(.bordered)
                        .accessibilityIdentifier("notification-transfer-decline-\(item.transfer.id)")
                    Button("Accept exchange") { decide("accept", item) }.buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("notification-transfer-accept-\(item.transfer.id)")
                }
            } else if let cardID = item.transfer.receivedCardID,
                      let discovery = store.state.discoveries.first(where: { $0.collectionID == cardID }) {
                Button("View Card") { navigation?.open(.card(discovery.id), in: .map) }.buttonStyle(.bordered)
            }
        }
        .accessibilityIdentifier("notification-transfer-\(item.transfer.id)")
    }

    private func friendship(_ action: String, _ friend: ExplorerFriend) {
        run { try await store.social.action(action, friendID: friend.id, connection: $0) }
    }

    private func decide(_ decision: String, _ item: NotificationTransfer) {
        run { try await store.social.decide(decision, transferID: item.transfer.id, store: store, connection: $0) }
    }

    private func run(_ work: @escaping (ShareConnection) async throws -> Void) {
        guard !working else { return }; working = true; error = nil
        Task { defer { working = false }; do { try await work(ConnectionVault().loadOrCreate()) } catch { self.error = error.localizedDescription } }
    }

    private func refresh() async {
        do {
            let connection = try ConnectionVault().loadOrCreate()
            try await store.social.refreshFriends(connection: connection)
            for friend in store.social.friends.filter(\.canInteract).prefix(12) {
                try? await store.social.refreshTransfers(friend.id, store: store, connection: connection)
            }
        } catch { if !(error is CancellationError) { self.error = error.localizedDescription } }
    }
}

private struct NotificationTransfer: Identifiable {
    let friendID: String
    let transfer: CardTransfer
    var id: String { transfer.id }
}