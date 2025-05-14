import Foundation

struct Order: Identifiable {
    let id: String
    let restaurantId: String
    let restaurantName: String
    let orderNumber: String
    let status: OrderStatus
    let date: Date
    let total: Double
    let imageURL: URL?
    
    enum OrderStatus: String {
        case delivered
        case inProgress
        case cancelled
    }
} 