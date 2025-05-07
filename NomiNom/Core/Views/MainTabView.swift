import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            OffersView()
                .tabItem {
                    Label("Offers", systemImage: "tag.fill")
                }
                .tag(1)
            
            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet")
                }
                .tag(2)
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Me", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
} 