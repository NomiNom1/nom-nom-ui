import SwiftUI

struct OrdersView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                HStack {
                    OrdersTabButton(
                        title: "active_orders".localized,
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    OrdersTabButton(
                        title: "past_orders".localized,
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                }
                .padding()
                .background(themeManager.currentTheme.surface)
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == 0 {
                            // Active Orders
                            ForEach(0..<2) { _ in
                                ActiveOrderCard()
                            }
                        } else {
                            // Past Orders
                            ForEach(0..<5) { _ in
                                PastOrderCard()
                            }
                        }
                    }
                    .padding()
                }
                .background(themeManager.currentTheme.background)
            }
            .navigationTitle("orders".localized)
        }
    }
}

struct OrdersTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? themeManager.currentTheme.buttonPrimary : themeManager.currentTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    themeManager.currentTheme.buttonPrimary.opacity(0.1) :
                    Color.clear
                )
                .cornerRadius(8)
        }
    }
}

struct ActiveOrderCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Restaurant Info
            HStack {
                Rectangle()
                    .fill(themeManager.currentTheme.surface)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Restaurant Name")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    Text("Order #12345")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
                
                Spacer()
                
                Text("preparing".localized)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.statusPending)
            }
            
            // Order Progress
            VStack(spacing: 8) {
                ProgressView(value: 0.6)
                    .tint(themeManager.currentTheme.buttonPrimary)
                
                HStack {
                    Text("estimated_delivery".localized)
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    Spacer()
                    
                    Text("20-30 min")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                }
            }
            
            // Action Buttons
            HStack {
                Button(action: {
                    // Handle contact restaurant
                }) {
                    Text("contact_restaurant".localized)
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.buttonPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.buttonPrimary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Handle track order
                }) {
                    Text("track_order".localized)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.buttonPrimary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.surface)
        .cornerRadius(12)
    }
}

struct PastOrderCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant Image
            Rectangle()
                .fill(themeManager.currentTheme.surface)
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            
            // Order Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Restaurant Name")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text("Order #12345")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Text("delivered".localized)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.success)
            }
            
            Spacer()
            
            // Reorder Button
            Button(action: {
                // Handle reorder
            }) {
                Text("reorder".localized)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.buttonPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.currentTheme.buttonPrimary.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(themeManager.currentTheme.surface)
        .cornerRadius(12)
    }
}

#Preview {
    OrdersView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 