import Foundation
import SwiftData

@Model
final class Challenge {
    var id: UUID
    var userId: String  // User ID from Supabase Auth
    var title: String
    var details: String
    var type: ChallengeType
    var targetValue: Double
    var currentValue: Double
    var expiresAt: Date
    var isCompleted: Bool
    var completedAt: Date?
    var reward: ChallengeReward
    var emoji: String

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    var hoursRemaining: Int {
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: expiresAt).hour ?? 0
        return max(hours, 0)
    }

    init(userId: String, title: String, details: String, type: ChallengeType, targetValue: Double, expiresAt: Date, reward: ChallengeReward, emoji: String) {
        self.id = UUID()
        self.userId = userId
        self.title = title
        self.details = details
        self.type = type
        self.targetValue = targetValue
        self.currentValue = 0
        self.expiresAt = expiresAt
        self.isCompleted = false
        self.completedAt = nil
        self.reward = reward
        self.emoji = emoji
    }

    func addProgress(value: Double) {
        currentValue += value
        if currentValue >= targetValue && !isCompleted {
            complete()
        }
    }

    func complete() {
        isCompleted = true
        completedAt = Date()
    }
}

enum ChallengeType: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case special = "Special"
}

struct ChallengeReward: Codable {
    let xp: Int
    let title: String?
    let emoji: String

    init(xp: Int, title: String? = nil, emoji: String = "⭐") {
        self.xp = xp
        self.title = title
        self.emoji = emoji
    }
}

// MARK: - Challenge Generator
struct ChallengeGenerator {
    static func generateDailyChallenge(for userId: String) -> Challenge {
        let challenges: [(title: String, details: String, target: Double, emoji: String)] = [
            ("Payment Warrior", "Make a payment today", 1, "⚔️"),
            ("Double Up", "Pay twice today", 2, "💪"),
            ("Review Master", "Review all your debts", 1, "👀"),
            ("Goal Setter", "Create a new goal", 1, "🎯"),
            ("Achievement Hunter", "Check your progress", 1, "🏆")
        ]

        let selected = challenges.randomElement()!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

        return Challenge(
            userId: userId,
            title: selected.title,
            details: selected.details,
            type: .daily,
            targetValue: selected.target,
            expiresAt: tomorrow,
            reward: ChallengeReward(xp: 100, emoji: "⭐"),
            emoji: selected.emoji
        )
    }

    static func generateWeeklyChallenge(for userId: String) -> Challenge {
        let challenges: [(title: String, details: String, target: Double, emoji: String)] = [
            ("Week Warrior", "Make 5 payments this week", 5, "🔥"),
            ("Debt Crusher", "Pay off a complete debt", 1, "💥"),
            ("Consistency King", "Maintain your streak", 7, "👑"),
            ("Goal Achiever", "Complete a goal", 1, "🎊"),
            ("Big Spender", "Pay $500 total this week", 500, "💰")
        ]

        let selected = challenges.randomElement()!
        let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!

        return Challenge(
            userId: userId,
            title: selected.title,
            details: selected.details,
            type: .weekly,
            targetValue: selected.target,
            expiresAt: nextWeek,
            reward: ChallengeReward(xp: 500, title: "Weekly Champion", emoji: "🏆"),
            emoji: selected.emoji
        )
    }
}
