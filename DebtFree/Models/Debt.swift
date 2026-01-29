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
