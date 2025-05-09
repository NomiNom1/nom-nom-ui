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

    init() {
        let currentTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? "system"
        _selectedTheme = State(initialValue: ThemeSetting(rawValue: currentTheme) ?? .system)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Choose Theme")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)

//                VStack(alignment: .leading) {
//                    ForEach(ThemeSetting.allCases) { theme in
//                        HStack {
//                            RadioButton(isSelected: selectedTheme == theme) {
//                                selectedTheme = theme
//                                UserDefaults.standard.set(theme.rawValue, forKey: "AppTheme")
//                                themeManager.applyTheme(theme) // Apply the theme
//                            }
//                            Text(theme.rawValue)
//                                .foregroundColor(.primary)
//                        }
//                        .padding(.bottom, 5) // Add some spacing between rows
//                    }
//                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Theme", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
//            .onAppear {
//                // Ensure the theme is applied on initial load of this view
//                themeManager.applyTheme(selectedTheme)
//            }
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
        .buttonStyle(PlainButtonStyle()) // To remove default button styling
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(ThemeManager())
}
