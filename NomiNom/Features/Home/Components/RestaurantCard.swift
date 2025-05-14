import SwiftUI

struct RestaurantCardv1: View {
    let restaurant: Restaurant
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant Image
            AsyncImage(url: restaurant.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(themeManager.currentTheme.surface)
            }
            .frame(width: 160, height: 120)
            .cornerRadius(8)
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text(restaurant.cuisineType)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }
        }
        .frame(width: 160)
    }
} 