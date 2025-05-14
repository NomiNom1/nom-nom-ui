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
    @Published private(set) var lastRefreshTime: Date?
    
    private let userService: UserServiceProtocol
    private let userDefaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()
    private let refreshInterval: TimeInterval = 300 // 5 minutes
    private let cacheKey = "cachedUserData"
    
    private init(userService: UserServiceProtocol = UserService(), userDefaults: UserDefaults = .standard) {
        self.userService = userService
        self.userDefaults = userDefaults
        setupSessionStateObserver()
        loadCachedUserData()
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
    
    private func loadCachedUserData() {
        if let data = userDefaults.data(forKey: cacheKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.sessionState = .signedIn(user)
            self.lastRefreshTime = userDefaults.object(forKey: "lastRefreshTime") as? Date
        }
    }
    
    private func cacheUserData(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: cacheKey)
            userDefaults.set(Date(), forKey: "lastRefreshTime")
            self.lastRefreshTime = Date()
        }
    }
    
    // MARK: - Public Methods
    
    func signIn(userId: String) async throws {
        sessionState = .loading
        do {
            let user = try await userService.fetchUser(id: userId)
            await MainActor.run {
                self.sessionState = .signedIn(user)
                self.cacheUserData(user)
            }
        } catch {
            await MainActor.run {
                self.sessionState = .signedOut
                self.userDefaults.removeObject(forKey: cacheKey)
                self.userDefaults.removeObject(forKey: "lastRefreshTime")
            }
            throw error
        }
    }
    
    func signOut() {
        sessionState = .signedOut
        currentUser = nil
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: "lastRefreshTime")
    }
    
    func refreshUserData() async throws {
        guard case .signedIn(let user) = sessionState else { return }
        
        // Check if we need to refresh based on time interval
        if let lastRefresh = lastRefreshTime,
           Date().timeIntervalSince(lastRefresh) < refreshInterval {
            return // Use cached data if within refresh interval
        }
        
        do {
            let updatedUser = try await userService.fetchUser(id: user.id)
            await MainActor.run {
                self.sessionState = .signedIn(updatedUser)
                self.cacheUserData(updatedUser)
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
    
    var userDeliveryAddresses: [DeliveryAddress]? {
        currentUser?.deliveryAddresses
    }
    
    var userPaymentMethods: [String]? {
        currentUser?.paymentMethods
    }
    
    // MARK: - User Preferences
    
    func updateUserPreferences(_ preferences: [String: Any]) async throws {
        guard case .signedIn(let user) = sessionState else { return }
        // Implement user preferences update
        // This would typically make an API call to update user preferences
        // For now, we'll just refresh the user data
        try await refreshUserData()
    }
} 