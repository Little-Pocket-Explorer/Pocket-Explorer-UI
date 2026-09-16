import SwiftUI

struct GiftComposerView: View {
    let store: TripStore
    let friendID: String
    var wanted: KnowledgeCard?
    @State private var selected = ""
    @State private var working = false
    @State private var error: String?
    @State private var sent = false
    @State private var sentExchange = false
    @Environment(\.dismiss) private var dismiss
    private var pending: TransferDraft? { store.social.pendingTransfer(for: friendID) }
    private var isExchange: Bool { wanted != nil || pending?.kind == "exchange" || sentExchange }
    private var wantedTitle: String? { wanted?.versions.last?.reply.title ?? pending?.wantedTitle }
    private var cards: [KnowledgeCard] {
        var ids: Set<String> = []
        return store.state.discoveries.filter(\.isVerified).compactMap(\.collectible)
            .filter { $0.versions.allSatisfy { $0.audience == "public" } && ids.insert($0.id).inserted }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    LeafBadge(symbol: "gift.fill")
                    Text(L10n.text(isExchange ? "Choose a card to exchange" : "Give a little discovery")).font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(L10n.text(isExchange ? "Both of you keep your original cards and receive a copy." : "You keep your original card. Your friend receives a copy.")).foregroundStyle(Theme.muted)
                    if let wantedTitle { Text("↔ \(wantedTitle)").font(.title2.bold()) }
                    if sent { Label(L10n.text(isExchange ? "Your friend can now review this exchange." : "Your gift is on its way!"), systemImage: "checkmark.circle.fill").accessibilityIdentifier("transfer-sent") }
                    else {
                        if cards.isEmpty { Text("Explore and unlock a card to share with a friend.") }
                        ForEach(cards) { card in
                            Button { selected = card.id } label: {
                                HStack {
                                    Image(systemName: selected == card.id ? "checkmark.circle.fill" : "circle")
                                    Text(card.versions.last!.reply.title).font(.headline); Spacer()
                                }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 22))
                            }.buttonStyle(.plain).disabled(working || store.social.pendingTransfer(for: friendID) != nil).accessibilityIdentifier("gift-select-\(card.id)")
                        }
                        Button(L10n.text(isExchange ? "Offer this exchange" : "Send card copy")) { send() }
                            .buttonStyle(ExplorerButtonStyle()).disabled(selected.isEmpty || working).accessibilityIdentifier("gift-send")
                        if store.social.pendingTransfer(for: friendID) != nil { Text("The last request is saved. Retry it to confirm delivery.").font(.caption) }
                    }
                    if working { ProgressView() }
                    if let error { Text(error).foregroundStyle(Theme.muted).accessibilityIdentifier("social-error") }
                }.padding(24)
            }.background(ExplorerBackdrop()).toolbar { Button("Done") { dismiss() } }
        }.onAppear { selected = store.social.pendingTransfer(for: friendID)?.offeredID ?? cards.first?.id ?? "" }
    }
    private func send() {
        working = true; error = nil; sentExchange = isExchange
        Task {
            defer { working = false }
            do {
                let pending = store.social.pendingTransfer(for: friendID)
                _ = try await store.social.offer(friendID: friendID, offeredID: selected, wantedID: pending?.wantedID ?? wanted?.id, wantedTitle: wantedTitle, connection: ConnectionVault().loadOrCreate()); sent = true
            } catch { self.error = error.localizedDescription }
        }
    }
}

struct FriendCardView: View {
    let store: TripStore
    let friendID: String
    let card: KnowledgeCard
    @State private var bytes: Data?
    @State private var error: String?
    @State private var exchange = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let bytes, let image = UIImage(data: bytes) { Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 28)).accessibilityLabel(card.versions.last!.reply.title) }
                    Text(card.versions.last!.reply.title).font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(card.versions.last!.question).font(.title2)
                    Text(card.versions.last!.reply.answer)
                    Label(L10n.text(card.tier.rawValue.capitalized), systemImage: "sparkles")
                    Button("Request this card") { exchange = true }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("friend-exchange")
                    if let error { Text(error).foregroundStyle(Theme.muted) }
                }.padding(24)
            }.background(ExplorerBackdrop()).toolbar { Button("Done") { dismiss() } }
        }.sheet(isPresented: $exchange) { GiftComposerView(store: store, friendID: friendID, wanted: card) }
            .task {
                do { bytes = try await store.social.client.artwork(card, friendID: friendID, connection: ConnectionVault().loadOrCreate()) }
                catch { self.error = error.localizedDescription }
            }
    }
}
