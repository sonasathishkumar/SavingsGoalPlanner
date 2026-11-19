import SwiftUI

/// Home screen: summary stats and the goal closest to completion.
struct DashboardView: View {
    @EnvironmentObject var vm: GoalViewModel
    @EnvironmentObject var auth: AuthViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCard(title: "Total Goals", value: "\(vm.totalGoals)", icon: "target")
                        StatCard(title: "Achieved", value: "\(vm.achievedCount)", icon: "checkmark.seal.fill")
                    }
                    StatCard(title: "Total Saved", value: vm.totalSaved.currency, icon: "indianrupeesign.circle.fill")

                    Text("Closest to completion").font(.headline)
                    if let goal = vm.closestGoal {
                        NavigationLink { GoalDetailView(goalID: goal.id) } label: { GoalCardView(goal: goal) }
                            .buttonStyle(.plain)
                    } else {
                        Text("No goals in progress yet. Add one from the Goals tab!")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Button("Logout", systemImage: "rectangle.portrait.and.arrow.right") { auth.logout() }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).foregroundStyle(.tint)
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
