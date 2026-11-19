import Foundation

/// Goal categories used for the picker and for filtering.
enum GoalCategory: String, Codable, CaseIterable, Identifiable {
    case gadget = "Gadget"
    case travel = "Travel"
    case education = "Education"
    case emergency = "Emergency Fund"
    case gift = "Gift"
    case other = "Other"

    var id: String { rawValue }

    /// SF Symbol name for each category.
    var icon: String {
        switch self {
        case .gadget: return "iphone"
        case .travel: return "airplane"
        case .education: return "book.fill"
        case .emergency: return "cross.case.fill"
        case .gift: return "gift.fill"
        case .other: return "star.fill"
        }
    }
}

enum GoalStatus: String {
    case inProgress = "In Progress"
    case achieved = "Achieved"
}

/// A single deposit made towards a goal.

struct Contribution: Identifiable, Codable, Hashable {
    var id = UUID()
    var amount: Double
    var date = Date()
    var note = ""
}

/// A savings goal. Derived values (saved, progress, status) are computed from contributions.
struct Goal: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var targetAmount: Double
    var targetDate: Date
    var category: GoalCategory
    var notes: String
    var contributions: [Contribution] = []

    var savedAmount: Double { contributions.reduce(0) { $0 + $1.amount } }
    var remainingAmount: Double { max(targetAmount - savedAmount, 0) }
    var progress: Double { targetAmount > 0 ? min(savedAmount / targetAmount, 1) : 0 }
    var status: GoalStatus { savedAmount >= targetAmount ? .achieved : .inProgress }
}

extension Double {
    /// Formats a number as Indian Rupees.
    var currency: String { formatted(.currency(code: "INR")) }
}
