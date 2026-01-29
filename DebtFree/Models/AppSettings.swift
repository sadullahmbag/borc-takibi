import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var userId: String  // User ID from Supabase Auth
    var selectedCurrencyCode: String
    var showCelebrations: Bool
    var enableHaptics: Bool
    var enableNotifications: Bool
    var themeColor: String

    init(userId: String) {
        self.id = UUID()
        self.userId = userId
        self.selectedCurrencyCode = "USD"
        self.showCelebrations = true
        self.enableHaptics = true
        self.enableNotifications = true
        self.themeColor = "pink"
    }

    var currency: Currency {
        get {
            Currency.allCurrencies.first { $0.code == selectedCurrencyCode } ?? .usd
        }
        set {
            selectedCurrencyCode = newValue.code
        }
    }
}
