import SwiftUI

struct PendingCardView: View {
    let store: TripStore
    let discovery: Discovery
    var close: (() -> Void)? = nil
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Eyebrow(text: "A discovery to grow")
                Text("Your discovery is saved").font(.system(.largeTitle, design: .rounded, weight: .bold)).multilineTextAlignment(.center)
                DiscoveryCard(discovery: discovery, store: store, compact: true).frame(maxWidth: 260)
                Text("Come back tomorrow for a little recall question, or try it now. A correct answer unlocks your card.")
                    .font(.body).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                NavigationLink { DiscoveryQuizView(store: store, discoveryID: discovery.id, close: close) } label: {
                    Label("Quiz me now", systemImage: "sparkles")
                }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("pending-quiz")
                Text("Your observation stays safe, whatever your answer.").font(.caption).foregroundStyle(Theme.muted)
            }.padding(26)
        }.background(ExplorerBackdrop()).accessibilityIdentifier("pending-card")
    }
}

struct CardHistoryView: View {
    let card: KnowledgeCard
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Growing knowledge").font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("Every new version keeps the discoveries that came before it.").foregroundStyle(Theme.muted)
                ForEach(card.versions.reversed()) { version in
                    VStack(alignment: .leading, spacing: 12) {
                        Label("V\(version.version)", systemImage: "leaf.fill").font(.headline).foregroundStyle(Theme.forest)
                        Text(version.reply.title).font(.title2.bold())
                        Text(version.question).font(.headline)
                        Text(version.reply.answer)
                        Text(L10n.date(Date(timeIntervalSince1970: version.awardedAt / 1000))).font(.caption).foregroundStyle(Theme.muted)
                    }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 24))
                }
            }.padding(24)
        }.background(ExplorerBackdrop()).navigationTitle("Card history").navigationBarTitleDisplayMode(.inline)
    }
}
