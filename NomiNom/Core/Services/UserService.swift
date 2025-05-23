import Foundation

struct Location: Codable {
    let type: String
    let coordinates: [Double]?
}

struct DropOffOptions: Codable {
    let handItToMe: Bool
    let leaveAtDoor: Bool
}

struct DeliveryAddress: Codable {
    let id: String
    let label: String
    let street: String
    let apartment: String?
    let buildingName: String?
    let entryCode: String?
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let location: Location
    let dropOffOptions: DropOffOptions
    let instructions: String?
    let isDefault: Bool
    let addressType: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case label
        case street
        case apartment
        case buildingName
        case entryCode
        case city
        case state
        case zipCode
        case country
        case location
        case dropOffOptions
        case instructions
        case isDefault
        case addressType
        case createdAt
        case updatedAt
    }
}

struct ProfilePhoto: Codable {
    let url: String
    let thumbnailUrl: String?
}

struct PaymentMethod: Codable {
    let type: String
    let cardNumber: String
    let expiryDate: String
    let cardHolderName: String
    let isDefault: Bool
}

struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let countryCode: String
    let profilePhoto: ProfilePhoto?
    let addresses: [DeliveryAddress]
    let paymentMethods: [PaymentMethod]
    let orderHistory: [String]
    let createdAt: String
    let updatedAt: String
    let version: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
        case phone
        case countryCode
        case profilePhoto
        case addresses
        case paymentMethods
        case orderHistory
        case createdAt
        case updatedAt
        case version = "__v"
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
