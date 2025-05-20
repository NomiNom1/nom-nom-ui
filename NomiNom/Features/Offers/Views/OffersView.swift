import SwiftUI

struct OffersView: View {
    @StateObject private var coordinator = OrdersCoordinator()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(){

            }
            ScrollView {
                VStack(spacing: 20) {
                    // Active Offers Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Offers View Tab")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical)
            }
            .background(themeManager.currentTheme.background)
            .navigationBarHidden(true)

        }
    }
}

#Preview {
    OffersView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 