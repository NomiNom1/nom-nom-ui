import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let type: NotificationType
    
    enum NotificationType {
        case promotion
        case order
        case system
    }
}

struct NotificationsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var notifications: [NotificationItem] = []
    
    // Dummy user data - in a real app, this would come from a user service
    private let userName = "John"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Greeting Section
                Text("notifications_greeting".localized.replacingOccurrences(of: "{name}", with: userName))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Notifications List
                LazyVStack(spacing: 16) {
                    ForEach(notifications) { notification in
                        NotificationCard(notification: notification)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(themeManager.currentTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("notifications_title".localized)
        .onAppear {
            loadDummyNotifications()
        }
    }
    
    private func loadDummyNotifications() {
        notifications = [
            NotificationItem(
                title: "notifications_promo_title".localized,
                description: "notifications_promo_description".localized,
                date: Date(),
                type: .promotion
            ),
            NotificationItem(
                title: "notifications_order_title".localized,
                description: "notifications_order_description".localized,
                date: Date().addingTimeInterval(-3600),
                type: .order
            ),
            NotificationItem(
                title: "notifications_system_title".localized,
                description: "notifications_system_description".localized,
                date: Date().addingTimeInterval(-7200),
                type: .system
            )
        ]
    }
}

struct NotificationCard: View {
    let notification: NotificationItem
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Spacer()
                
                Text(notification.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
            
            Text(notification.description)
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .lineLimit(2)
        }
        .padding()
        .background(themeManager.currentTheme.surface)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(ThemeManager())
            .environmentObject(LanguageManager.shared)
    }
} 