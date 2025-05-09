import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
            updateLanguage()
        }
    }
    
    private init() {
        // Get saved language or use system language
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Use system language or default to English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = AppLanguage(rawValue: systemLanguage) ?? .english
        }
    }
    
    private func updateLanguage() {
        // Update app's language settings
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
}

// Notification name for language changes
extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

// Environment key for language
private struct LanguageKey: EnvironmentKey {
    static let defaultValue = LanguageManager.shared.currentLanguage
}

extension EnvironmentValues {
    var language: AppLanguage {
        get { self[LanguageKey.self] }
        set { self[LanguageKey.self] = newValue }
    }
}
