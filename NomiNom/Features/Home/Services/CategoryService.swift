import Foundation

protocol CategoryServiceProtocol {
    func getPopularCategories() async throws -> [Category]
}

final class CategoryService: CategoryServiceProtocol {
    func getPopularCategories() async throws -> [Category] {
        // TODO: Implement actual API call
        return []
    }
} 