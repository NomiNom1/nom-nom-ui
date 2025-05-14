import Foundation

protocol RestaurantServiceProtocol {
    func getFeaturedRestaurants() async throws -> [Restaurant]
}

final class RestaurantService: RestaurantServiceProtocol {
    func getFeaturedRestaurants() async throws -> [Restaurant] {
        // TODO: Implement actual API call
        return []
    }
} 