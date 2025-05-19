import SwiftUI

struct HomeView: View {
    @State private var showNotifications = false
    @StateObject private var coordinator = HomeCoordinator()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 0) {
                // Top Bar with Location and Action Icons
                HStack {
                    // Location Selector
                    Button(action: {
                        coordinator.showLocationSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .foregroundColor(themeManager.currentTheme.primary)
                                .font(.system(size: 16))
                            
                            Text(locationManager.address.isEmpty ? "select_location".localized : locationManager.address)
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                                .font(.system(size: 12))
                        }
                    }
                    
                    Spacer()
                    
                    // Action Icons
                    HStack(spacing: 16) {
                        NavigationLink(destination: NotificationsView()) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .font(.system(size: 20))
                        }
                        
                        Button(action: {
                            // Handle cart
                        }) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(themeManager.currentTheme.surface)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Featured Restaurants
                        VStack(alignment: .leading, spacing: 12) {
                            Text("featured_restaurants".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<5) { _ in
                                        RestaurantCard()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Popular Categories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("popular_categories".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<5) { _ in
                                        CategoryCard()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent Orders
                        VStack(alignment: .leading, spacing: 12) {
                            Text("recent_orders".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(0..<3) { _ in
                                    OrderCard()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .background(themeManager.currentTheme.background)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $coordinator.showLocationSelector) {
                LocationSelectorView()
            }
        }
    }
}

struct RestaurantCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant Image
            Rectangle()
                .fill(themeManager.currentTheme.surface)
                .frame(width: 160, height: 120)
                .cornerRadius(8)
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Restaurant Name")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text("Cuisine Type")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("4.5")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }
        }
        .frame(width: 160)
    }
}

struct CategoryCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(themeManager.currentTheme.surface)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 30))
                        .foregroundColor(themeManager.currentTheme.primary)
                )
            
            Text("Category")
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.textPrimary)
        }
    }
}

struct OrderCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant Image
            Rectangle()
                .fill(themeManager.currentTheme.surface)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            // Order Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Restaurant Name")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text("Order #12345")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Text("Delivered")
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
    HomeView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 

