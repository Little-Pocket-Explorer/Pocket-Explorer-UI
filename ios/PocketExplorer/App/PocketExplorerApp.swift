import SwiftUI
import Security

@main
struct PocketExplorerApp: App {
    @State private var store: TripStore?
    @State private var loadError: String?
    @State private var language: LanguagePreference?
    @State private var choosingLanguage = false
    @State private var demoActivation: DemoActivation?
    @State private var deviceLanguage = AppLanguage.resolve(Locale.preferredLanguages)
    @Environment(\.scenePhase) private var scenePhase
    private var resolvedLanguage: AppLanguage { language?.language ?? deviceLanguage }

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing"), ProcessInfo.processInfo.arguments.contains("--reset-language") {
            LanguageSettings.preferences.removeObject(forKey: "app-language")
        }
        #endif
        _language = State(initialValue: LanguageSettings.selection)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if language == nil {
                    LanguageSelectionView(onSelect: selectLanguage)
                } else if let store {
                    RootView(store: store, changeLanguage: { choosingLanguage = true })
                        .sheet(item: $demoActivation) { activation in DemoActivationView(activation: activation, demo: store.demo) }
                } else if let loadError {
                    ContentUnavailableView("Your journal needs a moment", systemImage: "book.closed", description: Text(loadError))
                } else {
                    ProgressView("Opening your little world…")
                }
            }
            .id("\(language?.rawValue ?? "choose")-\(resolvedLanguage.rawValue)")
            .environment(\.locale, Locale(identifier: resolvedLanguage.rawValue))
            .environment(\.layoutDirection, resolvedLanguage.isRightToLeft ? .rightToLeft : .leftToRight)
            .tint(Theme.forest)
            .preferredColorScheme(.light)
            .task(id: language) { openJournal() }
            .onOpenURL { url in
                if let activation = DemoActivation(url: url) { demoActivation = activation }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
                deviceLanguage = AppLanguage.resolve(Locale.preferredLanguages)
            }
            .sheet(isPresented: $choosingLanguage) {
                LanguageSelectionView(onSelect: selectLanguage)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background, language != nil { RecommendationRefresh.schedule() }
            #if DEBUG
            // Exercise the app's refresh entry point without relying on nondeterministic OS scheduling.
            if phase == .background, ProcessInfo.processInfo.arguments.contains("--simulate-discovery-refresh") {
                Task { await refreshRecommendations() }
            }
            #endif
        }
        .backgroundTask(.appRefresh(RecommendationRefresh.identifier)) {
            await refreshRecommendations()
        }
    }

    @MainActor
    private func refreshRecommendations() async {
        defer { RecommendationRefresh.schedule() }
        openJournal()
        guard let store, let base = try? ConnectionVault().loadOrCreate().validatedURL else { return }
        let savedAge = UserDefaults.standard.integer(forKey: "explorer-age")
        await RecommendationRefresh.run(store: store.recommendations, base: base, language: resolvedLanguage.rawValue, age: (5...18).contains(savedAge) ? savedAge : 7)
    }

    private func selectLanguage(_ preference: LanguagePreference) {
        LanguageSettings.save(preference)
        language = preference
        choosingLanguage = false
    }

    private func openJournal() {
        guard language != nil, store == nil, loadError == nil else { return }
        do {
            var url = TripStore.defaultURL
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
                url = FileManager.default.temporaryDirectory.appendingPathComponent("PocketExplorerUITests/journal.json")
                if ProcessInfo.processInfo.arguments.contains("--reset-journal") {
                    try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
                    ShareStorageScope.preferences.removePersistentDomain(forName: "PocketExplorerUITests")
                    SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrService: ShareStorageScope.service] as CFDictionary)
                }
            }
            #endif
            let initial: JournalState
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-testing"),
               let fixture = ProcessInfo.processInfo.environment["POCKET_TEST_JOURNAL"]?.data(using: .utf8) {
                initial = try JSONDecoder().decode(JournalState.self, from: fixture)
            } else {
                initial = ProcessInfo.processInfo.arguments.contains("--empty-journal") ? JournalState(trips: [], discoveries: []) : .examples()
            }
            #else
            initial = .examples()
            #endif
            #if DEBUG
            // Fixture-driven flows inject their own bank. Bundle acceptance opts into the real resources.
            let bundledContent: [PreparedContent]? = ProcessInfo.processInfo.arguments.contains("--ui-testing") && !ProcessInfo.processInfo.arguments.contains("--bundled-discoveries") ? [] : nil
            #else
            let bundledContent: [PreparedContent]? = nil
            #endif
            store = try TripStore(fileURL: url, initial: initial, bundledContent: bundledContent)
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-testing"), ProcessInfo.processInfo.arguments.contains("--reset-journal"),
               let fixture = ProcessInfo.processInfo.environment["POCKET_TEST_MEDIA"]?.data(using: .utf8) {
                for (filename, data) in try JSONDecoder().decode([String: Data].self, from: fixture) {
                    try data.write(to: url.deletingLastPathComponent().appendingPathComponent(URL(fileURLWithPath: filename).lastPathComponent), options: .atomic)
                }
            }
            #endif
        } catch {
            loadError = (error as? JournalError)?.localizedDescription ?? L10n.text("Your saved journal has been kept. Please close the app and try again.")
        }
    }
}
