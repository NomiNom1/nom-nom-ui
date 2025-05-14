import Foundation

struct Restaurant: Identifiable {
    let id: String
    let name: String
    let cuisineType: String
    let rating: Double
    let imageURL: URL?
    let deliveryTime: Int
    let deliveryFee: Double
    let minimumOrder: Double
    let isOpen: Bool
    
    // Additional properties can be added as needed
} 