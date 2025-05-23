import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var address: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentDeliveryAddress: DeliveryAddress?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func setCurrentAddress(_ deliveryAddress: DeliveryAddress) {
        self.currentDeliveryAddress = deliveryAddress
        self.address = formatAddress(from: deliveryAddress)
        
        // Create a CLLocation from the coordinates
        if let coordinates = deliveryAddress.location.coordinates,
           coordinates.count >= 2 {
            let latitude = coordinates[1]
            let longitude = coordinates[0]
            self.location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    private func formatAddress(from deliveryAddress: DeliveryAddress) -> String {
        var components: [String] = []
        
        components.append(deliveryAddress.street)
        if let apartment = deliveryAddress.apartment {
            components.append(apartment)
        }
        components.append(deliveryAddress.city)
        components.append(deliveryAddress.state)
        components.append(deliveryAddress.zipCode)
        
        return components.joined(separator: ", ")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied access
            break
        case .notDetermined:
            // Wait for user to make a choice
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        // Only update address if we don't have a current delivery address
        if currentDeliveryAddress == nil {
            // Reverse geocode the location to get the address
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self,
                      let placemark = placemarks?.first,
                      error == nil else { return }
                
                DispatchQueue.main.async {
                    self.address = self.formatAddress(from: placemark)
                }
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let streetNumber = placemark.subThoroughfare {
            components.append(streetNumber)
        }
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.joined(separator: ", ")
    }
} 