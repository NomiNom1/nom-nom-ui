import Foundation
import Combine
import CoreLocation

@MainActor
final class AddressSavingViewModel: ObservableObject {
    @Published var apartment: String = ""
    @Published var entryCode: String = ""
    @Published var buildingName: String = ""
    @Published var dropOffOptions: String = ""
    @Published var extraDescription: String = ""
    @Published var addressLabel: String = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var coordinate: CLLocationCoordinate2D?
    
    let selectedAddress: LocationPrediction
    let addressType: String // "Home" or "Work"
    
    private let geocodingService: GeocodingServiceProtocol
    
    init(
        selectedAddress: LocationPrediction,
        addressType: String,
        geocodingService: GeocodingServiceProtocol = GeocodingService()
    ) {
        self.selectedAddress = selectedAddress
        self.addressType = addressType
        self.geocodingService = geocodingService
        
        // Initialize with default address label
        self.addressLabel = addressType
        
        // Start geocoding the address
        Task {
            await geocodeAddress()
        }
    }
    
    private func geocodeAddress() async {
        isLoading = true
        do {
            let fullAddress = "\(selectedAddress.structuredFormatting.mainText), \(selectedAddress.structuredFormatting.secondaryText)"
            coordinate = try await geocodingService.geocode(address: fullAddress)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func saveAddress() async {
        // TODO: Implement address saving logic
        // This will be implemented later
    }
} 