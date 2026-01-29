import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var userId: String  // User ID from Supabase Auth
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

    init(userId: String) {
        self.id = UUID()
        self.userId = userId
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
        // Early wins - keep users motivated
        ("first_payment", "First Steps".localized, "First payment made".localized, "🎯", { _ in true }),
        ("debt_free_1", "Debt Slayer".localized, "Paid off first debt".localized, "🎊", { $0.debtsCompleted >= 1 }),

        // Consistency rewards
        ("streak_3", "Consistency".localized, "3-month payment streak".localized, "🔥", { $0.longestStreak >= 3 }),
        ("streak_6", "Dedication".localized, "6-month payment streak".localized, "💪", { $0.longestStreak >= 6 }),
        ("streak_12", "Year Warrior".localized, "12-month payment streak".localized, "👑", { $0.longestStreak >= 12 }),

        // Payment milestones
        ("payment_25", "Getting Started".localized, "Made 25 payments".localized, "⭐", { $0.totalPaid >= 25 * 100 }), // Assuming avg 100 per payment
        ("payment_50", "Persistence".localized, "Made 50 payments".localized, "💎", { $0.totalPaid >= 50 * 100 }),
        ("payment_100", "Dedication Master".localized, "Made 100 payments".localized, "🏅", { $0.totalPaid >= 100 * 100 }),

        // Debt completion
        ("debt_free_3", "Debt Crusher".localized, "Paid off 3 debts".localized, "💥", { $0.debtsCompleted >= 3 }),
        ("debt_free_5", "Debt Master".localized, "Paid off 5 debts".localized, "🏆", { $0.debtsCompleted >= 5 }),
        ("debt_free_10", "Debt Free Hero".localized, "Paid off 10 debts".localized, "🌟", { $0.debtsCompleted >= 10 }),

        // Financial milestones (realistic amounts in TRY)
        ("paid_5000", "Small Wins".localized, "Paid 5000₺ total".localized, "💵", { $0.totalPaid >= 5000 }),
        ("paid_25000", "Building Momentum".localized, "Paid 25000₺ total".localized, "💰", { $0.totalPaid >= 25000 }),
        ("paid_100000", "Major Milestone".localized, "Paid 100000₺ total".localized, "💎", { $0.totalPaid >= 100000 }),
        ("paid_500000", "Financial Freedom".localized, "Paid 500000₺ total".localized, "👑", { $0.totalPaid >= 500000 }),

        // Level achievements
        ("level_5", "Level 5".localized, "Reached level 5".localized, "✨", { $0.level >= 5 }),
        ("level_10", "Level 10".localized, "Reached level 10".localized, "🎖️", { $0.level >= 10 }),
        ("level_20", "Level 20".localized, "Reached level 20".localized, "🏅", { $0.level >= 20 }),
        ("level_50", "Level 50".localized, "Reached level 50".localized, "👑", { $0.level >= 50 })
    ]
}
