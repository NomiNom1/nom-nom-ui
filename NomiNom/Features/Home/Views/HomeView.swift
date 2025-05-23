import SwiftUI

struct HomeView: View {
    @State private var showNotifications = false
    @StateObject private var coordinator = HomeCoordinator()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    @Binding var selectedTab: Int
    
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
                            
                            Text(locationManager.currentDeliveryAddress != nil ? "select_location".localized : locationManager.address)
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
                            Text("Home View Tab".localized)
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
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $coordinator.showLocationSelector) {
                LocationSelectorView(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 

