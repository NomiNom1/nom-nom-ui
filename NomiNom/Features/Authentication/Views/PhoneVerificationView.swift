import SwiftUI

struct PhoneVerificationView: View {
    @StateObject private var viewModel: PhoneVerificationViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var navigateToMain = false
    
    init(phoneNumber: String, firstName: String, lastName: String, email: String) {
        _viewModel = StateObject(wrappedValue: PhoneVerificationViewModel(
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            email: email
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("verify_phone".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    Text("enter_verification_code".localized)
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Verification Code Input
                VStack(spacing: 16) {
                    TextField("verification_code".localized, text: $viewModel.verificationCode)
                        .textFieldStyle(CustomTextFieldStyle(theme: themeManager.currentTheme))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.horizontal)
                    
                    if viewModel.isResendEnabled {
                        Button(action: {
                            Task {
                                await viewModel.resendCode()
                            }
                        }) {
                            Text("resend_code".localized)
                                .foregroundColor(themeManager.currentTheme.buttonPrimary)
                        }
                    } else {
                        Text("resend_in".localized + " \(viewModel.resendCountdown)s")
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Verify Button
                Button(action: {
                    Task {
                        await viewModel.verifyCode()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("verify".localized)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.currentTheme.buttonPrimary)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(viewModel.verificationCode.count != 6 || viewModel.isLoading)
            }
            .padding()
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
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    PhoneVerificationView(
        phoneNumber: "+1234567890",
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com"
    )
    .environmentObject(ThemeManager())
    .environmentObject(LanguageManager.shared)
} 