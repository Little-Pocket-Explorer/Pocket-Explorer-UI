import SwiftUI

struct ChatHomeView: View {
    let store: TripStore
    var changeLanguage: () -> Void
    var isActive = true
    @Environment(\.scenePhase) private var scenePhase
    @State private var recommendations: RecommendationStore
    @State private var visible = false
    @State private var recommendationError: String?

    init(store: TripStore, changeLanguage: @escaping () -> Void, isActive: Bool = true) {
        self.store = store
        self.changeLanguage = changeLanguage
        self.isActive = isActive
        _recommendations = State(initialValue: store.recommendations)
    }
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var launch: ExplorationLaunch?
    @State private var selectedQuestion: ExplorationRecord?
    @State private var history = false
    @State private var profile = false
    @State private var pendingQuestion: ExplorationRecord?
    @State private var pendingLanguage = false
    @AppStorage("explorer-age") private var age = 7

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Button { history = true } label: { Image(systemName: "sidebar.left").font(.system(size: 21)).frame(width: 44, height: 44).background(.white.opacity(0.85), in: Circle()) }
                        .accessibilityLabel("Question history").accessibilityIdentifier("question-history")
                    if !dynamicTypeSize.isAccessibilitySize {
                        Image(systemName: "leaf.fill").font(.system(size: 23)).foregroundStyle(Theme.forest).accessibilityHidden(true)
                    }
                    Text("Pocket Explorer").font(.system(.title3, design: .rounded, weight: .black))
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .fixedSize(horizontal: false, vertical: true).layoutPriority(1)
                    Spacer(minLength: 0)
                    Button { profile = true } label: { ExplorerAvatar(size: 44) }.buttonStyle(.plain).accessibilityLabel("My profile").accessibilityIdentifier("open-profile")
                }.padding(.horizontal, 18).padding(.top, 8)
                if store.state.discoveries.contains(where: { ReminderPolicy.isEligible($0, now: Date()) }) {
                    NavigationLink { DiscoveryRemindersView(store: store) } label: {
                        HStack { LeafBadge(symbol: "leaf.arrow.triangle.circlepath"); Text("A little look back").font(.subheadline.bold()); Spacer(); Image(systemName: "chevron.right") }
                            .padding(12).background(.white, in: Capsule())
                    }.padding(.horizontal, 18).padding(.top, 12).accessibilityIdentifier("home-reminders")
                }
                Image("explorer-hero").resizable().scaledToFit().frame(maxHeight: 230).accessibilityHidden(true)
                VStack(spacing: 10) {
                    Text("What are you curious\nabout today?").font(.system(.largeTitle, design: .rounded, weight: .black))
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    Text("Ask about anything you notice.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                }.padding(.horizontal, 20).padding(.bottom, 22)
                VStack(spacing: 10) {
                    ForEach(recommendations.items) { suggestion($0) }
                    if recommendations.removedCount > 0 {
                        Text("A discovery is being updated. You can still ask your own question.").font(.caption).foregroundStyle(Theme.muted)
                    }
                    if let recommendationError { Text(recommendationError).font(.caption).foregroundStyle(Theme.muted) }
                }.padding(.horizontal, 24)
            }.padding(.bottom, 24)
        }
        .background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: dynamicTypeSize.isAccessibilitySize ? 8 : 12) {
                Button { open(.camera) } label: { Image(systemName: "camera").font(.system(size: 22)).foregroundStyle(Theme.forest).frame(width: 44, height: 44) }
                    .accessibilityLabel("Explore with a photo").accessibilityIdentifier("home-camera")
                Button { open(.compose) } label: {
                    Text(L10n.text(dynamicTypeSize.isAccessibilitySize ? "Ask" : "Ask anything…"))
                        .foregroundStyle(Theme.muted).fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading).contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityLabel("Type your question").accessibilityIdentifier("home-question")
                Button { open(.voice) } label: { LeafBadge(symbol: "mic.fill").frame(width: 44, height: 44) }
                    .accessibilityLabel("Speak your question").accessibilityIdentifier("home-ask")
            }.padding(12).background(.white, in: Capsule()).shadow(color: Theme.ink.opacity(0.07), radius: 12, y: 4)
                .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 10 : 16).padding(.bottom, 6).background(Theme.paper.opacity(0.8))
        }
        .onAppear { visible = true }
        .onDisappear { visible = false }
        .task(id: homeContext) {
            guard safeHome else { return }
            var now = Date()
            var forceRefresh = false
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
                if let value = ProcessInfo.processInfo.environment["POCKET_TEST_DISCOVERY_TIME"], let timestamp = Double(value) {
                    now = Date(timeIntervalSince1970: timestamp)
                }
                forceRefresh = ProcessInfo.processInfo.arguments.contains("--refresh-discoveries")
            }
            #endif
            do { try recommendations.activate(language: AppLanguage.current.rawValue, age: age, now: now); recommendationError = nil }
            catch { recommendationError = L10n.text("Your discoveries could not be saved. Please try again.") }
            guard let base = try? ConnectionVault().loadOrCreate().validatedURL else { return }
            await recommendations.synchronize(base: base, language: AppLanguage.current.rawValue, age: age, now: now, force: forceRefresh)
            guard !Task.isCancelled else { return }
            if recommendations.items.isEmpty && recommendations.removedCount == 0 {
                _ = try? recommendations.activate(language: AppLanguage.current.rawValue, age: age, now: now)
            }
            await recommendations.prefetch(base: base)
        }
        .sheet(item: $launch) { launch in ExplorationFlow(store: store, tripID: nil, initialQuestion: launch.question, entry: launch.entry) }
        .sheet(item: $selectedQuestion) { record in ExplorationFlow(store: store, tripID: nil, recordID: record.id) }
        .sheet(isPresented: $history, onDismiss: { selectedQuestion = pendingQuestion; pendingQuestion = nil }) {
            NavigationStack {
                List {
                    if store.questions.isEmpty { Text("Your questions will appear here.").foregroundStyle(Theme.muted) }
                    ForEach(store.questions) { record in
                        Button { pendingQuestion = record; history = false } label: {
                            HStack { LeafBadge(); VStack(alignment: .leading, spacing: 4) {
                                Text(record.reply?.title ?? record.question).font(.headline)
                                Text(L10n.date(record.createdAt, includeTime: true)).font(.caption).foregroundStyle(Theme.muted)
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
                        Button("Language") { pendingLanguage = true; profile = false }.accessibilityIdentifier("choose-language")
                        LabeledContent("Discoveries", value: "\(store.state.discoveries.count)")
                        LabeledContent("Questions", value: "\(store.questions.count)")
                    }
                }.navigationTitle("My profile").toolbar { Button("Done") { profile = false } }
            }.tint(Theme.forest)
        }
    }

    private var safeHome: Bool {
        visible && isActive && scenePhase == .active && launch == nil && selectedQuestion == nil && !history && !profile
    }

    private var homeContext: String { "\(safeHome):\(AppLanguage.current.rawValue):\(age)" }

    private func suggestion(_ item: PreparedContent) -> some View {
        let symbol = item.reply.category == "nature" ? "leaf.fill" : "sparkles"
        return Button {
            do { selectedQuestion = try store.beginPrepared(item, age: age); recommendationError = nil }
            catch { recommendationError = L10n.text("Your discoveries could not be saved. Please try again.") }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: symbol).font(.system(size: 24)).foregroundStyle(Theme.forest)
                    .frame(width: 44, height: 44).background(Theme.mint, in: Circle())
                Text(item.question).font(.system(.subheadline, design: .rounded, weight: .medium)).multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(Theme.muted.opacity(0.6))
            }.padding(12).background(.white.opacity(0.95), in: Capsule())
        }.buttonStyle(.plain).accessibilityIdentifier("daily-question-\(item.topicID)")
    }

    private func open(_ entry: ExplorationEntry, question: String = "") {
        launch = ExplorationLaunch(entry: entry, question: question)
    }
}

private struct ExplorationLaunch: Identifiable {
    let id = UUID()
    let entry: ExplorationEntry
    let question: String
}
