import SwiftUI

struct ChatHomeView: View {
    let store: TripStore
    var changeLanguage: () -> Void
    var isActive = true
    @Environment(\.explorerNavigation) private var navigation
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
    @State private var allDemoQuestions = false
    @AppStorage("explorer-age") private var age = 7

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Button { navigation?.open(.history) } label: { Image(systemName: "rectangle.leftthird.inset.filled").font(.system(size: 21)).frame(width: 44, height: 44).background(.white.opacity(0.85), in: Circle()) }
                        .accessibilityLabel("Question history").accessibilityIdentifier("question-history")
                    if !dynamicTypeSize.isAccessibilitySize {
                        Image("brand-logo").resizable().scaledToFit().frame(width: 30, height: 30).clipShape(RoundedRectangle(cornerRadius: 8)).accessibilityHidden(true)
                    }
                    Text("Pocket Explorer").font(.system(.title3, design: .rounded, weight: .black))
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .fixedSize(horizontal: false, vertical: true).layoutPriority(1)
                    Spacer(minLength: 0)
                    Button { navigation?.open(.profile) } label: { ExplorerAvatar(size: 44, avatar: store.family.family?.profile.avatar) }.buttonStyle(.plain).accessibilityLabel("My profile").accessibilityIdentifier("open-profile")
                }.padding(.horizontal, 18).padding(.top, 8)
                if store.state.discoveries.contains(where: { ReminderPolicy.isEligible($0, now: Date()) }) {
                    NavigationLink(value: ExplorerRoute.reminders) {
                        HStack { LeafBadge(symbol: "leaf.arrow.triangle.circlepath"); Text("A little look back").font(.subheadline.bold()); Spacer(); Image(systemName: "chevron.right") }
                            .padding(12).background(.white, in: Capsule())
                    }.padding(.horizontal, 18).padding(.top, 12).accessibilityIdentifier("home-reminders")
                }
                Image("explorer-hero").resizable().scaledToFit().accessibilityHidden(true)
                    .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.08), .init(color: .black, location: 0.8), .init(color: .clear, location: 1)], startPoint: .top, endPoint: .bottom))
                    .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.1), .init(color: .black, location: 0.9), .init(color: .clear, location: 1)], startPoint: .leading, endPoint: .trailing))
                    .frame(maxHeight: 230)
                VStack(spacing: 10) {
                    Text("What are you curious\nabout today?").font(.system(.largeTitle, design: .rounded, weight: .black))
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    Text("Ask about anything you notice.").font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                }.padding(.horizontal, 20).padding(.bottom, 22)
                VStack(spacing: 10) {
                    if store.demo.enabled {
                        Label("Demo mode", systemImage: "sparkles").font(.caption.bold()).foregroundStyle(Theme.forest).accessibilityIdentifier("demo-badge")
                        if store.demo.busy { ProgressView("Preparing your demo…") }
                        if store.demo.items.isEmpty && !store.demo.busy {
                            Text("No demo discoveries in this language yet.").font(.subheadline).foregroundStyle(Theme.muted)
                        }
                    }
                    ForEach(store.demo.enabled ? Array(store.demo.items.prefix(3)) : recommendations.items) { suggestion($0) }
                    if store.demo.enabled && store.demo.items.count > 3 {
                        Button("All demo discoveries") { allDemoQuestions = true }.font(.subheadline.bold())
                    }
                    if !store.demo.enabled && recommendations.removedCount > 0 {
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
                Button { open(.camera) } label: { Image(systemName: "camera.fill").font(.system(size: 22)).foregroundStyle(Theme.forest).frame(width: 44, height: 44) }
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
            if let connection = try? ConnectionVault().loadOrCreate(), store.demo.hasAccessRecord {
                await store.demo.checkAccess(connection: connection)
                store.demo.selectContext(language: AppLanguage.current.rawValue, age: age)
                if store.demo.enabled && !store.demo.offlineReady {
                    await store.demo.refresh(connection: connection, language: AppLanguage.current.rawValue, age: age)
                }
            }
            await recommendations.synchronize(base: base, language: AppLanguage.current.rawValue, age: age, now: now, force: forceRefresh)
            guard !Task.isCancelled else { return }
            if recommendations.items.isEmpty && recommendations.removedCount == 0 {
                _ = try? recommendations.activate(language: AppLanguage.current.rawValue, age: age, now: now)
            }
            await recommendations.prefetch(base: base)
        }
        .sheet(isPresented: $allDemoQuestions) {
            NavigationStack {
                List(store.demo.items) { item in
                    Button(item.question) { select(item) }
                }.navigationTitle("All demo discoveries").toolbar { Button("Done") { allDemoQuestions = false } }
            }.tint(Theme.forest)
        }
        .onChange(of: store.family.family?.profile.age) { _, value in if let value { age = value } }
    }

    private var safeHome: Bool {
        visible && isActive && scenePhase == .active && !allDemoQuestions
    }

    private var homeContext: String { "\(safeHome):\(AppLanguage.current.rawValue):\(age)" }

    private func suggestion(_ item: PreparedContent) -> some View {
        let symbol = item.reply.category == "nature" ? "leaf.fill" : "sparkles"
        return Button {
            select(item)
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

    private func select(_ item: PreparedContent) {
        guard store.family.allows(.exploration) else { recommendationError = FamilyError.disabled.localizedDescription; return }
        do {
            let record = try store.beginPrepared(item, age: age)
            allDemoQuestions = false
            navigation?.open(.explore(.init(recordID: record.id, presentAnswer: true)))
            recommendationError = nil
        } catch { recommendationError = L10n.text("Your discoveries could not be saved. Please try again.") }
    }

    private func open(_ entry: ExplorationEntry, question: String = "") {
        guard store.family.allows(.exploration) else { recommendationError = FamilyError.disabled.localizedDescription; return }
        navigation?.open(.explore(.init(question: question, entry: entry)))
    }
}
