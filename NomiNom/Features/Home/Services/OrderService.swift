import Foundation

protocol OrderServiceProtocol {
    func getRecentOrders() async throws -> [Order]
}

final class OrderService: OrderServiceProtocol {
    func getRecentOrders() async throws -> [Order] {
        // TODO: Implement actual API call
        return []
    }
} 