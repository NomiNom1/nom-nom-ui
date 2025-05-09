import SwiftUI
import AppTrackingTransparency
import AuthenticationServices

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isEmailValid = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    @State private var navigateToMain = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                Text("Sign in or create an account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .padding(.top, 32)
                
                // Social Sign-in Buttons
                VStack(spacing: 12) {
                    SocialSignInButton(
                        title: "Continue with Google",
                        icon: "g.circle.fill",
                        action: { Task { await handleGoogleSignIn() }}
                    )
                    .environmentObject(themeManager)
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
                        .foregroundColor(themeManager.currentTheme.textTertiary.opacity(0.3))
                    Text("OR")
                        .foregroundColor(themeManager.currentTheme.textTertiary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(themeManager.currentTheme.textTertiary.opacity(0.3))
                }
                .padding(.horizontal)
                
                // Email Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or get started with email")
                        .font(.headline)
                         .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    Text("If you already have an account, use your Grubhub or Seamless email")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of :email) { newValue in
                             isEmailValid = isValidEmail(newValue)
                        }
                        .padding(.top, 8)

                    // Button(action: {
                    //     navigateToMain = true
                    //     // Task {
                    //     //     await handleEmailSignIn()
                    //     // }
                    // }) {
                    //     if isLoading {
                    //         ProgressView()
                    //             .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    //     } else {
                    //         Text("Continue")
                    //             .font(.headline)
                    //     }
                    // }
                    // .padding()
                    // .background(isEmailValid ? themeManager.currentTheme.buttonPrimary : themeManager.currentTheme.buttonDisabled)
                    // .foregroundColor(.white)
                    // .cornerRadius(50)
                    // .disabled(!isEmailValid || isLoading)
                    // .padding(.top, 16)
                    
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
            .background(themeManager.currentTheme.background)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(themeManager.currentTheme.buttonPrimary)
                    }
                }
            }
            .fullScreenCover(isPresented: $navigateToMain) {
                MainTabView()
            }
        }
        //         .onAppear {
        //             ATTTrackingDialougue()
        //         }
    }

    private func handleGoogleSignIn() async {
        do {
            try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    let theme: ColorTheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(theme.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.textTertiary.opacity(0.3), lineWidth: 1)
            )
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
            .environmentObject(ThemeManager())
    }
}
