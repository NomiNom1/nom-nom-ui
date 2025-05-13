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
    // @StateObject private var authService = AuthenticationService.shared
    @State private var navigateToMain = false
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full screen background
                themeManager.currentTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("sign_in_header".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .padding(.top, 16)
                        
                        // Social Sign-in Buttons
                        VStack(spacing: 12) {
                            SocialSignInButton(
                                title: "continue_with_google".localized,
                                icon: "g.circle.fill",
                                action: { Task { await handleGoogleSignIn() }}
                            )
                            .environmentObject(themeManager)
                            
                            SocialSignInButton(
                                title: "continue_with_apple".localized,
                                icon: "apple.logo",
                                action: { Task { await handleAppleSignIn() }}
                            )
                            .environmentObject(themeManager)
                            
                            SocialSignInButton(
                                title: "continue_with_facebook".localized,
                                icon: "f.circle.fill",
                                action: { Task { await handleFacebookSignIn() }}
                            )
                            .environmentObject(themeManager)
                        }
                        .padding(.horizontal)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(themeManager.currentTheme.textTertiary.opacity(0.3))
                            Text("or".localized)
                                .foregroundColor(themeManager.currentTheme.textTertiary)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(themeManager.currentTheme.textTertiary.opacity(0.3))
                        }
                        .padding(.horizontal)
                        
                        // Email Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("email_sign_in_header".localized)
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                            
                            Text("email_sign_in_subheader".localized)
                                .font(.subheadline)
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                            
                            TextField("email_placeholder".localized, text: $email)
                                .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .onChange(of: email) { newValue in
                                    isEmailValid = isValidEmail(newValue)
                                }
                                .padding(.top, 8)
                            
                            Button(action: {
                                navigateToMain = true
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("continue".localized)
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isEmailValid ? themeManager.currentTheme.buttonPrimary : themeManager.currentTheme.buttonDisabled)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!isEmailValid || isLoading)
                            .padding(.top, 16)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
            }
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
            print("Google sign in")
            // try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handleAppleSignIn() async {
        // Implement Apple Sign In
    }
    
    private func handleFacebookSignIn() async {
        // Implement Facebook Sign In
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
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .foregroundColor(themeManager.currentTheme.textPrimary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(themeManager.currentTheme.surface)
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(ThemeManager())
            .environmentObject(LanguageManager.shared)
            .environmentObject(UserSessionManager.shared)
    }
}
