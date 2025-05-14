import SwiftUI

final class HomeCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var showLocationSelector = false
    @Published var showNotifications = false
    
    func showRestaurantDetails(_ restaurant: Restaurant) {
        // TODO: Implement restaurant details navigation
    }
    
    func showCategoryDetails(_ category: Category) {
        // TODO: Implement category details navigation
    }
    
    func showOrderDetails(_ order: Order) {
        // TODO: Implement order details navigation
    }
    
    func showCart() {
        // TODO: Implement cart navigation
    }
} 