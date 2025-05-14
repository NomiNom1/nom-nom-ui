import SwiftUI

struct CategoryCardv1: View {
    let category: Category
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: category.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(themeManager.currentTheme.surface)
                    .overlay(
                        Image(systemName: category.iconName)
                            .font(.system(size: 30))
                            .foregroundColor(themeManager.currentTheme.primary)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.textPrimary)
        }
    }
} 