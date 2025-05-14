import Foundation

struct Location: Codable {
    let type: String
    let coordinates: [Double]
}

struct DeliveryAddress: Codable {
    let location: Location
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let isDefault: Bool
    let id: String

    enum CodingKeys: String, CodingKey {
        case location
        case street
        case city
        case state
        case zipCode
        case isDefault
        case id = "_id"
    }
}

struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let orderHistory: [String]
    let deliveryAddresses: [DeliveryAddress]
    let paymentMethods: [String]
    let createdAt: String
    let updatedAt: String
    
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
    private let decoder: JSONDecoder
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchUser(id: String) async throws -> User {
        let endpoint = APIEndpoint.getUser(id: id)
        return try await apiClient.request(endpoint)
    }
} 
