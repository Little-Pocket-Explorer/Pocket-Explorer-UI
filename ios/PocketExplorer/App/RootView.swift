import SwiftUI

struct RootView: View {
    let store: TripStore
    var changeLanguage: () -> Void
    @Binding var discoveryLink: DiscoveryLink?
    @State private var navigation = AppNavigation()
    @State private var notifications = RecallNotifications.shared
    @AppStorage("explorer-age") private var age = 7
    @State private var familySettings = false
    @State private var artwork = ArtworkCoordinator()
    @State private var aiPermission = AIDataPermission()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $navigation.tab) {
            stack(.chat) { ChatHomeView(store: store, changeLanguage: changeLanguage, isActive: navigation.tab == .chat) }
                .tabItem { Label("Chat", systemImage: "bubble.left.fill") }.tag(ExplorerTab.chat)
            stack(.map) { WorldView(store: store, explore: { navigation.open(.explore(.init()), in: .chat) }, changeLanguage: changeLanguage) }
                .tabItem { Label("Map", systemImage: "map.fill") }.tag(ExplorerTab.map)
            stack(.social) { SocialView(store: store) }
                .tabItem { Label("Social", systemImage: "person.2.fill") }.tag(ExplorerTab.social)
        }
        .tint(Theme.forest)
        .environment(artwork)
        .environment(\.explorerNavigation, navigation)
        .onChange(of: discoveryLink, initial: true) { _, value in
            guard let value else { return }
            navigation.open(value.kind == "events" ? .event(value.identifier) : .sharedDiscovery(value.identifier), in: .map)
            discoveryLink = nil
        }
        .onChange(of: notifications.opening, initial: true) { _, value in
            guard let value else { return }
            navigation.open(.recall(value), in: .chat)
            notifications.opening = nil
        }
        .task(id: "\(scenePhase == .active):\(store.family.allows(.exploration)):\(store.state.discoveries.map { "\($0.id):\($0.quizAnsweredAt?.timeIntervalSince1970 ?? 0):\($0.recallReviewedAt?.timeIntervalSince1970 ?? 0):\($0.isVerified)" }.joined()):\(AppLanguage.current.rawValue)") {
            guard scenePhase == .active else { return }
            let discoveries = store.state.discoveries.filter { discovery in
                discovery.collectible != nil && !store.state.trips.contains(where: { $0.id == discovery.tripID && $0.isExample })
            }
            await notifications.synchronize(store.family.allows(.exploration) ? RecallNotice.plan(discoveries) : [])
        }
        .sheet(isPresented: $familySettings) { FamilySettingsView(family: store.family) }
        .task(id: scenePhase) {
            guard scenePhase == .active, let connection = try? ConnectionVault().loadOrCreate() else { return }
            await aiPermission.synchronize(connection: connection)
        }
        .background(FamilyPauseShield(family: store.family).frame(width: 0, height: 0))
        .task(id: scenePhase) {
            guard scenePhase == .active else { try? store.family.endActive(); return }
            store.family.beginActive()
            guard let connection = try? ConnectionVault().loadOrCreate() else { return }
            await store.family.synchronize(connection: connection)
            var ticks = 0
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(5)) } catch { return }
                try? store.family.tick()
                ticks += 1
                if ticks % 6 == 0 && store.family.family != nil { await store.family.synchronize(connection: connection) }
            }
        }
        .task(id: "\(scenePhase == .active):\(store.family.family?.id ?? "")") {
            guard scenePhase == .active, store.family.family != nil, let connection = try? ConnectionVault().loadOrCreate() else { return }
            try? await store.social.synchronizeReceivedCards(store: store, connection: connection)
        }
        .task(id: scenePhase == .active ? store.state.discoveries.count : -1) {
            if scenePhase == .active { await artwork.resume(store: store) }
        }
        .task(id: "\(scenePhase == .active):\(store.questions.count):\(store.state.recallAttempts?.count ?? 0)") {
            guard scenePhase == .active else { return }
            while !Task.isCancelled {
                await PreparedRegistration.shared.refresh(store: store)
                if let connection = try? ConnectionVault().loadOrCreate() { await store.recall.synchronize(store: store, connection: connection) }
                do { try await Task.sleep(for: .seconds(30)) } catch { return }
            }
        }

    }

    private func stack<Content: View>(_ tab: ExplorerTab, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack(path: Binding(get: { navigation.paths[tab] ?? [] }, set: { navigation.paths[tab] = $0 })) {
            content()
                .navigationDestination(for: ExplorerRoute.self) { route in
                    destination(route)
                        .toolbar(.visible, for: .navigationBar, .tabBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button { navigation.home() } label: { Image(systemName: "house.fill").frame(minWidth: 44, minHeight: 44) }
                                    .accessibilityLabel("Home").accessibilityIdentifier("navigation-home")
                            }
                        }
                }
        }.id(navigation.roots[tab, default: 0])
    }

    @ViewBuilder private func destination(_ route: ExplorerRoute) -> some View {
        switch route {
        case .explore(let value):
            ExplorationFlow(store: store, tripID: value.tripID, initialQuestion: value.question, recordID: value.recordID,
                presentAnswerOnOpen: value.presentAnswer, entry: value.entry, parentQuestionID: value.parentID, evolveFrom: value.evolveFrom)
        case .card(let id): CardDetailView(store: store, discoveryID: id)
        case .newCard(let id): NewCardView(store: store, discoveryID: id)
        case .trip(let id): TripDetailView(store: store, tripID: id)
        case .collection: CollectionView(store: store, explore: { navigation.open(.explore(.init()), in: .chat) })
        case .memory(let id):
            if let trip = store.state.trips.first(where: { $0.id == id }) {
                MemoryPlayer(trip: trip, store: store).toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: ExplorerRoute.share(trip.id, nil)) {
                            Image(systemName: "square.and.arrow.up").frame(minWidth: 44, minHeight: 44)
                        }.accessibilityLabel("Preview & share").accessibilityIdentifier("memory-share-preview")
                    }
                }
            }
        case .share(let id, let cardID):
            if let trip = store.state.trips.first(where: { $0.id == id }) {
                SharePreviewView(trip: trip, discoveries: cardID.map { cardID in store.state.discoveries.filter { $0.id == cardID } } ?? store.discoveries(in: id), store: store, singleCardID: cardID)
            }
        case .nearby: NearbyDiscoveryView(store: store)
        case .event(let id): DiscoveryLinkView(store: store, link: DiscoveryLink(kind: "events", identifier: id))
        case .sharedDiscovery(let id): DiscoveryLinkView(store: store, link: DiscoveryLink(kind: "discoveries", identifier: id))
        case .mapShare(let id):
            if let discovery = store.state.discoveries.first(where: { $0.id == id }) { MapSharingView(store: store, discovery: discovery) }
        case .reminders: DiscoveryRemindersView(store: store)
        case .recall(let id): DiscoveryQuizView(store: store, discoveryID: id, showContext: true)
        case .friendProfile(let id): FriendProfileView(store: store, friendID: id)
        case .friend(let id, let page): FriendDetailView(store: store, friendID: id, page: page)
        case .friendCard(let friend, let id):
            if let card = store.social.cards[friend]?.first(where: { $0.id == id }) { FriendCardView(store: store, friendID: friend, card: card) }
        case .exchange(let friend, let id):
            GiftComposerView(store: store, friendID: friend, wanted: id.flatMap { id in store.social.cards[friend]?.first(where: { $0.id == id }) })
        case .history:
            QuestionHistoryView(store: store, select: { navigation.open(.explore(.init(recordID: $0.id)), in: .chat) }, done: { navigation.back() })
        case .profile: ExplorerProfileView(store: store, age: $age, onClose: { navigation.back() }, onLanguage: changeLanguage, onFamilySettings: { familySettings = true })
        case .eventShare(let id): EventShareView(store: store, eventID: id)
        }
    }

}

