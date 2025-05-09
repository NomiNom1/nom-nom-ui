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
                Text("Dark Mode")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)

                Spacer()
            }
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
