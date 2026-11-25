import SwiftUI

/// Shows the login screen until the user is authenticated, then the main tabs.
struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

/// Tab container. `selectedTab` is shared so the Dashboard can jump to the Goals tab.
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }
                .tag(0)
            GoalListView()
                .tabItem { Label("Goals", systemImage: "target") }
                .tag(1)
        }
    }
}

