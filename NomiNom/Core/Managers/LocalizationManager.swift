import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private var localizedStrings: [String: [String: String]] = [:]
    
    private init() {
        loadLocalizations()
    }
    
    private func loadLocalizations() {
        // Load all language files
        for language in AppLanguage.allCases {
            if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                if let strings = NSDictionary(contentsOfFile: bundle.path(forResource: "Localizable", ofType: "strings") ?? "") as? [String: String] {
                    localizedStrings[language.rawValue] = strings
                }
            }
        }
    }
    
    func localizedString(_ key: String, language: AppLanguage = LanguageManager.shared.currentLanguage) -> String {
        return localizedStrings[language.rawValue]?[key] ?? key
    }
}

// String extension for easy localization
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
    
    func localized(with language: AppLanguage) -> String {
        return LocalizationManager.shared.localizedString(self, language: language)
    }
} 