import SwiftUI
import Combine

/// Form state + validation shared by the Add Goal and Edit Goal screens.
final class GoalFormViewModel: ObservableObject {
    @Published var name: String
    @Published var targetText: String
    @Published var targetDate: Date
    @Published var category: GoalCategory
    @Published var notes: String
    @Published var errorMessage: String?

    private let original: Goal?
    var isEditing: Bool { original != nil }
    var title: String { isEditing ? "Edit Goal" : "New Goal" }

    init(goal: Goal?) {
        original = goal
        name = goal?.name ?? ""
        targetText = goal.map { String($0.targetAmount) } ?? ""
        targetDate = goal?.targetDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        category = goal?.category ?? .gadget
        notes = goal?.notes ?? ""
    }

    /// Validates input and returns a Goal ready to save, or nil with an error message.
    func makeGoal() -> Goal? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { errorMessage = "Please enter a goal name."; return nil }
        guard let target = Double(targetText), target > 0 else {
            errorMessage = "Target amount must be a number greater than 0."
            return nil

        }
        errorMessage = nil

        var goal = original ?? Goal(name: trimmed, targetAmount: target, targetDate: targetDate,
                                    category: category, notes: notes)
        goal.name = trimmed
        goal.targetAmount = target
        goal.targetDate = targetDate
        goal.category = category
        goal.notes = notes
        return goal
    }
}
