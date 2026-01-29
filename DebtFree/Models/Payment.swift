import Foundation
import SwiftData

@Model
final class Payment {
    var id: UUID
    var userId: String  // User ID from Supabase Auth
    var amount: Double
    var date: Date
    var note: String?
    var debt: Debt?

    init(userId: String, amount: Double, note: String? = nil, debt: Debt? = nil) {
        self.id = UUID()
        self.userId = userId
        self.amount = amount
        self.date = Date()
        self.note = note
        self.debt = debt
    }
}
