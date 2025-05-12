import Foundation

struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let orderHistory: [String]
    let deliveryAddresses: [String]
    let paymentMethods: [String]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
        case phone
        case orderHistory
        case deliveryAddresses
        case paymentMethods
        case createdAt
        case updatedAt
    }
}

protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User
}

final class UserService: UserServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchUser(id: String) async throws -> User {
        let endpoint = APIEndpoint.getUser(id: id)
        return try await apiClient.request(endpoint)
    }
} 