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

// MARK: - Light Theme
struct LightTheme: ColorTheme {
    let primary = Color(red: 0.4627, green: 0.8392, blue: 1.0)      // Primary brand color
    let secondary = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // Secondary brand color
    let background = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // White background
    let surface = Color(red: 0.4627, green: 0.8392, blue: 1.0)     // Surface color
    let error = Color(red: 0.4627, green: 0.8392, blue: 1.0)        // Error red
    let success = Color(red: 0.4627, green: 0.8392, blue: 1.0)      // Success green
    let warning = Color(red: 0.4627, green: 0.8392, blue: 1.0)      // Warning orange
    
    let textPrimary = Color(red: 0.4627, green: 0.8392, blue: 1.0)  // Primary text
    let textSecondary = Color(red: 0.4627, green: 0.8392, blue: 1.0) // Secondary text
    let textTertiary = Color(red: 0.4627, green: 0.8392, blue: 1.0)  // Tertiary text
    
    let buttonPrimary = Color(red: 0.4627, green: 0.8392, blue: 1.0)    // Primary button
    let buttonSecondary = Color(red: 0.4627, green: 0.8392, blue: 1.0)  // Secondary button
    let buttonDisabled = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // Disabled button
    
    let statusActive = Color(red: 0.4627, green: 0.8392, blue: 1.0)     // Active status
    let statusInactive = Color(red: 0.4627, green: 0.8392, blue: 1.0)  // Inactive status
    let statusPending = Color(red: 0.4627, green: 0.8392, blue: 1.0)    // Pending status
}

// MARK: - Dark Theme
struct DarkTheme: ColorTheme {
    let primary = Color(red: 0.4627, green: 0.8392, blue: 1.0)      // Primary brand color (slightly lighter)
    let secondary = Color(red: 0.4627, green: 0.8392, blue: 1.0)    // Secondary brand color (slightly lighter)
    let background = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // Black background
    let surface = Color(red: 0.4627, green: 0.8392, blue: 1.0)     // Dark surface
    let error = Color(red: 0.4627, green: 0.8392, blue: 1.0)        // Error red
    let success = Color(red: 0.4627, green: 0.8392, blue: 1.0)     // Success green
    let warning = Color(red: 0.4627, green: 0.8392, blue: 1.0)      // Warning orange
    
    let textPrimary = Color(red: 0.4627, green: 0.8392, blue: 1.0) // Primary text
    let textSecondary = Color(red: 0.4627, green: 0.8392, blue: 1.0) // Secondary text
    let textTertiary = Color(red: 0.4627, green: 0.8392, blue: 1.0)  // Tertiary text
    
    let buttonPrimary = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // Primary button
    let buttonSecondary = Color(red: 0.4627, green: 0.8392, blue: 1.0)  // Secondary button
    let buttonDisabled = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // Disabled button
    
    let statusActive = Color(red: 0.4627, green: 0.8392, blue: 1.0)     // Active status
    let statusInactive = Color(red: 0.4627, green: 0.8392, blue: 1.0)   // Inactive status
    let statusPending = Color(red: 0.4627, green: 0.8392, blue: 1.0)    // Pending status
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: ColorTheme
    
    init() {
        // Default to system appearance
        self.currentTheme = UITraitCollection.current.userInterfaceStyle == .dark ? DarkTheme() : LightTheme()
    }
    
    func updateTheme(for colorScheme: ColorScheme) {
        currentTheme = colorScheme == .dark ? DarkTheme() : LightTheme()
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
