import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private var cancellables = Set<AnyCancellable>()
    
} 