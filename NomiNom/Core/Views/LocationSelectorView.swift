import SwiftUI
import CoreLocation

struct LocationSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with X and Address
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Address")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 32)
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 1)
                    .padding(.top, 8)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search for a location", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(50)
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Horizontal scroll view for Home and Work tiles
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Home Tile
                        VStack(alignment: .leading) {
                            HStack(spacing: 8) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Home")
                                        .font(.headline)
                                    Text("Set Address")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 4)
                            .padding(.trailing, 0)
                        }
                        .frame(width: 150)
                        
                        // Divider
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 50)
                            .padding(.horizontal, 8)
                        
                        // Work Tile
                        VStack(alignment: .leading) {
                            HStack(spacing: 8) {
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Work")
                                        .font(.headline)
                                    Text("Set Address")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 4)
                            .padding(.trailing, 12)
                        }
                        .frame(width: 180)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                
                // Current location button
                Button(action: {
                    locationManager.requestLocationPermission()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("Use current location")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                }
                
                // Current address if available
                if !locationManager.address.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Location")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text(locationManager.address)
                            .font(.body)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
    }
}

#Preview {
    LocationSelectorView()
}
