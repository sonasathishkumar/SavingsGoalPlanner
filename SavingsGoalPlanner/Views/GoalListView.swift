import SwiftUI

/// Scrollable list of goal cards with search, category filter and an Add button.
struct GoalListView: View {
    @EnvironmentObject var vm: GoalViewModel
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    categoryChips
                    if vm.filteredGoals.isEmpty {
                        Text(vm.goals.isEmpty ? "No goals yet. Tap + to add one." : "No goals match your search.")
                            .foregroundStyle(.secondary).padding(.top, 40)
                    }
                    ForEach(vm.filteredGoals) { goal in
                        NavigationLink { GoalDetailView(goalID: goal.id) } label: { GoalCardView(goal: goal) }
                            .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .searchable(text: $vm.searchText, prompt: "Search goals")
            .navigationTitle("Goals")
            .toolbar {
                Button("Add Goal", systemImage: "plus") { showingAdd = true }
            }
            .sheet(isPresented: $showingAdd) { GoalFormView() }
        }
    }


    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                chip(title: "All", selected: vm.selectedCategory == nil) { vm.selectedCategory = nil }
                ForEach(GoalCategory.allCases) { category in
                    chip(title: category.rawValue, selected: vm.selectedCategory == category) {
                        vm.selectedCategory = category
                    }
                }
            }
        }
    }

    private func chip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.subheadline)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(selected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(selected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
    }
}
