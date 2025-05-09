import SwiftUI

enum ThemeSetting: String, CaseIterable, Identifiable {
    case on = "On"
    case off = "Off"
    case system = "System Settings"
    
    var id: Self { self }
}

struct ThemeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTheme: ThemeSetting
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        let currentTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? "system"
        _selectedTheme = State(initialValue: ThemeSetting(rawValue: currentTheme) ?? .system)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Theme Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // Light Mode Option
                        HStack {
                            RadioButton(isSelected: selectedTheme == .off) {
                                selectedTheme = .off
                                updateTheme()
                            }
                            Text("Light")
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = .off
                            updateTheme()
                        }
                        
                        // Dark Mode Option
                        HStack {
                            RadioButton(isSelected: selectedTheme == .on) {
                                selectedTheme = .on
                                updateTheme()
                            }
                            Text("Dark")
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = .on
                            updateTheme()
                        }
                        
                        // System Settings Option
                        HStack {
                            RadioButton(isSelected: selectedTheme == .system) {
                                selectedTheme = .system
                                updateTheme()
                            }
                            Text("System Settings")
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = .system
                            updateTheme()
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
    
    private func updateTheme() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "AppTheme")
        
        switch selectedTheme {
        case .on:
            themeManager.updateTheme(for: .dark)
        case .off:
            themeManager.updateTheme(for: .light)
        case .system:
            themeManager.updateTheme(for: colorScheme)
        }
    }
}

struct RadioButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(isSelected ? themeManager.currentTheme.primary : themeManager.currentTheme.surface)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(themeManager.currentTheme.primary, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(ThemeManager())
        .preferredColorScheme(.light)
}
