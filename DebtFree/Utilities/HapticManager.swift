import UIKit
import SwiftUI

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func success() {
        notification(.success)
    }

    func error() {
        notification(.error)
    }

    func warning() {
        notification(.warning)
    }

    func light() {
        impact(.light)
    }

    func medium() {
        impact(.medium)
    }

    func heavy() {
        impact(.heavy)
    }

    func celebration() {
        DispatchQueue.main.async {
            self.notification(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.heavy)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.impact(.light)
        }
    }
}
