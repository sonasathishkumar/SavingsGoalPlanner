import SwiftUI
import Combine

/// Single source of truth for goals: CRUD, search/filter, contributions and dashboard stats.
final class GoalViewModel: ObservableObject {
    @Published private(set) var goals: [Goal] = []
    @Published var searchText = ""
    @Published var selectedCategory: GoalCategory?

    private let storage: GoalStoring

    init(storage: GoalStoring = UserDefaultsGoalStorage()) {
        self.storage = storage
        self.goals = storage.load()
    }

    // MARK: - Search & Filter
    var filteredGoals: [Goal] {
        goals.filter { goal in
            let matchesText = searchText.isEmpty || goal.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || goal.category == selectedCategory
            return matchesText && matchesCategory
        }
    }

    // MARK: - Dashboard stats
    var totalGoals: Int { goals.count }
    var achievedCount: Int { goals.filter { $0.status == .achieved }.count }
    var totalSaved: Double { goals.reduce(0) { $0 + $1.savedAmount } }
    /// In-progress goal with the highest progress.
    var closestGoal: Goal? {
        goals.filter { $0.status == .inProgress }.max { $0.progress < $1.progress }
    }

    // MARK: - CRUD
    func goal(withID id: UUID) -> Goal? { goals.first { $0.id == id } }

    func add(_ goal: Goal) {
        goals.insert(goal, at: 0)
        persist()
    }

    func update(_ goal: Goal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index] = goal
        persist()
    }

    /// Deleting a goal also removes its contribution history (it is stored inside the goal).
    func delete(id: UUID) {
        goals.removeAll { $0.id == id }
        persist()
    }

    func addContribution(amount: Double, note: String, to goalID: UUID) {
        guard let index = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[index].contributions.insert(Contribution(amount: amount, note: note), at: 0)
        persist()
    }

    private func persist() { storage.save(goals) }
}
