import SwiftUI

struct ExplorationConversation: Identifiable {
    let id: UUID
    let records: [ExplorationRecord]
    var title: String { records.first?.reply?.title ?? records.first?.question ?? "" }
    var updatedAt: Date { records.last?.createdAt ?? .distantPast }

    static func groups(_ questions: [ExplorationRecord]) -> [Self] {
        Dictionary(grouping: questions, by: { $0.conversationID ?? $0.id }).map { id, values in
            Self(id: id, records: values.sorted { $0.createdAt < $1.createdAt })
        }.sorted { $0.updatedAt == $1.updatedAt ? $0.id.uuidString < $1.id.uuidString : $0.updatedAt > $1.updatedAt }
    }
}

struct QuestionHistoryView: View {
    let store: TripStore
    var select: (ExplorationRecord) -> Void
    var done: () -> Void
    private var conversations: [ExplorationConversation] { ExplorationConversation.groups(store.questions) }

    var body: some View {
        NavigationStack {
            List {
                if conversations.isEmpty { Text("Your questions will appear here.").foregroundStyle(Theme.muted) }
                ForEach(conversations) { conversation in
                    NavigationLink {
                        conversationView(conversation)
                    } label: {
                        HStack(spacing: 14) {
                            LeafBadge()
                            VStack(alignment: .leading, spacing: 6) {
                                Text(conversation.title).font(.headline)
                                Text("\(conversation.records.count) questions").font(.caption).foregroundStyle(Theme.muted)
                                Text(L10n.date(conversation.updatedAt, includeTime: true)).font(.caption).foregroundStyle(Theme.muted)
                            }
                        }.padding(.vertical, 8)
                    }.accessibilityIdentifier("conversation-\(conversation.id)")
                }
            }.scrollContentBackground(.hidden).background(ExplorerBackdrop())
                .navigationTitle("Your questions").toolbar { Button("Done", action: done) }
        }.tint(Theme.forest)
    }

    private func conversationView(_ conversation: ExplorationConversation) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(conversation.records) { record in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(record.question).font(.headline).padding(16).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.mint, in: RoundedRectangle(cornerRadius: 22))
                        if let reply = record.reply { Text(reply.answer).textSelection(.enabled) }
                        Button { select(record) } label: {
                            Label(L10n.text(record.reply == nil ? "Check answer" : "Continue exploring"), systemImage: "arrow.turn.down.right")
                        }.buttonStyle(.bordered).accessibilityIdentifier("history-question-\(record.id)")
                    }.padding(18).background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 26))
                }
            }.padding(20)
        }.background(ExplorerBackdrop()).navigationTitle(conversation.title).navigationBarTitleDisplayMode(.inline)
    }
}
