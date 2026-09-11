import Foundation

enum AppLanguage: String {
    case english = "en"
    case chinese = "zh-Hans"

    static func resolve(_ preferences: [String]) -> AppLanguage {
        preferences.first?.hasPrefix("zh") == true ? .chinese : .english
    }

    static var current: AppLanguage { (LanguageSettings.selection ?? .system).resolve(Bundle.main.preferredLocalizations) }
    var speechLocale: String { self == .chinese ? "zh-CN" : "en-AU" }
}

enum LanguagePreference: String {
    case system, english, chinese

    func resolve(_ preferredLanguages: [String]) -> AppLanguage {
        switch self {
        case .system: return AppLanguage.resolve(preferredLanguages)
        case .english: return .english
        case .chinese: return .chinese
        }
    }
}

enum LanguageSettings {
    static var preferences: UserDefaults {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            return UserDefaults(suiteName: "PocketExplorerUITestLanguage")!
        }
        #endif
        return .standard
    }
    static var selection: LanguagePreference? {
        preferences.string(forKey: "app-language").flatMap(LanguagePreference.init(rawValue:))
    }
    static func save(_ preference: LanguagePreference, to defaults: UserDefaults = preferences) {
        defaults.set(preference.rawValue, forKey: "app-language")
    }
}

enum L10n {
    static func text(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: AppLanguage.current.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return key }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
