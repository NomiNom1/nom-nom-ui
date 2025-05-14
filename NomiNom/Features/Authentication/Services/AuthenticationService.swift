import Foundation

protocol AuthenticationServiceProtocol {
    func signIn(email: String, password: String) async throws -> String
    func signUp(firstName: String, lastName: String, email: String, phoneNumber: String, countryCode: String) async throws -> User
    func signInWithGoogle() async throws -> String
    func signInWithApple() async throws -> String
    func signInWithFacebook() async throws -> String
    func sendVerificationCode(to phoneNumber: String) async throws -> String
    func verifyCode(phoneNumber: String, code: String) async throws -> Bool
}

class AuthenticationService: AuthenticationServiceProtocol {
    private let apiClient: APIClientProtocol
    private let twilioService: TwilioServiceProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared,
         twilioService: TwilioServiceProtocol = TwilioService()) {
        self.apiClient = apiClient
        self.twilioService = twilioService
    }
    
    func signIn(email: String, password: String) async throws -> String {
        // TODO: Implement actual authentication logic
        return "dummy_user_id"
    }
    
    func signUp(firstName: String, lastName: String, email: String, phoneNumber: String, countryCode: String) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/users",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "phone": phoneNumber
            ]
        )
        
        return try await apiClient.request(endpoint)
    }
    
    func signInWithGoogle() async throws -> String {
        // TODO: Implement Google Sign In
        return "dummy_user_id"
    }
    
    func signInWithApple() async throws -> String {
        // TODO: Implement Apple Sign In
        return "dummy_user_id"
    }
    
    func signInWithFacebook() async throws -> String {
        // TODO: Implement Facebook Sign In
        return "dummy_user_id"
    }
    
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        return try await twilioService.sendVerificationCode(to: phoneNumber)
    }
    
    func verifyCode(phoneNumber: String, code: String) async throws -> Bool {
        return try await twilioService.verifyCode(phoneNumber: phoneNumber, code: code)
    }
} 