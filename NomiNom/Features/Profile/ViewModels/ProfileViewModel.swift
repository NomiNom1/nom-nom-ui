import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var user: User?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var memberSince: String = ""
    
    // MARK: - Dependencies
    private let userSessionManager: UserSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(userSessionManager: UserSessionManager = .shared) {
        self.userSessionManager = userSessionManager
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        userSessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
                if let createdAt = user?.createdAt {
                    self?.memberSince = self?.formatDate(createdAt) ?? ""
                }
            }
            .store(in: &cancellables)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = formatter.date(from: dateString) else { return "" }
        
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Public Methods
    func refreshUserData() async {
        isLoading = true
        do {
            try await userSessionManager.refreshUserData()
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func signOut() async {
        await userSessionManager.signOut()
    }
} 