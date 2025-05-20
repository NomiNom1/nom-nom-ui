import SwiftUI
import MapKit

struct LocationMapView: View {
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    
    @State private var region: MKCoordinateRegion
    @State private var annotation: MKPointAnnotation
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        // Initialize with a default region that will be updated
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        
        // Create the annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        _annotation = State(initialValue: annotation)
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [annotation]) { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        }
        .frame(height: 200)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - MKPointAnnotation Extension
extension MKPointAnnotation: Identifiable {
    public var id: String {
        "\(coordinate.latitude),\(coordinate.longitude)"
    }
} 