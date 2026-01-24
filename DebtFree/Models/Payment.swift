import Foundation
import SwiftData

@Model
final class Payment {
    var id: UUID
    var amount: Double
    var date: Date
    var note: String?
    var debt: Debt?

    init(amount: Double, note: String? = nil, debt: Debt? = nil) {
        self.id = UUID()
        self.amount = amount
        self.date = Date()
        self.note = note
        self.debt = debt
    }
}
