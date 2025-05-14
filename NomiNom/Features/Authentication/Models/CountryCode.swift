import Foundation

struct CountryCode: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let country: String
    
    static let availableCodes: [CountryCode] = [
        CountryCode(code: "+1", country: "US"),
        CountryCode(code: "+1", country: "CA"),
        CountryCode(code: "+1", country: "PR")
    ]
    
    var displayText: String {
        "\(code) (\(country))"
    }
} 