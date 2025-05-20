import SwiftUI

struct OrdersView: View {
    @StateObject private var coordinator = OrdersCoordinator()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Orders View Tab")
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

#Preview {
    OrdersView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 