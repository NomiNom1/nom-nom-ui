import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var featuredRestaurants: [Restaurant] = []
    @Published var popularCategories: [Category] = []
    @Published var recentOrders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let restaurantService: RestaurantServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let orderService: OrderServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        restaurantService: RestaurantServiceProtocol,
        categoryService: CategoryServiceProtocol,
        orderService: OrderServiceProtocol
    ) {
        self.restaurantService = restaurantService
        self.categoryService = categoryService
        self.orderService = orderService
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let restaurants = restaurantService.getFeaturedRestaurants()
            async let categories = categoryService.getPopularCategories()
            async let orders = orderService.getRecentOrders()
            
            let (fetchedRestaurants, fetchedCategories, fetchedOrders) = try await (restaurants, categories, orders)
            
            featuredRestaurants = fetchedRestaurants
            popularCategories = fetchedCategories
            recentOrders = fetchedOrders
        } catch {
            self.error = error
        }
    }
    
    func refreshData() {
        Task {
            await loadData()
        }
    }
} 