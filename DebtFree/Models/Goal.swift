import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var userId: String  // User ID from Supabase Auth
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date
    var category: GoalCategory
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        return max(days, 0)
    }

    init(userId: String, title: String, targetAmount: Double, targetDate: Date, category: GoalCategory = .monthly) {
        self.id = UUID()
        self.userId = userId
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = 0
        self.targetDate = targetDate
        self.category = category
        self.isCompleted = false
        self.createdAt = Date()
        self.completedAt = nil
    }

    func addProgress(amount: Double) {
        currentAmount += amount
        if currentAmount >= targetAmount && !isCompleted {
            complete()
        }
    }

    func complete() {
        isCompleted = true
        completedAt = Date()
    }
}

enum GoalCategory: String, Codable, CaseIterable {
    case monthly = "Monthly Payment"
    case milestone = "Milestone"
    case custom = "Custom Goal"
    case debtFree = "Debt Free"

    var icon: String {
        switch self {
        case .monthly: return "calendar"
        case .milestone: return "flag.fill"
        case .custom: return "star.fill"
        case .debtFree: return "checkmark.seal.fill"
        }
    }

    var color: String {
        switch self {
        case .monthly: return "blue"
        case .milestone: return "purple"
        case .custom: return "pink"
        case .debtFree: return "success"
        }
    }
}
