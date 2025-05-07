import SwiftUI
import AppTrackingTransparency
import AuthenticationServices

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    @State private var navigateToMain = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                Text("Sign in or create an account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                
                // Social Sign-in Buttons
                VStack(spacing: 12) {
                    SocialSignInButton(
                        title: "Continue with Google",
                        icon: "g.circle.fill",
                        action: { Task { await handleGoogleSignIn() }}
                    )
                    // SocialSignInButton(title: "Continue with Amazon", icon: "a.circle.fill")
                    // SocialSignInButton(title: "Continue with Apple", icon: "apple.logo")
                    // SocialSignInButton(title: "Continue with Facebook", icon: "f.circle.fill")
                    // SocialSignInButton(title: "Continue with WeChat", icon: "w.circle.fill")
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
                        navigateToMain = true
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
            .navigationDestination(isPresented: $navigateToMain) {
                MainTabView()
            }
        }
        //         .onAppear {
        //             ATTTrackingDialougue()
        //         }
    }

    private func handleGoogleSignIn() async {
        print("Sindie the ")
        do {
            try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct SocialSignInButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
