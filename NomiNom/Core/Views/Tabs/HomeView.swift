import SwiftUI

struct HomeView: View {
    @State private var showLocationSelector = false
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Bar with Location and Action Icons
                HStack {
                    // Location Selector
                    Button(action: {
                        showLocationSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                            
                            Text(locationManager.address.isEmpty ? "Select location" : locationManager.address)
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                    
                    Spacer()
                    
                    // Action Icons
                    HStack(spacing: 16) {
                        Button(action: {
                            // Handle notifications
                        }) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.primary)
                                .font(.system(size: 20))
                        }
                        
                        Button(action: {
                            // Handle cart
                        }) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.primary)
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLocationSelector) {
                LocationSelectorView()
            }
        }
    }
}

#Preview {
    HomeView()
} 
