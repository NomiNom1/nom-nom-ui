import Foundation
import Combine

@MainActor
final class PhoneVerificationViewModel: ObservableObject {
    @Published var verificationCode = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isResendEnabled = false
    @Published var resendCountdown = 60
    
    private let phoneNumber: String
    private let firstName: String
    private let lastName: String
    private let email: String
    private let authService: AuthenticationServiceProtocol
    private let userSessionManager: UserSessionManager
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        phoneNumber: String,
        firstName: String,
        lastName: String,
        email: String,
        authService: AuthenticationServiceProtocol = AuthenticationService(),
        userSessionManager: UserSessionManager = .shared
    ) {
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.authService = authService
        self.userSessionManager = userSessionManager
        
        startResendTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func verifyCode() async {
        guard verificationCode.count == 6 else { return }
        
        isLoading = true
        do {
            let isValid = try await authService.verifyCode(phoneNumber: phoneNumber, code: verificationCode)
            
            if isValid {
                // Create user account
                let user = try await authService.signUp(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phoneNumber: phoneNumber,
                    countryCode: "+1" // TODO: Make this dynamic based on country code
                )
                // Sign in the user
                try await userSessionManager.signIn(userId: user.id)
            } else {
                showError = true
                errorMessage = "Invalid verification code"
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func resendCode() async {
        isLoading = true
        do {
            _ = try await authService.sendVerificationCode(to: phoneNumber)
            startResendTimer()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func startResendTimer() {
        isResendEnabled = false
        resendCountdown = 60
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.resendCountdown > 0 {
                self.resendCountdown -= 1
            } else {
                self.isResendEnabled = true
                timer.invalidate()
            }
        }
    }
} 