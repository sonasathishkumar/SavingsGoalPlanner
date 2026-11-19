import SwiftUI

/// Sheet for adding a contribution to a goal.
struct AddContributionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: GoalViewModel
    let goalID: UUID

    @State private var amountText = ""
    @State private var note = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount (₹)", text: $amountText).keyboardType(.decimalPad)
                TextField("Note (optional)", text: $note)
                if let errorMessage { Text(errorMessage).foregroundStyle(.red).font(.footnote) }
            }
            .navigationTitle("Add Contribution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { add() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func add() {

        guard let amount = Double(amountText), amount > 0 else {
            errorMessage = "Enter an amount greater than 0."
            return
        }
        vm.addContribution(amount: amount, note: note, to: goalID)
        dismiss()
    }
}
