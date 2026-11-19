import SwiftUI

/// Reusable card used in the goal list, detail and dashboard.
struct GoalCardView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: goal.category.icon).foregroundStyle(.tint)
                Text(goal.name).font(.headline)
                Spacer()
                StatusBadge(status: goal.status)
            }
            HStack {
                Text("Saved \(goal.savedAmount.currency)")
                Spacer()
                Text("Target \(goal.targetAmount.currency)")
            }
            .font(.subheadline).foregroundStyle(.secondary)
            ProgressView(value: goal.progress)
            Text("\(Int(goal.progress * 100))% complete").font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StatusBadge: View {
    let status: GoalStatus


    var body: some View {
        let color: Color = status == .achieved ? .green : .orange
        Text(status.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
