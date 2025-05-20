import Foundation
import Combine

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
    
    let selectedAddress: LocationPrediction
    let addressType: String // "Home" or "Work"
    
    init(selectedAddress: LocationPrediction, addressType: String) {
        self.selectedAddress = selectedAddress
        self.addressType = addressType
    }
    
    func saveAddress() async {
        // TODO: Implement address saving logic
        // This will be implemented later
    }
} 