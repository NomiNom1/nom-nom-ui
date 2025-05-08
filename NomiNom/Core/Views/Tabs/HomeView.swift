import SwiftUI

struct HomeView: View {
    @State private var showLocationSelector = false
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            VStack {
                // Location Selector Button
                Button(action: {
                    showLocationSelector = true
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        
                        Text(locationManager.address.isEmpty ? "Select location" : locationManager.address)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showLocationSelector) {
                LocationSelectorView()
            }
        }
    }
}

#Preview {
    HomeView()
} 
