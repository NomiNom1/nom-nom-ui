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

#Preview {
    ProfileEditView()
        .environmentObject(ThemeManager())
} 
