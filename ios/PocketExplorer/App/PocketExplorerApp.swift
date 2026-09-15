import SwiftUI
import Security

@main
struct PocketExplorerApp: App {
    @State private var store: TripStore?
    @State private var loadError: String?
    @State private var language: LanguagePreference?
    @State private var profile: ExplorerProfile?
    @State private var choosingLanguage = false
    @State private var deviceLanguage = AppLanguage.resolve(Locale.preferredLanguages)
    private var resolvedLanguage: AppLanguage { language?.language ?? deviceLanguage }

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            if ProcessInfo.processInfo.arguments.contains("--reset-language") { LanguageSettings.preferences.removeObject(forKey: "app-language") }
            if ProcessInfo.processInfo.arguments.contains("--reset-profile") { ProfileSettings.clear() }
            if ProfileSettings.profile == nil { _ = try? ProfileSettings.save(email: "explorer@example.com") }
        }
        #endif
        _language = State(initialValue: LanguageSettings.selection)
        _profile = State(initialValue: ProfileSettings.profile)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if profile == nil {
                    ProfileSetupView(onComplete: { savedProfile in
                        if language == nil {
                            LanguageSettings.save(.system)
                            language = .system
                        }
                        profile = savedProfile
                    })
                } else if language == nil {
                    LanguageSelectionView(onSelect: selectLanguage)
                } else if let store {
                    RootView(store: store, changeLanguage: { choosingLanguage = true })
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
            .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
                deviceLanguage = AppLanguage.resolve(Locale.preferredLanguages)
            }
            .sheet(isPresented: $choosingLanguage) {
                LanguageSelectionView(onSelect: selectLanguage)
            }
        }
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
            store = try TripStore(fileURL: url, initial: initial)
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
