//
//  AddressService.swift
//  NomiNom
//
//  Created by Owen Murphy on 5/22/25.
//

import Foundation

protocol AddressServiceProtocol {
    func saveAddressFromPlace(address: AddressFromPlace) async throws -> DeliveryAddress
}

struct AddressFromPlace: Codable {
    let label: String?
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let placeId: String
    let addressType: String
    let apartment: String?
    let buildingName: String?
    let entryCode: String?
    let dropOffOptions: String?
    let extraDescription: String?
}

final class AddressService: AddressServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func saveAddressFromPlace(address: AddressFromPlace) async throws -> DeliveryAddress {
        let endpoint = APIEndpoint.saveAddressFromPlace(
            userId: UserSessionManager.shared.currentUser?.id ?? "",
            address: address.dictionary
        )
        return try await apiClient.request(endpoint)
    }
}

// MARK: - Dictionary Extension
extension Encodable {
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }
}
