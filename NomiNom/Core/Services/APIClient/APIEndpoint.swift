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
    let requiresAuth: Bool
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: [String: Any]? = nil,
        category: String = "API",
        requiresAuth: Bool = false
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.category = category
        self.requiresAuth = requiresAuth
    }
    
    var logMetadata: [String: Any] {
        var metadata: [String: Any] = [
            "path": path,
            "method": method.rawValue,
            "category": category,
            "requiresAuth": requiresAuth
        ]
        
        if let body = body {
            metadata["body"] = body
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
            requiresAuth: true
        )
    }
} 