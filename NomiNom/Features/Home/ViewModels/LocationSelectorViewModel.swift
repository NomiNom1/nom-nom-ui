import Foundation
import Combine
import CoreLocation

@MainActor
final class LocationSelectorViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [LocationPrediction] = []
    @Published var nearbyLocations: [LocationPrediction] = []
    @Published var isLoading = false
    @Published var isLoadingNearby = false
    @Published var error: Error?
    @Published var isSearching = false
    
    private let locationSearchService: LocationSearchServiceProtocol
    private let locationManager: LocationManager
    private var searchTask: Task<Void, Never>?
    private var nearbyTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        locationSearchService: LocationSearchServiceProtocol = LocationSearchService(),
        locationManager: LocationManager = LocationManager()
    ) {
        self.locationSearchService = locationSearchService
        self.locationManager = locationManager
        setupSearchDebounce()
        setupLocationObserver()
    }
    
    func refreshData() async {
        // Cancel any existing tasks
        searchTask?.cancel()
        nearbyTask?.cancel()
        
        // Clear current data
        searchResults = []
        nearbyLocations = []
        
        // Refresh user data
        do {
            try await UserSessionManager.shared.refreshUserData()
            // Force a UI update by triggering objectWillChange
            objectWillChange.send()
        } catch {
            self.error = error
        }
        
        // Refresh nearby locations if we have a location
        if let location = locationManager.location {
            await fetchNearbyLocations(for: location)
        }
    }
    
    private func setupLocationObserver() {
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.fetchNearbyLocations(for: location)
            }
            .store(in: &cancellables)
    }
    
    private func fetchNearbyLocations(for location: CLLocation) {
        // Cancel any existing nearby task
        nearbyTask?.cancel()
        
        isLoadingNearby = true
        
        nearbyTask = Task {
            do {
                // Use the current location's address as the search query
                let query = locationManager.address
                let results = try await locationSearchService.searchLocations(query: query)
                if !Task.isCancelled {
                    nearbyLocations = results
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoadingNearby = false
            }
        }
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
