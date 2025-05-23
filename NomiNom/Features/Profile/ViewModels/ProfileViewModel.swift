import Foundation
import Combine
import SwiftUI
import PhotosUI

final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var user: User?
    @Published private(set) var isLoading = false
    @Published var error: Error?
    @Published private(set) var memberSince: String = ""
    @Published var selectedImage: UIImage?
    @Published var isImagePickerPresented = false
    @Published private(set) var isUploadingImage = false
    @Published private(set) var uploadProgress: Double = 0
    
    // MARK: - Dependencies
    private let userSessionManager: UserSessionManager
    private let profileService: ProfileServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private let maxImageSize: Int = 5 * 1024 * 1024 // 5MB
    private let imageCompressionQuality: CGFloat = 0.7
    
    // MARK: - Initialization
    init(
        userSessionManager: UserSessionManager = .shared,
        profileService: ProfileServiceProtocol = ProfileService()
    ) {
        self.userSessionManager = userSessionManager
        self.profileService = profileService
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
    
    private func validateImage(_ image: UIImage) -> Bool {
        guard let imageData = image.jpegData(compressionQuality: imageCompressionQuality) else {
            return false
        }
        return imageData.count <= maxImageSize
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
    
    func presentImagePicker() {
        isImagePickerPresented = true
    }
    
    func handleSelectedImage(_ image: UIImage?) {
        guard let image = image else { return }
        
        // Validate image size
        guard validateImage(image) else {
            self.error = NSError(
                domain: "com.nominom.app",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Image size exceeds 5MB limit. Please choose a smaller image."]
            )
            return
        }
        
        selectedImage = image
        Task {
            await uploadImage(image)
        }
    }
    
    private func uploadImage(_ image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: imageCompressionQuality) else {
            await MainActor.run {
                self.error = NSError(
                    domain: "com.nominom.app",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"]
                )
            }
            return
        }
        
        await MainActor.run {
            self.isUploadingImage = true
            self.uploadProgress = 0
        }
        
        do {
            let profilePhoto = try await profileService.updateProfilePhoto(imageData)
            
            await MainActor.run {
                self.isUploadingImage = false
                self.uploadProgress = 1.0
                // Refresh user data to get updated profile photo
                Task {
                    await self.refreshUserData()
                }
            }
        } catch {
            await MainActor.run {
                self.isUploadingImage = false
                self.error = error
            }
        }
    }
} 