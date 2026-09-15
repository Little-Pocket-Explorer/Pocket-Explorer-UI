import SwiftUI

struct DiscoveryRemindersView: View {
    let store: TripStore
    @Environment(\.dismiss) private var dismiss
    private var reminders: [Discovery] {
        store.state.discoveries.filter { ReminderPolicy.isEligible($0, now: Date()) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LeafBadge(symbol: "leaf.arrow.triangle.circlepath")
                Text("A little look back").font(.system(.largeTitle, design: .rounded, weight: .black))
                Text("Your past discoveries have a little question for you.").foregroundStyle(Theme.muted)
                ForEach(reminders) { discovery in
                    NavigationLink { DiscoveryQuizView(store: store, discoveryID: discovery.id) } label: {
                        HStack(spacing: 14) {
                            DiscoveryArtwork(discovery: discovery, store: store).frame(width: 70, height: 70).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
                            VStack(alignment: .leading, spacing: 6) {
                                Text(discovery.title).font(.headline)
                                Text(discovery.ai?.quiz.question ?? "").font(.subheadline)
                            }; Spacer(); Image(systemName: "chevron.right")
                        }.padding(15).background(.white, in: RoundedRectangle(cornerRadius: 23))
                    }.buttonStyle(.plain)
                }
                if reminders.isEmpty {
                    Text("Nothing to catch up on. Come back after your next discovery.").padding(22).background(Theme.mint, in: RoundedRectangle(cornerRadius: 24))
                }
                ForEach(store.state.trips.filter { ReminderPolicy.isEligible($0, now: Date()) }) { trip in
                    NavigationLink { MemoryPlayer(trip: trip, store: store) } label: {
                        TripRow(trip: trip, discoveries: store.discoveries(in: trip.id), store: store)
                    }.buttonStyle(.plain)
                }
            }.padding(24)
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).toolbar { Button("Done") { dismiss() } }
    }
}

struct DiscoveryQuizView: View {
    let store: TripStore
    let discoveryID: UUID
    @State private var choice: Int?
    @State private var checked = false
    @State private var error: String?
    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }
    var body: some View {
        ScrollView {
            if let discovery, let quiz = discovery.ai?.quiz {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 14) {
                        DiscoveryArtwork(discovery: discovery, store: store).frame(width: 82, height: 82).clipped().clipShape(RoundedRectangle(cornerRadius: 18))
                        VStack(alignment: .leading, spacing: 6) { Eyebrow(text: "From your discoveries"); Text(discovery.title).font(.headline) }
                    }.padding(16).background(Theme.paper, in: RoundedRectangle(cornerRadius: 24))
                    Text(quiz.question).font(.system(.title, design: .rounded, weight: .heavy))
                    Text("Choose what you remember.").foregroundStyle(Theme.muted)
                    ForEach(quiz.choices.indices, id: \.self) { index in
                        Button { choice = index } label: {
                            HStack {
                                Image(systemName: choice == index ? "checkmark.circle.fill" : "circle").font(.title2)
                                Text(quiz.choices[index]).font(.system(.body, design: .rounded, weight: .medium))
                                Spacer()
                            }.padding(18).frame(maxWidth: .infinity, minHeight: 60)
                                .background(choice == index ? Theme.mint : .white, in: RoundedRectangle(cornerRadius: 22))
                        }.buttonStyle(.plain).disabled(checked).accessibilityIdentifier("quiz-choice-\(index)")
                    }
                    if checked {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.text(choice == quiz.correctIndex ? "You remembered!" : "A new little thing to remember.")).font(.title3.bold())
                            Text(quiz.explanation)
                            Text("Your card is yours to keep.").font(.caption).foregroundStyle(Theme.muted)
                        }.padding(20).background(Theme.mint, in: RoundedRectangle(cornerRadius: 24)).accessibilityIdentifier("quiz-feedback")
                        NavigationLink { CardDetailView(store: store, discoveryID: discovery.id) } label: { Text("View my card") }.buttonStyle(ExplorerButtonStyle())
                    } else {
                        Button("Check answer") {
                            guard let choice else { return }
                            do { try store.answerQuiz(discoveryID: discoveryID, choice: choice); checked = true }
                            catch { self.error = error.localizedDescription }
                        }.buttonStyle(ExplorerButtonStyle()).disabled(choice == nil).accessibilityIdentifier("quiz-check")
                    }
                    if let error { Text(error) }
                }.padding(24)
            }
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).navigationTitle("Discovery Quiz").navigationBarTitleDisplayMode(.inline)
    }
}
