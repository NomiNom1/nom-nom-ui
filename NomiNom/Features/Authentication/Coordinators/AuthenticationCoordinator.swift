//
//  AuthenticationCoordinator.swift
//  NomiNom
//
//  Created by Owen Murphy on 5/14/25.
//

import SwiftUI

final class AuthenticationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var navigateToMain = false
    
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