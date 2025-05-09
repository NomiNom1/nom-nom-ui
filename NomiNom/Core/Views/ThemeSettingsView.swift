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
                    Text("Dark Mode")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            
                            
                            RadioButton(isSelected: selectedTheme == ThemeSetting.on) {
                                selectedTheme = ThemeSetting.on
                            }
                            Text("Light")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        HStack {
                            
                            
                            RadioButton(isSelected: selectedTheme == ThemeSetting.off) {
                                selectedTheme = ThemeSetting.off
                            }
                            Text("Dark")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom)
                }
                
                // List {
                //     Section {
                //         // On Button
                //         HStack {
                //             RadioButton(isSelected: selectedTheme == .on) {
                //                 selectedTheme = .on
                //                 updateTheme()
                //             }
                
                //             Text("On")
                //                 .foregroundColor(.primary)
                
                //             Spacer()
                //         }
                //         .contentShape(Rectangle())
                //         .onTapGesture {
                //             selectedTheme = .on
                //             updateTheme()
                //         }
                
                //         // Off Button
                //         HStack {
                //             RadioButton(isSelected: selectedTheme == .off) {
                //                 selectedTheme = .off
                //                 updateTheme()
                //             }
                
                //             Text("Off")
                //                 .foregroundColor(.primary)
                
                //             Spacer()
                //         }
                //         .contentShape(Rectangle())
                //         .onTapGesture {
                //             selectedTheme = .off
                //             updateTheme()
                //         }
                
                //         // System Settings Button
                //         HStack {
                //             RadioButton(isSelected: selectedTheme == .system) {
                //                 selectedTheme = .system
                //                 updateTheme()
                //             }
                
                //             Text("System Settings")
                //                 .foregroundColor(.primary)
                
                //             Spacer()
                //         }
                //         .contentShape(Rectangle())
                //         .onTapGesture {
                //             selectedTheme = .system
                //             updateTheme()
                //         }
                //     }
                // }
                // .navigationTitle("Dark Mode")
                // .navigationBarTitleDisplayMode(.inline)
            }
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
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.3))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
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
