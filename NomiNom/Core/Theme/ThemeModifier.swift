import SwiftUI

struct ThemeModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onChange(of: colorScheme) { newColorScheme in
                themeManager.updateTheme(for: newColorScheme)
            }
    }
}

extension View {
    func withTheme() -> some View {
        self.modifier(ThemeModifier())
    }
} 
