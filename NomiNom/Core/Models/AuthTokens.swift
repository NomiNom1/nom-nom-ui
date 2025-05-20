import Foundation

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }
}

extension AuthTokens {
    var isExpired: Bool {
        return Date() >= expiresAt
    }
    
    var willExpireSoon: Bool {
        // Consider token expired if it will expire in the next 5 minutes
        return Date().addingTimeInterval(300) >= expiresAt
    }
} 