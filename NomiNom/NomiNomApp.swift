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
    
    var body: some Scene {
        WindowGroup {
            LandingPage()
                .environmentObject(themeManager)
                .withTheme()
        }
    }
}
