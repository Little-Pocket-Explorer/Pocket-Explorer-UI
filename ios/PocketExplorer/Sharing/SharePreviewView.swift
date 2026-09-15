import SwiftUI

struct SharePreviewView: View {
    let trip: Trip
    let discoveries: [Discovery]
    var store: TripStore?
    var singleCardID: UUID?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var includeName = false
    @State private var firstName = ""
    @State private var includeCity = false
    @State private var published: PublishedShare?
    @State private var pendingStory: PublicStory?
    @State private var busy = false
    @State private var error: String?
    @State private var message: String?
    private var story: PublicStory { published?.story ?? pendingStory ?? PublicStory.make(trip: trip, discoveries: discoveries, firstName: includeName ? firstName : nil, includeCity: includeCity) }
    private var receiptKey: String { "share-receipt-\(trip.id)" + (singleCardID.map { "-card-\($0)" } ?? "") }

    private var inlineActions: Bool { textSize.isAccessibilitySize && published != nil }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Eyebrow(text: "Your adventure, ready to share").id("share-introduction")
                        Text("A little adventure.\nA lovely thing to share.").font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        Text("Preview the words everyone with your link will see. Field photos and exact locations are not included in the link.").foregroundStyle(Theme.muted)
                        if published == nil && pendingStory == nil {
                            VStack(alignment: .leading, spacing: 14) {
                                Toggle("Include a first name", isOn: $includeName).accessibilityIdentifier("share-include-name")
                                if includeName { TextField("First name", text: $firstName).textContentType(.givenName).padding(12).background(Theme.paper, in: RoundedRectangle(cornerRadius: 12)) }
                                Toggle("Include the city", isOn: $includeCity).disabled(trip.place == nil).accessibilityIdentifier("share-include-city")
                            }.padding(20).background(Theme.surface, in: RoundedRectangle(cornerRadius: 22)).disabled(busy)
                        }
                        if inlineActions { shareActions.id("share-actions") }
                        VStack(alignment: .leading, spacing: 18) {
                            Eyebrow(text: published == nil ? "Your public story preview" : "Shared snapshot")
                            Text(story.title).font(.system(.title2, design: .rounded, weight: .bold))
                            if let name = story.firstName { Text("Explored by \(name)") }
                            if let city = story.city { Text(city) }
                            ForEach(story.cards) { card in
                                VStack(alignment: .leading, spacing: 10) {
                                    publicArtwork(card).aspectRatio(1, contentMode: .fit).clipped().clipShape(RoundedRectangle(cornerRadius: 20))
                                    Text(card.title).font(.system(.headline, design: .rounded))
                                    Text(card.question).font(.subheadline)
                                    Text(card.observation).font(.system(.body, design: .rounded, weight: .bold))
                                    Text(card.explanation).font(.subheadline).foregroundStyle(Theme.muted)
                                }
                            }
                            Text("The memory plays these questions, observations and discoveries in the order shown.").font(.footnote).foregroundStyle(Theme.muted)
                        }.padding(20).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 25))
                    }.padding(26)
                }
                .background(Theme.paper).foregroundStyle(Theme.ink)
                .navigationTitle("Share a little wonder").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
                .safeAreaInset(edge: .bottom) { if !inlineActions { shareActions } }
                .onChange(of: published?.receipt.token) { _, _ in
                    if textSize.isAccessibilitySize { proxy.scrollTo(inlineActions ? "share-actions" : "share-introduction", anchor: .top) }
                }
                .onChange(of: busy) { _, busy in
                    if busy && inlineActions { proxy.scrollTo("share-actions", anchor: .top) }
                }
                .task {
                    if let saved = SharePublisher.shared.saved(for: receiptKey) {
                        published = saved
                        if let pending = SharePublisher.shared.pendingRevocation(for: receiptKey) { await finishRevocation(pending) }
                    }
                    else if let pending = SharePublisher.shared.pending(for: receiptKey) {
                        await receive(pending)
                    }
                }
            }
        }
    }

    @ViewBuilder private func publicArtwork(_ card: PublicCard) -> some View {
        if let artworkID = card.artworkID,
           let discovery = discoveries.first(where: { $0.artwork?.id == artworkID }),
           discovery.artworkFilename != nil, store != nil {
            DiscoveryArtwork(discovery: discovery, store: store)
        } else if let artworkID = card.artworkID, let published {
            AsyncImage(url: published.receipt.url.deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("api/shares/\(published.receipt.token)/artwork/\(artworkID)")) { image in
                    image.resizable().scaledToFill()
                } placeholder: { Image("keepsake").resizable().scaledToFit() }
        } else {
            Image(card.subject == .discovery ? "keepsake" : card.subject.rawValue).resizable().scaledToFit()
        }
    }
    private var shareActions: some View {
        VStack(spacing: 10) {
            if let error { Text(error).font(.callout).foregroundStyle(Theme.ink).accessibilityIdentifier("share-error") }
            if let message { Text(L10n.text(message)).font(.footnote).accessibilityIdentifier("share-message") }
            if let published {
                if busy {
                    HStack { ProgressView(); Text("Stopping sharing…") }.font(.footnote).accessibilityIdentifier("revoking-share")
                }
                Text(published.receipt.url.absoluteString).font(.caption2).lineLimit(1).textSelection(.enabled).accessibilityIdentifier("share-url")
                ShareLink(item: published.receipt.url) { Label("Share my adventure", systemImage: "square.and.arrow.up") }.buttonStyle(ExplorerButtonStyle()).disabled(busy)
                (inlineActions ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout())) {
                    Button("Copy link") { UIPasteboard.general.url = published.receipt.url; message = "Link copied." }.frame(maxWidth: .infinity, minHeight: 44)
                    Button("Stop sharing this story", action: revoke).frame(maxWidth: .infinity, minHeight: 44).accessibilityIdentifier("revoke-share")
                }.font(.footnote).disabled(busy)
            } else {
                Button(L10n.text(busy ? "Creating your link…" : "Create a sharing link"), action: create)
                    .buttonStyle(ExplorerButtonStyle()).disabled(busy || story.cards.isEmpty).accessibilityIdentifier("create-share")
            }
        }.padding(.horizontal, inlineActions ? 0 : 24).padding(.vertical, 12).background(Theme.paper)
    }
    private func create() {
        busy = true; error = nil; message = nil
        let request = SharePublisher.shared.publish(story, key: receiptKey)
        Task { await receive(request) }
    }
    private func receive(_ request: SharePublisher.Publication) async {
        busy = true; pendingStory = request.story
        defer { busy = false; pendingStory = nil }
        do {
            let result = try await request.task.value
            guard !Task.isCancelled else { return }
            published = result
            message = "Your story is ready. Anyone with the link can open it."
        } catch { if !Task.isCancelled { self.error = error.localizedDescription } }
    }
    private func revoke() {
        guard let published else { return }
        busy = true; error = nil; message = nil
        let request = SharePublisher.shared.revoke(published, key: receiptKey)
        Task { await finishRevocation(request) }
    }
    private func finishRevocation(_ request: Task<Void, Error>) async {
        busy = true
        defer { busy = false }
        do {
            try await request.value
            guard !Task.isCancelled else { return }
            published = nil; message = "This link is no longer shared."
        } catch { if !Task.isCancelled { self.error = error.localizedDescription } }
    }
}
