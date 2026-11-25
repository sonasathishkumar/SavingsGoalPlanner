import Foundation

/// Abstraction over persistence so it can be swapped (e.g. for CoreData) later.
protocol GoalStoring {
    func load() -> [Goal]
    func save(_ goals: [Goal])
}

/// Stores goals as JSON in UserDefaults – simple and crash-safe for this project.
struct UserDefaultsGoalStorage: GoalStoring {
    private let key = "savings_goals_v1"

    func load() -> [Goal] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let goals = try? JSONDecoder().decode([Goal].self, from: data) else { return [] }
        return goals
    }

    func save(_ goals: [Goal]) {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
