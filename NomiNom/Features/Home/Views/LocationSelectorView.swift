import SwiftUI
import CoreLocation

struct LocationSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var userSessionManager = UserSessionManager.shared
    @State private var searchText = ""
    
    // Sample nearby addresses
    private let nearbyAddresses = [
        (street: "123 Main Street", city: "San Francisco, CA 94105, USA"),
        (street: "456 Market Street", city: "San Francisco, CA 94103, USA")
    ]
    
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Current Location Section
                        if !locationManager.address.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Current Location")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(locationManager.address)
                                    .font(.body)
                            }
                        }
                        
                        // Nearby Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Nearby")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(nearbyAddresses, id: \.street) { address in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(address.street)
                                        .font(.body)
                                    Text(address.city)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        // Saved Addresses Section
                        if let savedAddresses = userSessionManager.userDeliveryAddresses {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Saved Addresses")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                ForEach(savedAddresses, id: \.id) { address in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(address.street)
                                            .font(.body)
                                        Text("\(address.city), \(address.state) \(address.zipCode)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }

                        Button(action: {
                            Task {
                                await debug()
                            }
                        }) {
                            Text("Debug")
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
    }


    private func debug() async {
        print("userSessionManager.userDeliveryAddresses: \(userSessionManager)")
        print("userSessionManager.userDeliveryAddresses: \(userSessionManager.userDeliveryAddresses)")
        print("first name: \(userSessionManager.userFirstName)")
    }
}

#Preview {
    LocationSelectorView()
}
