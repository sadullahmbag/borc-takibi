import Foundation
import SwiftData

@Model
final class Debt {
    var id: UUID
    var userId: String  // User ID from Supabase Auth
    var name: String
    var originalAmount: Double
    var currentAmount: Double
    var category: String
    var emoji: String
    var color: String
    var createdDate: Date
    var dueDate: Date?
    var interestRate: Double?
    var isCompleted: Bool

    @Relationship(deleteRule: .cascade) var payments: [Payment]?

    var progress: Double {
        guard originalAmount > 0 else { return 0 }
        return (originalAmount - currentAmount) / originalAmount
    }

    var amountPaid: Double {
        originalAmount - currentAmount
    }

    // Interest calculation helpers
    var monthlyInterestRate: Double {
        guard let rate = interestRate, rate > 0 else { return 0 }
        return rate / 100 / 12 // Convert annual percentage to monthly decimal
    }

    var monthsSinceCreation: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: createdDate, to: Date())
        return max(components.month ?? 0, 0)
    }

    // Calculate total interest accrued since creation
    func calculateAccruedInterest() -> Double {
        guard let rate = interestRate, rate > 0 else { return 0 }

        // Simple interest calculation: Principal × Rate × Time
        let years = Double(monthsSinceCreation) / 12.0
        return originalAmount * (rate / 100) * years
    }

    // Calculate current balance with accrued interest
    func currentBalanceWithInterest() -> Double {
        return currentAmount + calculateAccruedInterest()
    }

    // Calculate monthly interest on current balance
    func calculateMonthlyInterest() -> Double {
        guard let rate = interestRate, rate > 0 else { return 0 }
        return currentAmount * monthlyInterestRate
    }

    // Total amount that will be paid if debt continues with current interest
    func projectedTotalWithInterest(months: Int = 12) -> Double {
        guard let rate = interestRate, rate > 0 else { return currentAmount }

        // Compound interest: A = P(1 + r/n)^(nt)
        let monthlyRate = rate / 100 / 12
        let compoundFactor = pow(1 + monthlyRate, Double(months))
        return currentAmount * compoundFactor
    }

    init(
        userId: String,
        name: String,
        amount: Double,
        category: String = "Other",
        emoji: String = "💰",
        color: String = "blue",
        dueDate: Date? = nil,
        interestRate: Double? = nil
    ) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.originalAmount = amount
        self.currentAmount = amount
        self.category = category
        self.emoji = emoji
        self.color = color
        self.createdDate = Date()
        self.dueDate = dueDate
        self.interestRate = interestRate
        self.isCompleted = false
        self.payments = []
    }
}

extension Debt {
    static var categories: [String] = [
        "Credit Card", "Student Loan", "Car Loan", "Mortgage",
        "Personal Loan", "Medical", "Other"
    ]

    static var categoryEmojis: [String: String] = [
        "Credit Card": "💳",
        "Student Loan": "🎓",
        "Car Loan": "🚗",
        "Mortgage": "🏠",
        "Personal Loan": "💵",
        "Medical": "🏥",
        "Other": "💰"
    ]

    static var colors: [String] = [
        "pink", "purple", "blue", "teal", "green", "yellow", "orange", "red"
    ]
}
