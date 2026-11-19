import SwiftUI

/// App entry point. Creates the two shared view models and injects them into the view tree.
@main
struct SavingsGoalPlannerApp: App {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var goals = GoalViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(goals)
        }
    }
}

