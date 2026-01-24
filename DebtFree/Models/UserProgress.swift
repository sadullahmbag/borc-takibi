import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var totalPaid: Double
    var debtsCompleted: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastPaymentDate: Date?
    var level: Int
    var experience: Int
    var achievementsUnlocked: [String]

    var experienceToNextLevel: Int {
        level * 1000
    }

    var currentLevelProgress: Double {
        guard experienceToNextLevel > 0 else { return 0 }
        return Double(experience) / Double(experienceToNextLevel)
    }

    init() {
        self.id = UUID()
        self.totalPaid = 0
        self.debtsCompleted = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastPaymentDate = nil
        self.level = 1
        self.experience = 0
        self.achievementsUnlocked = []
    }

    func addPayment(amount: Double) {
        totalPaid += amount
        experience += Int(amount / 10)

        if experience >= experienceToNextLevel {
            levelUp()
        }

        updateStreak()
    }

    func completeDebt() {
        debtsCompleted += 1
        experience += 500

        if experience >= experienceToNextLevel {
            levelUp()
        }
    }

    private func levelUp() {
        level += 1
        experience = 0
    }

    private func updateStreak() {
        let calendar = Calendar.current

        if let lastDate = lastPaymentDate {
            // Check if payment is in a different month
            let lastMonth = calendar.component(.month, from: lastDate)
            let lastYear = calendar.component(.year, from: lastDate)
            let currentMonth = calendar.component(.month, from: Date())
            let currentYear = calendar.component(.year, from: Date())

            // Calculate months between payments
            let monthsBetween = (currentYear - lastYear) * 12 + (currentMonth - lastMonth)

            if monthsBetween == 1 {
                // Payment in consecutive month
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else if monthsBetween > 1 {
                // Missed one or more months, reset streak
                currentStreak = 1
            }
            // If monthsBetween == 0, it's the same month, don't change streak
        } else {
            currentStreak = 1
        }

        lastPaymentDate = Date()
    }
}

extension UserProgress {
    static var achievements: [(id: String, title: String, description: String, emoji: String, requirement: (UserProgress) -> Bool)] = [
        ("first_payment", "First Step", "Made your first payment", "🎯", { _ in true }),
        ("payment_10", "Getting Started", "Made 10 payments", "⭐", { $0.totalPaid >= 10 }),
        ("debt_free_1", "Debt Destroyer", "Completed 1 debt", "🎊", { $0.debtsCompleted >= 1 }),
        ("debt_free_5", "Debt Slayer", "Completed 5 debts", "🏆", { $0.debtsCompleted >= 5 }),
        ("streak_3", "Consistent Payer", "3-month payment streak", "🔥", { $0.longestStreak >= 3 }),
        ("streak_6", "Half Year Hero", "6-month payment streak", "💪", { $0.longestStreak >= 6 }),
        ("level_5", "Rising Star", "Reached level 5", "✨", { $0.level >= 5 }),
        ("level_10", "Debt Champion", "Reached level 10", "👑", { $0.level >= 10 }),
        ("paid_1000", "Thousand Club", "Paid $1,000 total", "💵", { $0.totalPaid >= 1000 }),
        ("paid_10000", "Ten Thousand Legend", "Paid $10,000 total", "💎", { $0.totalPaid >= 10000 })
    ]
}
