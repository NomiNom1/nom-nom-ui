import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Profile Image Section
                    HStack {
                        Spacer()
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        Spacer()
                    }
                    .padding(.top)


                     HStack {
                        Spacer()
                        Text("Owen Murphy")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        Spacer()
                    }
                    
                    
                    // Profile Badge Section
                    NavigationLink(destination: ProfileBadgeView()) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Profile")
                                    .font(.headline)
                                    .foregroundColor(themeManager.currentTheme.textPrimary)
                                Text("Earn a profile badge")
                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(themeManager.currentTheme.surface)
                        .cornerRadius(10)
                    }
                    
                    // Additional Profile Settings
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Profile Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        
                        ProfileSettingRow(title: "Display Name", value: "John Doe")
                        ProfileSettingRow(title: "Email", value: "john.doe@example.com")
                        ProfileSettingRow(title: "Phone", value: "+1 (555) 123-4567")
                        ProfileSettingRow(title: "Location", value: "New York, NY")
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(themeManager.currentTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit Profile") {
                        // Handle edit profile action
                    }
                    .foregroundColor(themeManager.currentTheme.buttonPrimary)
                }
            }
        }
    }
}

struct ProfileSettingRow: View {
    let title: String
    let value: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            Spacer()
            Text(value)
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .padding()
        .background(themeManager.currentTheme.surface)
        .cornerRadius(10)
    }
}

struct ProfileBadgeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile Badges")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                // Badge Categories
                ForEach(BadgeCategory.allCases, id: \.self) { category in
                    BadgeCategorySection(category: category)
                }
            }
            .padding()
        }
        .background(themeManager.currentTheme.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BadgeCategorySection: View {
    let category: BadgeCategory
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 15) {
//                    ForEach(category.badges, id: \.self) { badge in
//                        BadgeView(badge: badge)
//                    }
//                }
//            }
        }
    }
}

struct BadgeView: View {
    let badge: Badge
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            Image(systemName: badge.icon)
                .font(.system(size: 30))
                .foregroundColor(badge.isUnlocked ? themeManager.currentTheme.buttonPrimary : .gray)
                .frame(width: 60, height: 60)
                .background(themeManager.currentTheme.surface)
                .clipShape(Circle())
            
            Text(badge.name)
                .font(.caption)
                .foregroundColor(themeManager.currentTheme.textPrimary)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

enum BadgeCategory: CaseIterable {
    case foodie
    case social
    case loyalty
    
    var title: String {
        switch self {
        case .foodie: return "Foodie Badges"
        case .social: return "Social Badges"
        case .loyalty: return "Loyalty Badges"
        }
    }
    
    var badges: [Badge] {
        switch self {
        case .foodie:
            return [
                Badge(name: "Food Explorer", icon: "fork.knife", isUnlocked: true),
                Badge(name: "Spice Master", icon: "flame.fill", isUnlocked: false),
                Badge(name: "Healthy Eater", icon: "leaf.fill", isUnlocked: false)
            ]
        case .social:
            return [
                Badge(name: "Review Pro", icon: "star.fill", isUnlocked: true),
                Badge(name: "Photo Expert", icon: "camera.fill", isUnlocked: false),
                Badge(name: "Community Leader", icon: "person.2.fill", isUnlocked: false)
            ]
        case .loyalty:
            return [
                Badge(name: "Regular", icon: "crown.fill", isUnlocked: true),
                Badge(name: "VIP", icon: "star.circle.fill", isUnlocked: false),
                Badge(name: "Elite", icon: "diamond.fill", isUnlocked: false)
            ]
        }
    }
}

struct Badge {
    let name: String
    let icon: String
    let isUnlocked: Bool
}

#Preview {
    ProfileEditView()
        .environmentObject(ThemeManager())
} 