struct ExplorationFlow: View {
    let store: TripStore
    let tripID: UUID?
    var initialQuestion = ""
    var recordID: UUID?
    var presentAnswerOnOpen = false
    var entry: ExplorationEntry = .compose
    var parentQuestionID: UUID?
    var evolveFrom: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.explorerNavigation) private var navigation
    @State private var saved: Discovery?
    @State private var revealed = false

    var body: some View {
        FeatureNavigation {
            Group {
                if let saved {
                    if !saved.isUnlocked {
                        PendingCardView(store: store, discovery: saved, close: { finish() })
                    } else if revealed {
                        NewCardView(store: store, discoveryID: saved.id)
                    } else {
                        CardUnlockView(discovery: store.state.discoveries.first(where: { $0.id == saved.id }) ?? saved, onReveal: { revealed = true }, store: store)
                    }
                }
                else { ExploreView(store: store, tripID: tripID, initialQuestion: initialQuestion, recordID: recordID, presentAnswerOnOpen: presentAnswerOnOpen, entry: entry, parentQuestionID: parentQuestionID, evolveFrom: evolveFrom, onSave: { discovery, isNew in saved = discovery; revealed = !isNew }) }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.text(saved == nil ? "Close" : "Done")) { finish() }.frame(minWidth: 44, minHeight: 44).accessibilityIdentifier("exploration-close")
                }
            }
        }
        .tint(Theme.forest)
    }

    private func finish() {
        if let navigation { navigation.back() } else { dismiss() }
    }
}
