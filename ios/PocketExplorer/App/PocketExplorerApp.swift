import SwiftUI
import Security

@main
struct PocketExplorerApp: App {
    @State private var store: TripStore?
    @State private var loadError: String?
    @State private var language: LanguagePreference?
    @State private var choosingLanguage = false

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
                } else if let loadError {
                    ContentUnavailableView("Your journal needs a moment", systemImage: "book.closed", description: Text(loadError))
                } else {
                    ProgressView("Opening your little world…")
                }
            }
            .id(language)
            .environment(\.locale, Locale(identifier: AppLanguage.current.rawValue))
            .tint(Theme.forest)
            .preferredColorScheme(.light)
            .task { openJournal() }
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
        guard store == nil, loadError == nil else { return }
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
        } catch {
            loadError = "Your saved journal has been kept. \(error.localizedDescription)"
        }
    }
}
