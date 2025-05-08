import SwiftUI

struct ProfileView: View {
    // MARK: - Properties
    @State private var profileImage: Image = Image(systemName: "person.circle.fill")
    @State private var memberSince = "May 20"
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
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
                    }
                    .padding(.horizontal)
                    
                    // User Info Section
                    VStack(spacing: 8) {
                        Text("John Doe") // Replace with actual user name
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("NomiNom member since \(memberSince)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical)
                    
                    // Horizontal Scrolling Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ProfileButton(icon: "list.bullet", title: "Orders")
                            ProfileButton(icon: "gearshape.fill", title: "Settings")
                            ProfileButton(icon: "person.fill", title: "Profile")
                            ProfileButton(icon: "gift.fill", title: "Rewards")
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Me")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Supporting Views
struct ProfileButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: { /* Handle button tap */ }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
} 
