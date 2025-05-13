import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("home_tab".localized, systemImage: "house.fill")
                }
                .tag(0)
            
            OffersView()
                .tabItem {
                    Label("offers_tab".localized, systemImage: "tag.fill")
                }
                .tag(1)
            
            OrdersView()
                .tabItem {
                    Label("orders_tab".localized, systemImage: "list.bullet")
                }
                .tag(2)
            
            BrowseView()
                .tabItem {
                    Label("browse_tab".localized, systemImage: "magnifyingglass")
                }
                .tag(3)
            
            ChatListView()
                .tabItem {
                    Label("chat_tab".localized, systemImage: "message.fill")
                }
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Label("me_tab".localized, systemImage: "person.fill")
                }
                .tag(5)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    MainTabView()
        .environmentObject(LanguageManager.shared)
} 
