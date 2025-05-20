import SwiftUI

final class HomeCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var showLocationSelector = false
    @Published var showNotifications = false
    @Published var showAddressSaving = false
    @Published var selectedAddress: LocationPrediction?
    @Published var addressType: String?
    
    func showAddressSaving(for address: LocationPrediction, type: String) {
        selectedAddress = address
        addressType = type
        showAddressSaving = true
    }
} 