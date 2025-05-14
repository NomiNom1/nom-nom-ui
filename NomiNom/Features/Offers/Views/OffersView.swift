import SwiftUI

struct OffersView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Active Offers Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("active_offers".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .padding(.horizontal)
                        
                        ForEach(0..<3) { _ in
                            OfferCard()
                        }
                    }
                    
                    // Expiring Soon Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("expiring_soon".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .padding(.horizontal)
                        
                        ForEach(0..<2) { _ in
                            OfferCard(isExpiring: true)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(themeManager.currentTheme.background)
            .navigationTitle("offers".localized)
        }
    }
}

struct OfferCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let isExpiring: Bool
    
    init(isExpiring: Bool = false) {
        self.isExpiring = isExpiring
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Offer Image
            Rectangle()
                .fill(themeManager.currentTheme.surface)
                .frame(height: 160)
                .overlay(
                    Image(systemName: "tag.fill")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.currentTheme.primary)
                )
            
            // Offer Details
            VStack(alignment: .leading, spacing: 8) {
                Text("20% off your first order")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text("Use code WELCOME20 at checkout")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                if isExpiring {
                    Text("expires_in_24h".localized)
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.warning)
                }
                
                Button(action: {
                    // Handle offer selection
                }) {
                    Text("use_offer".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.buttonPrimary)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(themeManager.currentTheme.surface)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    OffersView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 