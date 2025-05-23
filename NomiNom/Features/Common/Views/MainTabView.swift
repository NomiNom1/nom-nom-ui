import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("home_tab".localized, systemImage: "house.fill")
                }
                .tag(0)
            
            OrdersView()
                .tabItem {
                    Label("orders_tab".localized, systemImage: "list.bullet")
                }
                .tag(1)
            
            BrowseView()
                .tabItem {
                    Label("browse_tab".localized, systemImage: "magnifyingglass")
                }
                .tag(2)
            
            ChatListView()
                .tabItem {
                    Label("chat_tab".localized, systemImage: "message.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("me_tab".localized, systemImage: "person.fill")
                }
                .tag(4)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    MainTabView()
        .environmentObject(LanguageManager.shared)
} 
