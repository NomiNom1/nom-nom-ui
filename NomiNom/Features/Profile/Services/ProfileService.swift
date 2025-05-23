import Foundation

protocol ProfileServiceProtocol {
    func updateProfilePhoto(_ imageData: Data) async throws -> ProfilePhoto
    func updateUserProfile(firstName: String, lastName: String, phone: String) async throws -> User
    func deleteProfilePhoto() async throws
}

final class ProfileService: ProfileServiceProtocol {
    private let apiClient: APIClientProtocol
    private let logger = LoggingService.shared
    private let apiGatewayBaseURL = "https://jdzrq0u3e6.execute-api.us-east-1.amazonaws.com/test"
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func updateProfilePhoto(_ imageData: Data) async throws -> ProfilePhoto {
        // Step 1: Get pre-signed URL from API Gateway
        let fileName = "\(UUID().uuidString).jpg"
        let endpoint = APIEndpoint(
            path: "/images/upload",
            method: .get,
            headers: ["Content-Type": "application/json"],
            body: [
                "fileName": fileName,
                "contentType": "image/jpeg"
            ],
            category: "Profile",
            baseURL: apiGatewayBaseURL // Use API Gateway for S3 upload
        )
        
        let uploadResponse: ImageUploadResponse = try await apiClient.request(endpoint)
        
        // Step 2: Upload image to S3 using pre-signed URL
        var s3Request = URLRequest(url: URL(string: uploadResponse.uploadUrl)!)
        s3Request.httpMethod = "PUT"
        s3Request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        s3Request.httpBody = imageData
        
        let (_, s3Response) = try await URLSession.shared.data(for: s3Request)
        
        guard let httpResponse = s3Response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(500, "Failed to upload image to S3")
        }
        
        // Step 3: Update user profile with new image URL (using local API)
        let updateEndpoint = APIEndpoint(
            path: "/users/\(UserSessionManager.shared.currentUser?.id ?? "")",
            method: .put,
            headers: ["Content-Type": "application/json"],
            body: [
                "profilePhoto": [
                    "url": uploadResponse.imageUrl,
                    "thumbnailUrl": uploadResponse.imageUrl
                ]
            ],
            category: "Profile",
        )
        
        let updatedUser: User = try await apiClient.request(updateEndpoint)
        
        // Step 4: Return the profile photo information
        return updatedUser.profilePhoto ?? ProfilePhoto(url: uploadResponse.imageUrl, thumbnailUrl: uploadResponse.imageUrl)
    }
    
    func updateUserProfile(firstName: String, lastName: String, phone: String) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/users/\(UserSessionManager.shared.currentUser?.id ?? "")",
            method: .put,
            headers: ["Content-Type": "application/json"],
            body: [
                "firstName": firstName,
                "lastName": lastName,
                "phone": phone
            ],
            category: "Profile",
        )
        
        return try await apiClient.request(endpoint)
    }
    
    func deleteProfilePhoto() async throws {
        print("deleteProfilePhoto")
        // let endpoint = APIEndpoint(
        //     path: "/users/\(UserSessionManager.shared.currentUser?.id ?? "")",
        //     method: .put,
        //     headers: ["Content-Type": "application/json"],
        //     body: [
        //         "profilePhoto": nil
        //     ],
        //     category: "Profile",
        // )
        
        // _ = try await apiClient.request(endpoint) as User
    }
}

// MARK: - Supporting Types
struct ImageUploadResponse: Codable {
    let uploadUrl: String
    let imageUrl: String
    let imageId: String
} 