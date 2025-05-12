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
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: [String: Any]? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
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
            ]
        )
    }
} 