import SwiftUI

struct ProfileView: View {
    // MARK: - Properties
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    @State private var memberSince = "May 20"
    @EnvironmentObject private var userSessionManager: UserSessionManager
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    // Top Bar with Profile Picture and Icons
                    HStack {
                        Spacer()
                        
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Button(action: { /* Handle notifications */ }) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: { /* Handle cart */ }) {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)
                    
                    // User Info Section
                    VStack(spacing: 4) {
                        if let user = userSessionManager.currentUser {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            Text("Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Loading...")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("NomiNom member since \(memberSince)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical)
                    
                    // Horizontal Scrolling Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ProfileButton(icon: "list.bullet", title: "Orders")
                            NavigationLink(destination: SettingsView()) {
                                ProfileButtonContent(icon: "list.bullet", title: "Orders")
                            }
                            NavigationLink(destination: SettingsView()) {
                                ProfileButtonContent(icon: "gearshape.fill", title: "Settings")
                            }
                            NavigationLink(destination: SettingsView()) {
                                ProfileButtonContent(icon: "person.fill", title: "Profile")
                            }
                            NavigationLink(destination: SettingsView()) {
                                ProfileButtonContent(icon: "gift.fill", title: "Rewards")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Me")
            .navigationBarHidden(true)
            .task {
                if !userSessionManager.isSignedIn {
                    do {
                        try await userSessionManager.signIn(userId: "6820d662bdc2a39900706b74")
                    } catch {
                        print("Error signing in: \(error)")
                    }
                }
            }
        }
    }
}

// Separate struct for the button content to avoid issues with NavigationLink
struct ProfileButtonContent: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primary)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(50)
    }
}

// MARK: - Supporting Views
struct ProfileButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        // Use ProfileButtonContent inside NavigationLink in ProfileView
        EmptyView() // This struct is now just a wrapper for styling in the horizontal scroll
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserSessionManager.shared)
}
