import Foundation
import Combine

@MainActor
final class LocationSelectorViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [LocationPrediction] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isSearching = false
    
    private let locationSearchService: LocationSearchServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(locationSearchService: LocationSearchServiceProtocol = LocationSearchService()) {
        self.locationSearchService = locationSearchService
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                self.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        // Cancel any existing search task
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        isLoading = true
        
        searchTask = Task {
            do {
                let results = try await locationSearchService.searchLocations(query: query)
                if !Task.isCancelled {
                    searchResults = results
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        isSearching = false
    }
} 
