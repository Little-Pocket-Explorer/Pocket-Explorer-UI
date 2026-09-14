import SwiftUI

struct ChatHomeView: View {
    let store: TripStore
    var changeLanguage: () -> Void
    @State private var question = ""
    @State private var selectedQuestion: ExplorationRecord?
    @State private var exploring = false
    @State private var history = false
    @State private var profile = false
    @State private var pendingQuestion: ExplorationRecord?
    @State private var pendingLanguage = false
    @AppStorage("explorer-age") private var age = 7

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Button { history = true } label: { Image(systemName: "sidebar.left").font(.title3).frame(width: 44, height: 44).background(.white.opacity(0.85), in: Circle()) }
                        .accessibilityLabel("Question history").accessibilityIdentifier("question-history")
                    Image(systemName: "leaf.fill").font(.title2).foregroundStyle(Theme.forest)
                    Text("Pocket Explorer").font(.system(.title3, design: .rounded, weight: .black)).minimumScaleFactor(0.65).lineLimit(1)
                    Spacer(minLength: 0)
                    Button { profile = true } label: { ExplorerAvatar().frame(width: 44, height: 44) }.accessibilityLabel("My profile").accessibilityIdentifier("open-profile")
                }.padding(.horizontal, 18).padding(.top, 8)
                if store.state.discoveries.contains(where: { ReminderPolicy.isEligible($0, now: Date()) }) {
                    NavigationLink { DiscoveryRemindersView(store: store) } label: {
                        HStack { LeafBadge(symbol: "leaf.arrow.triangle.circlepath"); Text("A little look back").font(.subheadline.bold()); Spacer(); Image(systemName: "chevron.right") }
                            .padding(12).background(.white, in: Capsule())
                    }.padding(.horizontal, 18).padding(.top, 12).accessibilityIdentifier("home-reminders")
                }
                Image("explorer-hero").resizable().scaledToFit().accessibilityHidden(true)
                VStack(spacing: 10) {
                    Text("What are you curious\nabout today?").font(.system(.largeTitle, design: .rounded, weight: .black))
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    Text("Ask about anything you notice.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                }.padding(.horizontal, 20).padding(.bottom, 22)
                VStack(spacing: 10) {
                    suggestion("Why is the sky blue?", symbol: "cloud", color: Color(hex: 0x43B4ED))
                    suggestion("What kind of leaf is this?", symbol: "leaf.fill", color: Theme.forest)
                    suggestion("How do bees find flowers?", symbol: "ladybug.fill", color: Color(hex: 0xD4A229))
                }.padding(.horizontal, 24)
            }.padding(.bottom, 24)
        }
        .background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button { exploring = true } label: { Image(systemName: "camera").foregroundStyle(Theme.forest).frame(width: 44, height: 44) }
                    .accessibilityLabel("Explore with a photo")
                TextField("Ask anything…", text: $question).submitLabel(.send).onSubmit { exploring = true }
                    .accessibilityIdentifier("home-question")
                Button { exploring = true } label: { LeafBadge(symbol: question.isEmpty ? "mic.fill" : "arrow.up").frame(width: 44, height: 44) }
                    .accessibilityLabel("Ask your guide").accessibilityIdentifier("home-ask")
            }.padding(12).background(.white, in: Capsule()).shadow(color: Theme.ink.opacity(0.07), radius: 12, y: 4)
                .padding(.horizontal, 16).padding(.bottom, 6).background(Theme.paper.opacity(0.8))
        }
        .sheet(isPresented: $exploring) { ExplorationFlow(store: store, tripID: nil, initialQuestion: question) }
        .sheet(item: $selectedQuestion) { record in ExplorationFlow(store: store, tripID: nil, recordID: record.id) }
        .sheet(isPresented: $history, onDismiss: { selectedQuestion = pendingQuestion; pendingQuestion = nil }) {
            NavigationStack {
                List {
                    if store.questions.isEmpty { Text("Your questions will appear here.").foregroundStyle(Theme.muted) }
                    ForEach(store.questions) { record in
                        Button { pendingQuestion = record; history = false } label: {
                            HStack { LeafBadge(); VStack(alignment: .leading, spacing: 4) {
                                Text(record.reply?.title ?? record.question).font(.headline)
                                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(Theme.muted)
                            }; Spacer(); Image(systemName: "chevron.right") }
                        }.buttonStyle(.plain)
                    }
                }.navigationTitle("Your questions").toolbar { Button("Done") { history = false } }
            }.tint(Theme.forest)
        }
        .sheet(isPresented: $profile, onDismiss: { if pendingLanguage { pendingLanguage = false; changeLanguage() } }) {
            NavigationStack {
                Form {
                    Section {
                        HStack { Spacer(); ExplorerAvatar(size: 100); Spacer() }.listRowBackground(Color.clear)
                        Stepper("Age: \(age)", value: $age, in: 5...18)
                        Text("Your guide adjusts explanations to your age.").font(.caption).foregroundStyle(Theme.muted)
                    }
                    Section {
                        Button("语言 / Language") { pendingLanguage = true; profile = false }.accessibilityIdentifier("choose-language")
                        LabeledContent("Discoveries", value: "\(store.state.discoveries.count)")
                        LabeledContent("Questions", value: "\(store.questions.count)")
                    }
                }.navigationTitle("My profile").toolbar { Button("Done") { profile = false } }
            }.tint(Theme.forest)
        }
    }

    private func suggestion(_ title: String, symbol: String, color: Color) -> some View {
        Button { question = L10n.text(title); exploring = true } label: {
            HStack(spacing: 14) {
                Image(systemName: symbol).font(.system(size: 24)).foregroundStyle(color)
                    .frame(width: 44, height: 44).background(color.opacity(0.1), in: Circle())
                Text(L10n.text(title)).font(.system(.subheadline, design: .rounded, weight: .medium)).multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(Theme.muted.opacity(0.6))
            }.padding(12).background(.white.opacity(0.95), in: Capsule())
        }.buttonStyle(.plain)
    }
}
