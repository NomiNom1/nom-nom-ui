import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
}

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let baseURL = "http://localhost:3000/api"
//    private let baseURL = "https://nom-nom-api-kkrd.onrender.com/api" // deployed
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = LoggingService.shared
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let startTime = Date()
        
        guard let url = URL(string: baseURL + endpoint.path) else {
            logger.error(
                "Invalid URL",
                category: "APIClient",
                metadata: ["path": endpoint.path]
            )
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        // Log request
        logger.debug(
            "Making API request",
            category: "APIClient",
            metadata: [
                "method": endpoint.method.rawValue,
                "path": endpoint.path,
                "headers": endpoint.headers,
                "body": endpoint.body as Any
            ]
        )
        
        do {
            let (data, response) = try await session.data(for: request)
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error(
                    "Invalid response type",
                    category: "APIClient",
                    metadata: ["response": String(describing: response)]
                )
                throw APIError.invalidResponse
            }
            
            // Log response
            logger.debug(
                "Received API response",
                category: "APIClient",
                metadata: [
                    "statusCode": httpResponse.statusCode,
                    "duration": duration,
                    "responseSize": data.count
                ]
            )
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    logger.info(
                        "Successfully decoded response",
                        category: "APIClient",
                        metadata: ["type": String(describing: T.self)]
                    )
                    return decodedResponse
                } catch {
                    logger.error(
                        "Failed to decode response",
                        category: "APIClient",
                        metadata: [
                            "error": error.localizedDescription,
                            "type": String(describing: T.self)
                        ]
                    )
                    throw APIError.decodingError(error)
                }
            case 401:
                logger.warning(
                    "Unauthorized request",
                    category: "APIClient",
                    metadata: ["path": endpoint.path]
                )
                throw APIError.unauthorized
            default:
                if let errorMessage = String(data: data, encoding: .utf8) {
                    logger.error(
                        "Server error",
                        category: "APIClient",
                        metadata: [
                            "statusCode": httpResponse.statusCode,
                            "error": errorMessage
                        ]
                    )
                    throw APIError.serverError(httpResponse.statusCode, errorMessage)
                }
                logger.error(
                    "Unknown server error",
                    category: "APIClient",
                    metadata: ["statusCode": httpResponse.statusCode]
                )
                throw APIError.serverError(httpResponse.statusCode, "Unknown error")
            }
        } catch let error as APIError {
            throw error
        } catch {
            logger.error(
                "Network error",
                category: "APIClient",
                metadata: ["error": error.localizedDescription]
            )
            throw APIError.networkError(error)
        }
    }
}
