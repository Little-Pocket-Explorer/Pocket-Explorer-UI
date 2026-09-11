import SwiftUI

struct SharePreviewView: View {
    let trip: Trip
    let discoveries: [Discovery]
    @Environment(\.dismiss) private var dismiss
    @State private var includeName = false
    @State private var firstName = ""
    @State private var includeCity = false
    @State private var published: PublishedShare?
    @State private var busy = false
    @State private var error: String?
    @State private var message: String?
    private var story: PublicStory { published?.story ?? PublicStory.make(trip: trip, discoveries: discoveries, firstName: includeName ? firstName : nil, includeCity: includeCity) }
    private var receiptKey: String { "share-receipt-\(trip.id)" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Eyebrow(text: "Your adventure, ready to share")
                    Text("A little adventure.\nA lovely thing to share.").font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    Text("Preview the words everyone with your link will see. Photos and exact locations stay on this iPhone.").foregroundStyle(Theme.muted)
                    if published == nil {
                        VStack(alignment: .leading, spacing: 14) {
                            Toggle("Include a first name", isOn: $includeName)
                            if includeName { TextField("First name", text: $firstName).textContentType(.givenName).padding(12).background(Theme.paper, in: RoundedRectangle(cornerRadius: 12)) }
                            Toggle("Include the city", isOn: $includeCity).disabled(trip.place == nil)
                        }.padding(20).background(Theme.surface, in: RoundedRectangle(cornerRadius: 22)).disabled(busy)
                    }
                    VStack(alignment: .leading, spacing: 18) {
                        Eyebrow(text: published == nil ? "Your public story preview" : "Shared snapshot")
                        Text(story.title).font(.system(.title2, design: .rounded, weight: .bold))
                        if let name = story.firstName { Text("Explored by \(name)") }
                        if let city = story.city { Text(city) }
                        ForEach(story.cards) { card in
                            VStack(alignment: .leading, spacing: 10) {
                                Image(card.subject.rawValue).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 20))
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
            .safeAreaInset(edge: .bottom) { shareActions }
            .task {
                if let data = ShareStorageScope.preferences.data(forKey: receiptKey) { published = try? JSONDecoder().decode(PublishedShare.self, from: data) }
            }
        }
    }
    private var shareActions: some View {
        VStack(spacing: 10) {
            if let error { Text(error).font(.callout).foregroundStyle(Theme.ink).accessibilityIdentifier("share-error") }
            if let message { Text(L10n.text(message)).font(.footnote).accessibilityIdentifier("share-message") }
            if let published {
                Text(published.receipt.url.absoluteString).font(.caption2).lineLimit(1).textSelection(.enabled).accessibilityIdentifier("share-url")
                ShareLink(item: published.receipt.url) { Label("Share my adventure", systemImage: "square.and.arrow.up") }.buttonStyle(ExplorerButtonStyle())
                HStack {
                    Button("Copy link") { UIPasteboard.general.url = published.receipt.url; message = "Link copied." }.frame(maxWidth: .infinity, minHeight: 44)
                    Button("Stop sharing this story", action: revoke).frame(maxWidth: .infinity, minHeight: 44)
                }.font(.footnote).disabled(busy)
            } else {
                Button(L10n.text(busy ? "Creating your link…" : "Create a sharing link"), action: create)
                    .buttonStyle(ExplorerButtonStyle()).disabled(busy || story.cards.isEmpty).accessibilityIdentifier("create-share")
            }
        }.padding(.horizontal, 24).padding(.vertical, 12).background(Theme.paper)
    }
    private func create() {
        busy = true; error = nil; message = nil
        let snapshot = story
        Task {
            defer { busy = false }
            do {
                let connection = try ConnectionVault().loadOrCreate()
                let result = try await ShareClient().create(snapshot, connection: connection)
                let saved = PublishedShare(receipt: result, story: snapshot)
                let encoded = try JSONEncoder().encode(saved)
                ShareStorageScope.preferences.set(encoded, forKey: receiptKey)
                guard ShareStorageScope.preferences.data(forKey: receiptKey) == encoded else { throw ShareError.unavailable }
                published = saved
                message = "Your story is ready. Anyone with the link can open it."
            } catch { self.error = error.localizedDescription }
        }
    }
    private func revoke() {
        guard let published else { return }
        busy = true; error = nil; message = nil
        Task {
            defer { busy = false }
            do {
                guard let connection = try ConnectionVault().read() else { throw ShareError.configuration }
                try await ShareClient().revoke(published.receipt, connection: connection)
                ShareStorageScope.preferences.removeObject(forKey: receiptKey)
                self.published = nil; message = "This link is no longer shared."
            } catch { self.error = error.localizedDescription }
        }
    }
}
