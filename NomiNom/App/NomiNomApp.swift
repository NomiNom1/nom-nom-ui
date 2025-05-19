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
    @State private var isInitialized = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !isInitialized {
                    ProgressView()
                        .onAppear {
                            Task {
                                // Wait for session restoration
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                isInitialized = true
                            }
                        }
                } else {
                    if userSessionManager.isSignedIn {
                        MainTabView()
                    } else {
                        LandingPage()
                    }
                }
            }
            .environmentObject(themeManager)
            .environmentObject(languageManager)
            .environmentObject(userSessionManager)
            .environment(\.locale, languageManager.currentLanguage.locale)
        }
    }
}
