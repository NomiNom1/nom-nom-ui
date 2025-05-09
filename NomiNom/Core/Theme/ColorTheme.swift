import SwiftUI

// MARK: - Color Theme Protocol
protocol ColorTheme {
    var primary: Color { get }
    var secondary: Color { get }
    var background: Color { get }
    var surface: Color { get }
    var error: Color { get }
    var success: Color { get }
    var warning: Color { get }
    
    // Text Colors
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
    
    // Button Colors
    var buttonPrimary: Color { get }
    var buttonSecondary: Color { get }
    var buttonDisabled: Color { get }
    
    // Status Colors
    var statusActive: Color { get }
    var statusInactive: Color { get }
    var statusPending: Color { get }
}

import SwiftUI

// MARK: - Light Theme
struct LightTheme: ColorTheme {
    let primary = Color(red: 0.18, green: 0.55, blue: 0.82)   // Steel Blue
    let secondary = Color(red: 0.68, green: 0.85, blue: 0.90) // Light Sky Blue
    let background = Color(red: 1.00, green: 1.00, blue: 1.00)   // White
    let surface = Color(red: 0.95, green: 0.95, blue: 0.95)     // Light Gray
    let error = Color(red: 0.85, green: 0.32, blue: 0.24)     // Error Red
    let success = Color(red: 0.20, green: 0.80, blue: 0.20)   // Success Green
    let warning = Color(red: 0.94, green: 0.78, blue: 0.20)   // Warning Gold

    let textPrimary = Color(red: 0.00, green: 0.00, blue: 0.00) // Black
    let textSecondary = Color(red: 0.40, green: 0.40, blue: 0.40) // Dark Gray
    let textTertiary = Color(red: 0.60, green: 0.60, blue: 0.60)  // Gray

    let buttonPrimary = Color(red: 0.18, green: 0.55, blue: 0.82) // Steel Blue
    let buttonSecondary = Color(red: 0.68, green: 0.85, blue: 0.90) // Light Sky Blue
    let buttonDisabled = Color(red: 0.80, green: 0.80, blue: 0.80)  // Light Gray

    let statusActive = Color(red: 0.20, green: 0.80, blue: 0.20)    // Green
    let statusInactive = Color(red: 0.80, green: 0.80, blue: 0.80)  // Gray
    let statusPending = Color(red: 0.94, green: 0.78, blue: 0.20)   // Gold
}

// MARK: - Dark Theme
struct DarkTheme: ColorTheme {
    let primary = Color(red: 0.30, green: 0.70, blue: 0.90)   // Slightly lighter Steel Blue
    let secondary = Color(red: 0.50, green: 0.75, blue: 0.85) // Slightly darker Light Sky Blue
    let background = Color(red: 0.10, green: 0.10, blue: 0.12)   // Dark Gray/Almost Black
    let surface = Color(red: 0.20, green: 0.20, blue: 0.22)     // Darker Gray
    let error = Color(red: 1.00, green: 0.40, blue: 0.30)     // Brighter Red
    let success = Color(red: 0.40, green: 0.90, blue: 0.40)   // Brighter Green
    let warning = Color(red: 1.00, green: 0.85, blue: 0.30)   // Brighter Gold

    let textPrimary = Color(red: 1.00, green: 1.00, blue: 1.00) // White
    let textSecondary = Color(red: 0.80, green: 0.80, blue: 0.80) // Light Gray
    let textTertiary = Color(red: 0.60, green: 0.60, blue: 0.60)  // Gray

    let buttonPrimary = Color(red: 0.30, green: 0.70, blue: 0.90) // Slightly lighter Steel Blue
    let buttonSecondary = Color(red: 0.50, green: 0.75, blue: 0.85) // Slightly darker Light Sky Blue
    let buttonDisabled = Color(red: 0.40, green: 0.40, blue: 0.40)  // Dark Gray

    let statusActive = Color(red: 0.40, green: 0.90, blue: 0.40)    // Brighter Green
    let statusInactive = Color(red: 0.40, green: 0.40, blue: 0.40)  // Dark Gray
    let statusPending = Color(red: 1.00, green: 0.85, blue: 0.30)   // Brighter Gold
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: ColorTheme
    @Published var isDarkMode: Bool
    
    init() {
        // Initialize with system appearance
        let savedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? "system"
        let isDark = savedTheme == "On" || (savedTheme == "System Settings" && UITraitCollection.current.userInterfaceStyle == .dark)
        self.isDarkMode = true
        self.currentTheme = isDark ? DarkTheme() : LightTheme()
    }
    
    func updateTheme(for colorScheme: ColorScheme) {
        let savedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? "system"
        
        switch savedTheme {
        case "On":
            isDarkMode = true
            currentTheme = DarkTheme()
        case "Off":
            isDarkMode = false
            currentTheme = LightTheme()
        case "System Settings":
            isDarkMode = colorScheme == .dark
            currentTheme = colorScheme == .dark ? DarkTheme() : LightTheme()
        default:
            isDarkMode = colorScheme == .dark
            currentTheme = colorScheme == .dark ? DarkTheme() : LightTheme()
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(red: Int, green: Int, blue: Int) {
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1.0
        )
    }
} 
