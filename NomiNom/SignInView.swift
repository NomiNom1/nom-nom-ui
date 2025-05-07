import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Sign in or create an account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                
                // Social Sign-in Buttons
                VStack(spacing: 12) {
                    SocialSignInButton(title: "Continue with Google", icon: "g.circle.fill")
                    SocialSignInButton(title: "Continue with Amazon", icon: "a.circle.fill")
                    SocialSignInButton(title: "Continue with Apple", icon: "apple.logo")
                    SocialSignInButton(title: "Continue with Facebook", icon: "f.circle.fill")
                    SocialSignInButton(title: "Continue with WeChat", icon: "w.circle.fill")
                }
                .padding(.horizontal)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("OR")
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal)
                
                // Email Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or get started with email")
                        .font(.headline)
                    
                    Text("If you already have an account, use your Grubhub or Seamless email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.top, 8)
                    
                    Button(action: {
                        // Handle continue action
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct SocialSignInButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Handle social sign-in
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
} 