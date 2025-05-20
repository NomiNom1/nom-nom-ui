import Foundation

struct LocationPrediction: Codable, Identifiable {
    let placeId: String
    let description: String
    let structuredFormatting: StructuredFormatting
    
    var id: String { placeId }
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case description
        case structuredFormatting = "structured_formatting"
    }
}

struct StructuredFormatting: Codable {
    let mainText: String
    let secondaryText: String
    
    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case secondaryText = "secondary_text"
    }
}

struct LocationSearchResponse: Codable {
    let predictions: [LocationPrediction]
}

protocol LocationSearchServiceProtocol {
    func searchLocations(query: String) async throws -> [LocationPrediction]
}

final class LocationSearchService: LocationSearchServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func searchLocations(query: String) async throws -> [LocationPrediction] {
        let endpoint = APIEndpoint(
            path: "/location/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            method: .get,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
        
        let response: LocationSearchResponse = try await apiClient.request(endpoint)
        return response.predictions
    }
} 
