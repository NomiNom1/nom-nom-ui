import Foundation
import Combine

enum UserSessionState {
    case signedOut
    case signedIn(User)
    case loading
}

final class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()
    
    @Published private(set) var sessionState: UserSessionState = .signedOut
    @Published private(set) var currentUser: User?
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
        setupSessionStateObserver()
    }
    
    private func setupSessionStateObserver() {
        $sessionState
            .map { state -> User? in
                if case .signedIn(let user) = state {
                    return user
                }
                return nil
            }
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func signIn(userId: String) async throws {
        sessionState = .loading
        do {
            let user = try await userService.fetchUser(id: userId)
            await MainActor.run {
                self.sessionState = .signedIn(user)
            }
        } catch {
            await MainActor.run {
                self.sessionState = .signedOut
            }
            throw error
        }
    }
    
    func signOut() {
        sessionState = .signedOut
        currentUser = nil
    }
    
    func refreshUserData() async throws {
        guard case .signedIn(let user) = sessionState else { return }
        do {
            let updatedUser = try await userService.fetchUser(id: user.id)
            await MainActor.run {
                self.sessionState = .signedIn(updatedUser)
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - User Data Access
    
    var isSignedIn: Bool {
        if case .signedIn = sessionState {
            return true
        }
        return false
    }
    
    var userFirstName: String? {
        currentUser?.firstName
    }
    
    var userLastName: String? {
        currentUser?.lastName
    }
    
    var userEmail: String? {
        currentUser?.email
    }
    
    var userPhone: String? {
        currentUser?.phone
    }
    
    var userOrderHistory: [String]? {
        currentUser?.orderHistory
    }
    
    var userDeliveryAddresses: [String]? {
        currentUser?.deliveryAddresses
    }
    
    var userPaymentMethods: [String]? {
        currentUser?.paymentMethods
    }
} 