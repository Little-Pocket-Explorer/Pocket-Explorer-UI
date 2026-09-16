import SwiftUI

struct DiscoveryRemindersView: View {
    let store: TripStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.explorerNavigation) private var navigation
    @State private var notifications = RecallNotifications.shared
    @State private var requested = false
    private var reminders: [Discovery] {
        store.state.discoveries.filter { ReminderPolicy.isEligible($0, now: Date()) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LeafBadge(symbol: "leaf.arrow.triangle.circlepath")
                Text("A little look back").font(.system(.largeTitle, design: .rounded, weight: .black))
                Text("Your past discoveries have a little question for you.").foregroundStyle(Theme.muted)
                VStack(alignment: .leading, spacing: 12) {
                    Text("A gentle reminder, when you want one.").font(.headline)
                    Text("At most one afternoon reminder a day. No reminders while you explore.").font(.caption).foregroundStyle(Theme.muted)
                    Button(L10n.text(notifications.requesting ? "Cancel" : notifications.enabled ? "Turn off reminders" : "Turn on reminders")) {
                        let enable = !notifications.requesting && !notifications.enabled
                        Task { await notifications.setEnabled(enable); requested = true }
                    }.frame(minHeight: 44).accessibilityIdentifier("recall-notifications")
                    if (requested || notifications.enabled) && !notifications.allowed { Text("You can allow reminders in iPhone Settings.").font(.caption) }
                    if let error = notifications.error { Text(error).font(.caption) }
                }.padding(18).background(.white, in: RoundedRectangle(cornerRadius: 24))
                if store.demo.enabled, let discovery = store.state.discoveries.first(where: { $0.ai != nil && $0.isVerified }) {
                    Button("Preview recall in Chat") { navigation?.open(.recall(discovery.id), in: .chat) }
                        .accessibilityIdentifier("demo-recall-preview").frame(minHeight: 44)
                }
                ForEach(reminders) { discovery in
                    Button { navigation?.open(.recall(discovery.id), in: .chat) } label: {
                        HStack(spacing: 14) {
                            DiscoveryArtwork(discovery: discovery, store: store).frame(width: 70, height: 70).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
                            VStack(alignment: .leading, spacing: 6) {
                                Text(discovery.title).font(.headline)
                                Text(discovery.ai?.quiz.question ?? "").font(.subheadline)
                            }; Spacer(); Image(systemName: "chevron.right")
                        }.padding(15).background(.white, in: RoundedRectangle(cornerRadius: 23))
                    }.buttonStyle(.plain).accessibilityIdentifier("recall-open-\(discovery.id)")
                }
                if reminders.isEmpty {
                    Text("Nothing to catch up on. Come back after your next discovery.").padding(22).background(Theme.mint, in: RoundedRectangle(cornerRadius: 24))
                }
                ForEach(store.state.trips.filter { ReminderPolicy.isEligible($0, now: Date()) }) { trip in
                    NavigationLink(value: ExplorerRoute.memory(trip.id)) {
                        TripRow(trip: trip, discoveries: store.discoveries(in: trip.id), store: store)
                    }.buttonStyle(.plain)
                }
            }.padding(24)
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).toolbar { Button("Done") { if let navigation { navigation.back() } else { dismiss() } } }
    }
}

struct DiscoveryQuizView: View {
    let store: TripStore
    let discoveryID: UUID
    var close: (() -> Void)? = nil
    var showContext = false
    @Environment(\.explorerNavigation) private var navigation
    @State private var choice: Int?
    @State private var checked = false
    @State private var error: String?
    @State private var reveal = false
    @State private var revealed = false
    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }
    var body: some View {
        ScrollView {
            if let discovery, let quiz = discovery.ai?.quiz {
                VStack(alignment: .leading, spacing: 22) {
                    if showContext {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(discovery.question).accessibilityIdentifier("recall-original-question").font(.headline).padding(16).frame(maxWidth: .infinity, alignment: .trailing)
                                .background(Theme.mint, in: RoundedRectangle(cornerRadius: 22))
                            DisclosureGroup("Our earlier discovery") { Text(discovery.explanation).padding(.top, 8).textSelection(.enabled) }
                        }
                    }
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
                            Text(L10n.text(discovery.isUnlocked ? "Your card is yours to keep." : "Your observation is safe. Try the question again.")).font(.caption).foregroundStyle(Theme.muted)
                        }.padding(20).background(Theme.mint, in: RoundedRectangle(cornerRadius: 24)).accessibilityIdentifier("quiz-feedback")
                        if discovery.isUnlocked {
                            if showContext {
                                Button("View my card") { navigation?.open(.card(discoveryID)) }.buttonStyle(ExplorerButtonStyle())
                                Button("Keep exploring this idea.") {
                                    navigation?.open(.explore(.init(parentID: store.questions.first(where: { $0.id == discovery.explorationID })?.id)), in: .chat)
                                }.frame(minHeight: 44).accessibilityIdentifier("recall-continue")
                            } else if discovery.unlockRequired == true {
                                Button("Reveal my card") { reveal = true }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("quiz-reveal")
                                if !discovery.isVerified { Text("Your answer is saved. We will sync your card when you are online.").font(.caption).foregroundStyle(Theme.muted) }
                            } else {
                                NavigationLink("View my card", value: ExplorerRoute.card(discovery.id)).buttonStyle(ExplorerButtonStyle())
                            }
                        } else {
                            if choice == quiz.correctIndex && discovery.evolvesFrom != nil { Text(CollectibleError.newDiscovery.localizedDescription).font(.subheadline) }
                            Button("Try the question again") { checked = false; choice = nil }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("quiz-retry")
                        }
                    } else {
                        Button("Check answer") {
                            guard let choice else { return }
                            do {
                                try store.answerQuiz(discoveryID: discoveryID, choice: choice); checked = true
                                Task { if let connection = try? ConnectionVault().loadOrCreate() { await store.recall.synchronize(store: store, connection: connection) } }
                            }
                            catch { self.error = error.localizedDescription }
                        }.buttonStyle(ExplorerButtonStyle()).disabled(choice == nil).accessibilityIdentifier("quiz-check")
                    }
                    if let error { Text(error) }
                }.padding(24)
            } else {
                ContentUnavailableView("Nothing to catch up on. Come back after your next discovery.", systemImage: "leaf")
            }
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).navigationTitle("Discovery Quiz").navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $reveal) {
                if let discovery {
                    if revealed { NewCardView(store: store, discoveryID: discoveryID, close: close) }
                    else { CardUnlockView(discovery: discovery, onReveal: { revealed = true }, store: store) }
                }
            }
            .toolbar {
                if let close { ToolbarItem(placement: .topBarTrailing) { Button("Done", action: close).accessibilityIdentifier("exploration-close") } }
            }
    }
}
