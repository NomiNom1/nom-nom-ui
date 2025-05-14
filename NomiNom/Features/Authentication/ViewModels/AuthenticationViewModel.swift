import Foundation
import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var isSignIn = true
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var selectedCountryCode: CountryCode = CountryCode(code: "+1", country: "US")
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showPhoneVerification = false
    @StateObject private var coordinator = AuthenticationCoordinator()

    
    private let authService: AuthenticationServiceProtocol
    private let userSessionManager: UserSessionManager
    
    init(
        authService: AuthenticationServiceProtocol = AuthenticationService(),
        userSessionManager: UserSessionManager = .shared
    ) {
        self.authService = authService
        self.userSessionManager = userSessionManager
    }
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        do {
            let userId = try await authService.signIn(email: email, password: password)
            try await userSessionManager.signIn(userId: userId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func startSignUp() async {
        guard validateSignUpFields() else { return }
        
        isLoading = true
        do {
            // Send verification code
            print("attempting to sign up")
            let user = try await authService.signUp(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phoneNumber: phoneNumber,
                    countryCode: "+1" // TODO: Make this dynamic based on country code
                )
            print("User signed up: \(user)")

            try await userSessionManager.signIn(userId: user.id)
            print("User signed in: \(user)")
            coordinator.navigateToMain = true
            // _ = try await authService.sendVerificationCode(to: phoneNumber)
            // showPhoneVerification = true
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        do {
            let userId = try await authService.signInWithGoogle()
            try await userSessionManager.signIn(userId: userId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        do {
            let userId = try await authService.signInWithApple()
            try await userSessionManager.signIn(userId: userId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signInWithFacebook() async {
        isLoading = true
        do {
            let userId = try await authService.signInWithFacebook()
            try await userSessionManager.signIn(userId: userId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func validateSignUpFields() -> Bool {
        guard !firstName.isEmpty else {
            showError = true
            errorMessage = "Please enter your first name"
            return false
        }
        
        guard !lastName.isEmpty else {
            showError = true
            errorMessage = "Please enter your last name"
            return false
        }
        
        guard !email.isEmpty else {
            showError = true
            errorMessage = "Please enter your email"
            return false
        }
        
        guard email.isValidEmail else {
            showError = true
            errorMessage = "Please enter a valid email"
            return false
        }
        
        guard !phoneNumber.isEmpty else {
            showError = true
            errorMessage = "Please enter your phone number"
            return false
        }
        
        guard phoneNumber.isValidPhoneNumber else {
            showError = true
            errorMessage = "Please enter a valid phone number"
            return false
        }
        
        return true
    }
}

// MARK: - Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var isValidPhoneNumber: Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self)
    }
}
