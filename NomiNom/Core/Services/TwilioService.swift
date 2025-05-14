import Foundation

protocol TwilioServiceProtocol {
    func sendVerificationCode(to phoneNumber: String) async throws -> String
    func verifyCode(phoneNumber: String, code: String) async throws -> Bool
}

final class TwilioService: TwilioServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        let endpoint = APIEndpoint(
            path: "/auth/send-verification",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: ["phoneNumber": phoneNumber]
        )
        
        let response: VerificationResponse = try await apiClient.request(endpoint)
        return response.verificationId
    }
    
    func verifyCode(phoneNumber: String, code: String) async throws -> Bool {
        let endpoint = APIEndpoint(
            path: "/auth/verify-code",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: [
                "phoneNumber": phoneNumber,
                "code": code
            ]
        )
        
        let response: VerificationResult = try await apiClient.request(endpoint)
        return response.isValid
    }
}

// Response models
private struct VerificationResponse: Codable {
    let verificationId: String
}

private struct VerificationResult: Codable {
    let isValid: Bool
} 