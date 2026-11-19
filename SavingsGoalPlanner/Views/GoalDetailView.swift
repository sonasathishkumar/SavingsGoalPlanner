import SwiftUI

/// Full goal information, contribution history, edit and delete.
struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: GoalViewModel
    let goalID: UUID

    @State private var showingEdit = false
    @State private var showingContribution = false
    @State private var showingDeleteAlert = false

    var body: some View {
        Group {
            if let goal = vm.goal(withID: goalID) {
                content(for: goal)
            }
        }
    }

    private func content(for goal: Goal) -> some View {
        List {
            Section { GoalCardView(goal: goal) }
            Section("Details") {
                row("Target amount", goal.targetAmount.currency)
                row("Amount saved", goal.savedAmount.currency)
                row("Remaining", goal.remainingAmount.currency)
                row("Target date", goal.targetDate.formatted(date: .abbreviated, time: .omitted))
                row("Category", goal.category.rawValue)
                if !goal.notes.isEmpty { row("Notes", goal.notes) }
            }
            Section("Contribution history") {
                if goal.contributions.isEmpty {
                    Text("No contributions yet").foregroundStyle(.secondary)
                }
                ForEach(goal.contributions) { c in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(c.amount.currency).font(.headline)
                            if !c.note.isEmpty { Text(c.note).font(.caption).foregroundStyle(.secondary) }
                        }
                        Spacer()
                        Text(c.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Section {
                Button { showingContribution = true } label: {
                    Label("Add Contribution", systemImage: "plus.circle.fill")
                }
                Button(role: .destructive) { showingDeleteAlert = true } label: {
                    Label("Delete Goal", systemImage: "trash")
                }
            }
        }
        .navigationTitle(goal.name)
        .toolbar { Button("Edit") { showingEdit = true } }
        .sheet(isPresented: $showingEdit) { GoalFormView(goal: goal) }
        .sheet(isPresented: $showingContribution) { AddContributionView(goalID: goal.id) }
        .alert("Delete this goal?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                vm.delete(id: goal.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Its saved contribution history will also be deleted.")
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
        }
    }
}
