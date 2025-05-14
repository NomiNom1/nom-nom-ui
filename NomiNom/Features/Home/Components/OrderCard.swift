import SwiftUI

struct OrderCardv1: View {
    let order: Order
    let onReorder: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant Image
            AsyncImage(url: order.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(themeManager.currentTheme.surface)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            // Order Info
            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurantName)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Text("Order #\(order.orderNumber)")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Text(order.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.success)
            }
            
            Spacer()
            
            // Reorder Button
            Button(action: onReorder) {
                Text("reorder".localized)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.buttonPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.currentTheme.buttonPrimary.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(themeManager.currentTheme.surface)
        .cornerRadius(12)
    }
} 