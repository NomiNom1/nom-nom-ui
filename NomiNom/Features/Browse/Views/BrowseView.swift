import SwiftUI

struct BrowseView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    private let categories = [
        "pizza", "burgers", "sushi", "chinese", "mexican",
        "italian", "indian", "thai", "vietnamese", "desserts"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    TextField("search_restaurants".localized, text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                        }
                    }
                }
                .padding()
                .background(themeManager.currentTheme.surface)
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category.localized,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            )
                        }
                    }
                    .padding()
                }
                .background(themeManager.currentTheme.background)
                
                // Restaurant List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<10) { _ in
                            RestaurantListItem()
                        }
                    }
                    .padding()
                }
                .background(themeManager.currentTheme.background)
            }
            .navigationTitle("browse".localized)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : themeManager.currentTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    themeManager.currentTheme.buttonPrimary :
                    themeManager.currentTheme.surface
                )
                .cornerRadius(20)
        }
    }
}

struct RestaurantListItem: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant Image
            Rectangle()
                .fill(themeManager.currentTheme.surface)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Restaurant Name")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text("Cuisine Type")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("4.5")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    Text("•")
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    Text("20-30 min")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }
            
            Spacer()
            
            // Delivery Fee
            Text("$2.99")
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .padding()
        .background(themeManager.currentTheme.surface)
        .cornerRadius(12)
    }
}

#Preview {
    BrowseView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager.shared)
} 