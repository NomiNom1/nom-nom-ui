import Foundation
import Combine
import OSLog

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
    private let keychainService: KeychainService
    private let logger = Logger(subsystem: "com.nominom.app", category: "UserSession")
    private var cancellables = Set<AnyCancellable>()
    private let refreshInterval: TimeInterval = 300 // 5 minutes
    private let tokenKey = "auth_tokens"
    private let userCacheKey = "cached_user_data"
    
    private init(
        userService: UserServiceProtocol = UserService(),
        keychainService: KeychainService = .shared
    ) {
        self.userService = userService
        self.keychainService = keychainService
        setupSessionStateObserver()
        Task {
            await restoreSession()
        }
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
    
    private func restoreSession() async {
        do {
            guard let tokensData = try? keychainService.load(key: tokenKey),
                  let tokens = try? JSONDecoder().decode(AuthTokens.self, from: tokensData) else {
                logger.info("No stored tokens found")
                return
            }
            
            if tokens.isExpired {
                logger.info("Stored tokens expired, attempting refresh")
                try await refreshTokens(tokens.refreshToken)
            } else {
                logger.info("Restoring session with valid tokens")
                try await fetchAndUpdateUser()
            }
        } catch {
            logger.error("Failed to restore session: \(error.localizedDescription)")
            await signOut()
        }
    }
    
    private func saveTokens(_ tokens: AuthTokens) throws {
        let data = try JSONEncoder().encode(tokens)
        try keychainService.save(key: tokenKey, data: data)
    }
    
    private func refreshTokens(_ refreshToken: String) async throws {
        // TODO: Implement token refresh API call
        // For now, we'll just sign out if tokens are expired
        throw NSError(domain: "com.nominom.app", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired"])
    }
    
    private func fetchAndUpdateUser() async throws {
        guard let tokensData = try? keychainService.load(key: tokenKey),
              let tokens = try? JSONDecoder().decode(AuthTokens.self, from: tokensData) else {
            throw NSError(domain: "com.nominom.app", code: 401, userInfo: [NSLocalizedDescriptionKey: "No valid session"])
        }
        
        // TODO: Use tokens.accessToken in API calls
        // For now, we'll use the cached user data
        if let userData = UserDefaults.standard.data(forKey: userCacheKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            await MainActor.run {
                self.sessionState = .signedIn(user)
                self.lastRefreshTime = Date()
            }
        }
    }
    
    // MARK: - Public Methods
    
    func signIn(userId: String) async throws {
        sessionState = .loading
        do {
            let user = try await userService.fetchUser(id: userId)
            
            // TODO: Get actual tokens from authentication service
            let tokens = AuthTokens(
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                expiresAt: Date().addingTimeInterval(3600)
            )
            
            try saveTokens(tokens)
            
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: userCacheKey)
            }
            
            await MainActor.run {
                self.sessionState = .signedIn(user)
                self.lastRefreshTime = Date()
            }

            // Start background refresh timer
            startBackgroundRefreshTimer()
        } catch {
            logger.error("Sign in failed: \(error.localizedDescription)")
            await MainActor.run {
                self.sessionState = .signedOut
            }
            throw error
        }
    }

    private func startBackgroundRefreshTimer() {
        // Cancel any existing timer
        cancellables.removeAll()

        // Create a timer that fires every refreshInterval
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.refreshUserData()
                }
            }
            .store(in: &cancellables)
    }
    
    func signOut() async {
        do {
            try keychainService.delete(key: tokenKey)
        } catch {
            logger.error("Failed to delete tokens: \(error.localizedDescription)")
        }
        
        UserDefaults.standard.removeObject(forKey: userCacheKey)
        UserDefaults.standard.removeObject(forKey: "lastRefreshTime")
        
        await MainActor.run {
            self.sessionState = .signedOut
            self.currentUser = nil
            self.lastRefreshTime = nil
        }
    }
    
    func refreshUserData() async throws {
        guard case .signedIn(let user) = sessionState else { return }
        
        if let lastRefresh = lastRefreshTime,
           Date().timeIntervalSince(lastRefresh) < refreshInterval {
            return // Use cached data if within refresh interval
        }
        
        do {
            let updatedUser = try await userService.fetchUser(id: user.id)
            if let userData = try? JSONEncoder().encode(updatedUser) {
                UserDefaults.standard.set(userData, forKey: userCacheKey)
            }
            
            await MainActor.run {
                self.sessionState = .signedIn(updatedUser)
                self.lastRefreshTime = Date()
            }
        } catch {
            logger.error("Failed to refresh user data: \(error.localizedDescription)")
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
    
    var userAddresses: [DeliveryAddress]? {
        currentUser?.addresses
    }
    
    var userPaymentMethods: [PaymentMethod]? {
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