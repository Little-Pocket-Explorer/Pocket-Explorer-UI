import SwiftUI

struct RootView: View {
    let store: TripStore
    var changeLanguage: () -> Void
    @State private var tab = 0
    @State private var exploring = false
    @State private var artwork = ArtworkCoordinator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { ChatHomeView(store: store, changeLanguage: changeLanguage, isActive: tab == 0) }
                .tabItem { Label("Chat", systemImage: "bubble.left.fill") }.tag(0)
            NavigationStack { WorldView(store: store, explore: { exploring = true }, changeLanguage: changeLanguage) }
                .tabItem { Label("Map", systemImage: "map.fill") }.tag(1)
            NavigationStack { MemoriesView(store: store) }
                .tabItem { Label("Memories", systemImage: "sparkles.tv.fill") }.tag(2)
            NavigationStack { FriendsView(store: store) }
                .tabItem { Label("Friends", systemImage: "person.2.fill") }.tag(3)
        }
        .tint(Theme.forest)
        .environment(artwork)
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
        .sheet(isPresented: $exploring) { ExplorationFlow(store: store, tripID: nil) }
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
    @State private var saved: Discovery?
    @State private var revealed = false

    var body: some View {
        NavigationStack {
            Group {
                if let saved {
                    if !saved.isUnlocked {
                        PendingCardView(store: store, discovery: saved, close: { dismiss() })
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
                    Button(L10n.text(saved == nil ? "Close" : "Done")) { dismiss() }.frame(minWidth: 44, minHeight: 44).accessibilityIdentifier("exploration-close")
                }
            }
        }
        .tint(Theme.forest)
    }
}
