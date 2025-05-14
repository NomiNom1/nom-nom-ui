import Foundation
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isSignIn = true
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var selectedCountryCode: CountryCode = CountryCode.availableCodes[0]
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }
    
    func signIn() async {
        isLoading = true
        do {
            let userId = try await authService.signIn(email: email, password: password)
            // Handle successful sign in
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func signUp() async {
        isLoading = true
        do {
            let userId = try await authService.signUp(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                countryCode: selectedCountryCode.code
            )
            // Handle successful sign up
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        do {
            let userId = try await authService.signInWithGoogle()
            // Handle successful sign in
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        do {
            let userId = try await authService.signInWithApple()
            // Handle successful sign in
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func signInWithFacebook() async {
        isLoading = true
        do {
            let userId = try await authService.signInWithFacebook()
            // Handle successful sign in
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}