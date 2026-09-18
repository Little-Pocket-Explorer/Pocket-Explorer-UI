import SwiftUI

struct CardShareOptionsView: View {
    let store: TripStore
    let discovery: Discovery
    let trip: Trip
    var onMap: () -> Void
    var onFriendSent: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var choosingFriend = false
    @State private var selectedFriendID: String?
    @State private var working = false
    @State private var message: String?
    @State private var error: String?

    private var friendsAllowed: Bool {
        store.family.family != nil && store.family.allows(.sharing) && store.family.allows(.social)
    }
    private var sharingAllowed: Bool { store.family.allows(.sharing) }
    private var friends: [ExplorerFriend] { store.social.friends.filter(\.canInteract) }
    private var cardID: String? {
        guard discovery.isVerified, let card = discovery.collectible,
              card.versions.allSatisfy({ $0.audience == "public" }) else { return nil }
        return card.id
    }
    private var receiptKey: String { "share-receipt-\(trip.id)-card-\(discovery.id)" }

    var body: some View {
        NavigationStack {
            Group {
                if choosingFriend { friendPicker }
                else { options }
            }
            .background(Theme.paper)
            .navigationTitle(choosingFriend ? "Share to friend" : "Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if choosingFriend { Button("Back") { choosingFriend = false; selectedFriendID = nil; error = nil } }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark").frame(minWidth: 44, minHeight: 44) }
                        .accessibilityLabel("Close").accessibilityIdentifier("card-share-close")
                }
            }
        }
        .tint(Theme.forest)
        .task(id: friendsAllowed) {
            guard friendsAllowed else { return }
            do { try await store.social.refreshFriends(connection: ConnectionVault().loadOrCreate()) }
            catch { self.error = error.localizedDescription }
        }
    }

    private var options: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share").font(.caption).foregroundStyle(Theme.muted)
                    Text(discovery.title).font(.system(.title2, design: .rounded, weight: .bold))
                }
                cardPreview
                if let message { Text(message).font(.caption).foregroundStyle(Theme.forest).accessibilityIdentifier("card-share-message") }
                if let error { Text(error).font(.caption).foregroundStyle(Theme.muted).accessibilityIdentifier("card-share-error") }
                Button {
                    choosingFriend = true
                } label: {
                    shareRow("Share to friend", detail: "Send privately in Messages", symbol: "person.2.fill")
                }
                .buttonStyle(.plain).disabled(!friendsAllowed || cardID == nil)
                .accessibilityIdentifier("card-share-friend")
                if !friendsAllowed {
                    Text("A grown-up can turn on friends and text chat in Family settings.").font(.caption).foregroundStyle(Theme.muted)
                }
                Button {
                    dismiss()
                    onMap()
                } label: {
                    shareRow("Share on map", detail: "Public with approximate location", symbol: "map.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("card-share-map")
                Button(action: copyLink) {
                    shareRow("Copy link", detail: "Share outside Pocket Explorer", symbol: "link")
                }
                .buttonStyle(.plain).disabled(!sharingAllowed || working)
                .accessibilityIdentifier("card-share-copy")
                if working { ProgressView("Creating your link…").frame(maxWidth: .infinity) }
                if !sharingAllowed {
                    Text("A grown-up can turn on sharing in Family settings.").font(.callout).foregroundStyle(Theme.muted)
                }
            }.padding(20)
        }
    }

    private var friendPicker: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                cardPreview
                Text("Who would enjoy this discovery?").font(.system(.title2, design: .rounded, weight: .bold))
                if friends.isEmpty {
                    Text("Add a trusted explorer in Social before sharing this card.").foregroundStyle(Theme.muted)
                }
                ForEach(friends) { friend in
                    Button { selectedFriendID = friend.id } label: {
                        HStack(spacing: 14) {
                            ExplorerAvatar(size: 52, avatar: friend.avatar)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(friend.displayName).font(.headline)
                                Text("Family friend").font(.caption).foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Image(systemName: selectedFriendID == friend.id ? "checkmark.circle.fill" : "circle")
                                .font(.title2).foregroundStyle(selectedFriendID == friend.id ? Theme.forest : Theme.muted)
                        }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).disabled(working).accessibilityIdentifier("card-share-recipient-\(friend.id)")
                }
                Button(selectedFriendID.flatMap { id in friends.first(where: { $0.id == id })?.displayName }
                    .map { String(format: L10n.text("Send to %@"), $0) } ?? L10n.text("Choose a friend"), action: sendToFriend)
                    .buttonStyle(ExplorerButtonStyle()).disabled(selectedFriendID == nil || working || cardID == nil)
                    .accessibilityIdentifier("card-share-send")
                if working { ProgressView().frame(maxWidth: .infinity) }
                if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("card-share-error") }
            }.padding(20)
        }
    }

    private var cardPreview: some View {
        HStack(spacing: 14) {
            DiscoveryArtwork(discovery: discovery, store: store).frame(width: 72, height: 72).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(discovery.title + " · V\(discovery.collectible?.versions.last?.version ?? 1)").font(.headline).lineLimit(2)
                Text("Choose where to share").font(.caption).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 0)
        }.padding(14).background(Theme.mint.opacity(0.45), in: RoundedRectangle(cornerRadius: 20))
            .accessibilityIdentifier("card-share-preview")
    }

    private func shareRow(_ title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).font(.title2).foregroundStyle(Theme.forest).frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.text(title)).font(.headline)
                Text(L10n.text(detail)).font(.caption).foregroundStyle(Theme.muted)
            }
            Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
        }.padding(.vertical, 8).contentShape(Rectangle())
    }

    private func sendToFriend() {
        guard friendsAllowed, let cardID, let friendID = selectedFriendID else { return }
        working = true; error = nil
        Task {
            defer { working = false }
            do {
                let connection = try ConnectionVault().loadOrCreate()
                let card = SharedCardMessage(cardID: cardID, title: discovery.title)
                guard SharedCardMessage(text: card.text) == card else { throw SocialError.invalidResponse }
                try await store.social.shareCard(card, friendID: friendID, connection: connection)
                onFriendSent(friendID)
                dismiss()
            } catch { self.error = error.localizedDescription }
        }
    }

    private func copyLink() {
        guard sharingAllowed else { return }
        working = true; error = nil; message = nil
        Task {
            defer { working = false }
            do {
                let published = try await publishedShare()
                UIPasteboard.general.url = published.receipt.url
                message = L10n.text("Link copied.")
            } catch { self.error = error.localizedDescription }
        }
    }

    private func publishedShare() async throws -> PublishedShare {
        if let saved = SharePublisher.shared.saved(for: receiptKey) { return saved }
        let story = PublicStory.make(trip: trip, discoveries: [discovery], firstName: nil, includeCity: false)
        return try await SharePublisher.shared.publish(story, key: receiptKey, prepare: {
            try await PreparedRegistration.shared.prepareShare(story, store: store, connection: ConnectionVault().loadOrCreate())
        }).task.value
    }
}