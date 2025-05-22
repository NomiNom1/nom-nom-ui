import SwiftUI

final class HomeCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var showLocationSelector = false
    @Published var showNotifications = false
    @Published var showAddressSaving = false
    @Published var selectedAddress: LocationPrediction?
    @Published var addressType: String?
    
    // MARK: - Navigation Methods
    
    func showAddressSaving(for address: LocationPrediction, type: String) {
        selectedAddress = address
        addressType = type
        showAddressSaving = true
    }
    
    func dismissAddressSaving() {
        showAddressSaving = false
        selectedAddress = nil
        addressType = nil
    }
    
    func handleAddressSaved() {
        // Dismiss the address saving sheet
        dismissAddressSaving()
        
        // Refresh the location selector view
        // This will trigger a refresh of the saved addresses
        NotificationCenter.default.post(name: .addressSaved, object: nil)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let addressSaved = Notification.Name("addressSaved")
} 