import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var selectedCurrencyCode: String
    var showCelebrations: Bool
    var enableHaptics: Bool
    var enableNotifications: Bool
    var themeColor: String

    init() {
        self.id = UUID()
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
