import SwiftUI
import CoreLocation

struct LocationSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var userSessionManager = UserSessionManager.shared
    @StateObject private var viewModel = LocationSelectorViewModel()
    @StateObject private var coordinator = HomeCoordinator()
    @State private var selectedAddressType: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Back/Close and Address
                HStack {
                    Button(action: {
                        if viewModel.isSearching {
                            viewModel.clearSearch()
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: viewModel.isSearching ? "chevron.left" : "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(selectedAddressType.map { "Choose \($0) Address" } ?? "Address")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(" ")
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
                    TextField("Search for a location", text: $viewModel.searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(50)
                .padding(.horizontal)
                .padding(.top, 16)
                
                if viewModel.isSearching {
                    // Search Results
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(viewModel.searchResults) { prediction in
                                    Button(action: {
                                        print("Button pressed")
                                        if let addressType = selectedAddressType {
                                            coordinator.showAddressSaving(for: prediction, type: addressType)
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(prediction.structuredFormatting.mainText)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            Text(prediction.structuredFormatting.secondaryText)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    // Original Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Home and Work Tiles
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack() {
                                    Button(action: {
                                        selectedAddressType = "Home"
                                        viewModel.isSearching = true
                                    }) {
                                        VStack(alignment: .leading) {
                                            HStack() {
                                                Image(systemName: "house.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.blue)
                                                VStack(alignment: .leading) {
                                                    Text("Home")
                                                        .font(.headline)
                                                    Text("Set Address")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Divider
                                    Rectangle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 1, height: 30)
                                        .padding(.leading, 20)
                                    
                                    Button(action: {
                                        selectedAddressType = "Work"
                                        viewModel.isSearching = true
                                    }) {
                                        VStack(alignment: .leading) {
                                            HStack() {
                                                Image(systemName: "briefcase.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.blue)
                                                VStack(alignment: .leading) {
                                                    Text("Work")
                                                        .font(.headline)
                                                    Text("Set Address")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                    }
                                }
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
                            }
                            
                            // Current Location Section
                            if !locationManager.address.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Current Location")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(locationManager.address)
                                        .font(.body)
                                }
                                
                                // Nearby Locations Section
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Nearby")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    if viewModel.isLoadingNearby {
                                        ProgressView()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                    } else if viewModel.nearbyLocations.isEmpty {
                                        Text("No nearby locations found")
                                            .foregroundColor(.gray)
                                            .padding()
                                    } else {
                                        ForEach(viewModel.nearbyLocations) { prediction in
                                            Button(action: {
                                                if let addressType = selectedAddressType {
                                                    coordinator.showAddressSaving(for: prediction, type: addressType)
                                                }
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(prediction.structuredFormatting.mainText)
                                                        .font(.body)
                                                        .foregroundColor(.primary)
                                                    Text(prediction.structuredFormatting.secondaryText)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                                .padding(.vertical, 8)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Saved Addresses Section
                            if let savedAddresses = userSessionManager.userAddresses {
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
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .sheet(isPresented: $coordinator.showAddressSaving) {
            if let address = coordinator.selectedAddress,
               let type = coordinator.addressType {
                AddressSavingView(selectedAddress: address, addressType: type)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .addressSaved)) { _ in
            // Refresh the view model when an address is saved
            Task {
                await viewModel.refreshData()
            }
        }
    }
}

#Preview {
    LocationSelectorView()
}
