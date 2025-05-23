import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: [String: Any]?
    let category: String
    let baseURL: String?
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: [String: Any]? = nil,
        category: String = "API",
        baseURL: String? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.category = category
        self.baseURL = baseURL
    }
    
    var logMetadata: [String: Any] {
        var metadata: [String: Any] = [
            "path": path,
            "method": method.rawValue,
            "category": category,
        ]
        
        if let body = body {
            metadata["body"] = body
        }
        
        if let baseURL = baseURL {
            metadata["baseURL"] = baseURL
        }
        
        return metadata
    }
}

// MARK: - User Endpoints
extension APIEndpoint {
    static func getUser(id: String) -> APIEndpoint {
        APIEndpoint(
            path: "/users/\(id)",
            method: .get,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            category: "User",
        )
    }
}

// MARK: - Address Endpoints
extension APIEndpoint {
    static func saveAddressFromPlace(userId: String, address: [String: Any]) -> APIEndpoint {
        APIEndpoint(
            path: "/addresses/from-places",
            method: .post,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "x-user-id": userId
            ],
            body: address
        )
    }
}
