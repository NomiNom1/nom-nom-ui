import SwiftUI

struct BrowseView: View {
    @StateObject private var coordinator = BrowseCoordinator()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager

    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Browse View Tab")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .background(themeManager.currentTheme.background)
            }
            .navigationBarHidden(true)

        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : themeManager.currentTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    themeManager.currentTheme.buttonPrimary :
                    themeManager.currentTheme.surface
                )
                .cornerRadius(20)
        }
    }
}

#Preview {
    BrowseView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 