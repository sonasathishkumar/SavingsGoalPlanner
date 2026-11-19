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

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }
            GoalListView()
                .tabItem { Label("Goals", systemImage: "target") }
        }
    }
}
