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
    @Published var isSaving = false
    @Published var saveError: Error?
    
    
    let selectedAddress: LocationPrediction
    let addressType: String // "Home" or "Work"
    
    private let geocodingService: GeocodingServiceProtocol
    private let addressService: AddressServiceProtocol
    private let coordinator: HomeCoordinator
    
    init(
        selectedAddress: LocationPrediction,
        addressType: String,
        geocodingService: GeocodingServiceProtocol = GeocodingService(),
        addressService: AddressServiceProtocol = AddressService(),
        coordinator: HomeCoordinator = HomeCoordinator()
    ) {
        self.selectedAddress = selectedAddress
        self.addressType = addressType
        self.geocodingService = geocodingService
        self.addressService = addressService
        self.coordinator = coordinator
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
        guard let user = UserSessionManager.shared.currentUser else {
            saveError = NSError(domain: "com.nominom.app", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not signed in"])
            return
        }

        isSaving = true
        saveError = nil

        do {
            // Parse address components from the selected address
            let components = selectedAddress.structuredFormatting.secondaryText.components(separatedBy: ", ")
            let city = components.first ?? ""
            let stateZip = components.last?.components(separatedBy: " ") ?? []
            let state = stateZip.first ?? ""
            let zipCode = stateZip.last ?? ""

            let address = AddressFromPlace(
                label: addressLabel.isEmpty ? nil : addressLabel,
                street: selectedAddress.structuredFormatting.mainText,
                city: city,
                state: state,
                zipCode: zipCode,
                country: "US",
                placeId: selectedAddress.placeId,
                addressType: addressLabel.lowercased() == "home" || addressLabel.lowercased() == "work" ? addressLabel.lowercased() : "custom",
                apartment: apartment.isEmpty ? nil : apartment,
                buildingName: buildingName.isEmpty ? nil : buildingName,
                entryCode: entryCode.isEmpty ? nil : entryCode,
                dropOffOptions: dropOffOptions.isEmpty ? nil : dropOffOptions,
                extraDescription: extraDescription.isEmpty ? nil : extraDescription
            )

            let savedAddress = try await addressService.saveAddressFromPlace(address: address)

            // Update user session with new address
            try await UserSessionManager.shared.refreshUserData()
            
            // Handle successful save through coordinator
            coordinator.handleAddressSaved()
        } catch {
            saveError = error
            print("saveError: \(saveError)")
            print("error: \(error)")
        }

        isSaving = false
    }
} 