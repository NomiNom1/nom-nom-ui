import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    var body: some View {
        NavigationStack {
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

#Preview {
    ProfileEditView()
        .environmentObject(ThemeManager())
} 
