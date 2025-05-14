//
//  HomeView.swift
//  NomiNom
//
//  Created by Owen Murphy on 5/14/25.
//

import SwiftUI
import Combine

// MARK: - Models

// These would ideally be in their own files under Features/Home/Models
struct HomeRestaurant: Identifiable { // Example Model
    let id = UUID()
    let name: String
    let cuisine: String
    let rating: Double
    // Add an imageURL, and any other relevant restaurant properties
}

struct Category: Identifiable { // Example Model
    let id = UUID()
    let name: String
    let imageName: String
}

struct Order: Identifiable {  // Example Model
    let id = UUID()
    let restaurantName: String
    let orderNumber: String
    let status: String
}
