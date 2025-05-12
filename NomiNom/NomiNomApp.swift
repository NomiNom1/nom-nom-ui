//
//  NomiNomApp.swift
//  NomiNom
//
//  Created by Owen Murphy on 5/7/25.
//

import SwiftUI

@main
struct NomiNomApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var userSessionManager = UserSessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            LandingPage()
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .environmentObject(userSessionManager)
                .environment(\.locale, languageManager.currentLanguage.locale)
        }
    }
}
