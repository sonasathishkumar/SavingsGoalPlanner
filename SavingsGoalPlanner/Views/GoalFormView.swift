import SwiftUI

/// Used for both Add Goal (goal == nil) and Edit Goal.
struct GoalFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: GoalViewModel
    @StateObject private var form: GoalFormViewModel

    init(goal: Goal? = nil) {
        _form = StateObject(wrappedValue: GoalFormViewModel(goal: goal))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Goal name", text: $form.name)
                    TextField("Target amount (₹)", text: $form.targetText).keyboardType(.decimalPad)
                    DatePicker("Target date", selection: $form.targetDate, displayedComponents: .date)
                    Picker("Category", selection: $form.category) {
                        ForEach(GoalCategory.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section("Notes") {
                    TextField("Notes (optional)", text: $form.notes, axis: .vertical).lineLimit(3...6)
                }
                if let message = form.errorMessage {
                    Text(message).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle(form.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    /// Validates the form and saves a new or updated goal, then closes the sheet.
    private func save() {
        guard let goal = form.makeGoal() else { return }
        if form.isEditing { vm.update(goal) } else { vm.add(goal) }
        dismiss()
    }
}
