import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("language_settings".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(AppLanguage.allCases) { language in
                            HStack {
                                RadioButton(isSelected: languageManager.currentLanguage == language) {
                                    languageManager.currentLanguage = language
                                }
                                Text(language.displayName)
                                    .foregroundColor(themeManager.currentTheme.textPrimary)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                languageManager.currentLanguage = language
                            }
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .background(themeManager.currentTheme.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LanguageSettingsView()
        .environmentObject(ThemeManager())
} 