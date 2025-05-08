import SwiftUI
import CoreLocation

struct LocationSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Handle bar for dragging
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search for a location", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
    }
}

#Preview {
    LocationSelectorView()
} 