import Foundation
import CoreLocation

protocol GeocodingServiceProtocol {
    func geocode(address: String) async throws -> CLLocationCoordinate2D
}

final class GeocodingService: GeocodingServiceProtocol {
    private let geocoder = CLGeocoder()
    
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            guard let location = placemarks.first?.location?.coordinate else {
                throw NSError(domain: "com.nominom.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "Location not found"])
            }
            return location
        } catch {
            throw error
        }
    }
} 