import SwiftUI
import AppTrackingTransparency
import AuthenticationServices

struct SignInView: View {
    @StateObject private var coordinator = AuthenticationCoordinator()
    @StateObject private var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userSessionManager: UserSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var navigateToMain = false
    @State private var showPhoneVerification = false
    
    init() {
        let coordinator = AuthenticationCoordinator()
        _coordinator = StateObject(wrappedValue: coordinator)
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab Buttons
                    HStack {
                        ZStack(alignment: viewModel.isSignIn ? .leading : .trailing) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(themeManager.currentTheme.surface)
                                .frame(height: 44)

                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.currentTheme.buttonPrimary)
                                .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 36)
                                .padding(4)
                                .animation(.easeInOut(duration: 0.25), value: viewModel.isSignIn)

                            HStack(spacing: 0) {
                                Button(action: { viewModel.isSignIn = true }) {
                                    Text("Sign In")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .foregroundColor(viewModel.isSignIn ? .white : themeManager.currentTheme.textSecondary)
                                }

                                Button(action: { viewModel.isSignIn = false }) {
                                    Text("Sign Up")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .foregroundColor(!viewModel.isSignIn ? .white : themeManager.currentTheme.textSecondary)
                                }
                            }
                            .frame(height: 44)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            Text(viewModel.isSignIn ? "sign_in_header".localized : "sign_up_header".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                                .padding(.top, 16)
                            
                            // Social Sign-in Buttons
                            VStack(spacing: 12) {
                                SocialSignInButton(
                                    title: "continue_with_google".localized,
                                    icon: "g.circle.fill",
                                    action: { Task { await viewModel.signInWithGoogle() }}
                                )
                                .environmentObject(themeManager)
                                
                                SocialSignInButton(
                                    title: "continue_with_apple".localized,
                                    icon: "apple.logo",
                                    action: { Task { await viewModel.signInWithApple() }}
                                )
                                .environmentObject(themeManager)
                                
                                SocialSignInButton(
                                    title: "continue_with_facebook".localized,
                                    icon: "f.circle.fill",
                                    action: { Task { await viewModel.signInWithFacebook() }}
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
                            
                            if viewModel.isSignIn {
                                signInForm
                            } else {
                                signUpForm
                            }
                        }
                        .padding(.bottom, 32)
                    }
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
            .fullScreenCover(isPresented: $coordinator.navigateToMain) {
                MainTabView()
            }
            .sheet(isPresented: $showPhoneVerification) {
                PhoneVerificationView(
                    phoneNumber: viewModel.phoneNumber,
                    firstName: viewModel.firstName,
                    lastName: viewModel.lastName,
                    email: viewModel.email
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var signInForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("email_sign_in_header".localized)
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text("email_sign_in_subheader".localized)
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            TextField("email_placeholder".localized, text: $viewModel.email)
                .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.top, 8)
            
            SecureField("password_placeholder".localized, text: $viewModel.password)
                .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                .textContentType(.password)
                .padding(.top, 8)
            
            Button(action: {
                Task {
                    await viewModel.signIn()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("sign_in".localized)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(themeManager.currentTheme.buttonPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 16)
        }
        .padding(.horizontal)
    }
    
    private var signUpForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("create_account".localized)
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            TextField("first_name_placeholder".localized, text: $viewModel.firstName)
                .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                .textContentType(.givenName)
                .autocapitalization(.words)
                .padding(.top, 8)
            
            TextField("last_name_placeholder".localized, text: $viewModel.lastName)
                .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                .textContentType(.familyName)
                .autocapitalization(.words)
                .padding(.top, 8)
            
            TextField("email_placeholder".localized, text: $viewModel.email)
                .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.top, 8)
            
            HStack(spacing: 8) {
                Menu {
                    ForEach(CountryCode.availableCodes) { countryCode in
                        Button(countryCode.displayText) {
                            viewModel.selectedCountryCode = countryCode
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedCountryCode.displayText)
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                    }
                    .padding()
                    .frame(width: 120)
                    .background(themeManager.currentTheme.surface)
                    .cornerRadius(10)
                }
                
                TextField("phone_placeholder".localized, text: $viewModel.phoneNumber)
                    .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }
            .padding(.top, 8)
            
            Button(action: {
                Task {
                    await viewModel.startSignUp()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("sign_up".localized)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(themeManager.currentTheme.buttonPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 16)
        }
        .fullScreenCover(isPresented: $coordinator.navigateToMain) {
            MainTabView()
        }
        .padding(.horizontal)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : themeManager.currentTheme.textSecondary)
                .padding(.vertical, 12)
                .padding(.horizontal, 24) // 宽一点，比圆形略宽
                .background(
                    Capsule()
                        .fill(isSelected ? themeManager.currentTheme.buttonPrimary : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(themeManager.currentTheme.textTertiary.opacity(0.3), lineWidth: 1)
                        )
                )
        }
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
