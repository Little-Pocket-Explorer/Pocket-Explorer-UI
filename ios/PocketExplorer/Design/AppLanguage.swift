import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case portuguese = "pt-BR"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"

    var id: String { rawValue }
    var name: String {
        switch self {
        case .english: return "English"
        case .chinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .portuguese: return "Português (Brasil)"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .arabic: return "العربية"
        }
    }
    static func resolve(_ preferences: [String]) -> AppLanguage {
        for preference in preferences {
            let locale = Locale(identifier: preference.replacingOccurrences(of: "_", with: "-"))
            let code = locale.language.languageCode?.identifier
            if code == "zh" {
                let explicitScript = preference.lowercased().split(whereSeparator: { $0 == "-" || $0 == "_" }).first { $0 == "hans" || $0 == "hant" }
                if let explicitScript { return explicitScript == "hant" ? .traditionalChinese : .chinese }
                return ["TW", "HK", "MO"].contains(locale.region?.identifier ?? "") ? .traditionalChinese : .chinese
            }
            if code == "pt" { return .portuguese }
            if let code, let language = AppLanguage(rawValue: code) { return language }
        }
        return .english
    }

    static var current: AppLanguage { (LanguageSettings.selection ?? .system).resolve(Locale.preferredLanguages) }
    var speechLocale: String { NarrationStyle.locale(for: rawValue) }
    var isRightToLeft: Bool { self == .arabic }
}

enum LanguagePreference: String, CaseIterable, Identifiable {
    case system, english, chinese, traditionalChinese, spanish, french, german, portuguese, japanese, korean, arabic
    var id: String { rawValue }
    var language: AppLanguage? {
        switch self {
        case .system: return nil
        case .english: return .english
        case .chinese: return .chinese
        case .traditionalChinese: return .traditionalChinese
        case .spanish: return .spanish
        case .french: return .french
        case .german: return .german
        case .portuguese: return .portuguese
        case .japanese: return .japanese
        case .korean: return .korean
        case .arabic: return .arabic
        }
    }
    func resolve(_ preferredLanguages: [String]) -> AppLanguage {
        language ?? AppLanguage.resolve(preferredLanguages)
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
    static func date(_ date: Date, includeTime: Bool = false, language: AppLanguage = .current) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: includeTime ? .shortened : .omitted).locale(Locale(identifier: language.rawValue)))
    }

    static func text(_ key: String, language: AppLanguage = .current) -> String {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return key }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
