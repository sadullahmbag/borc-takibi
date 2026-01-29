import SwiftUI
import Combine

class PopupManager: ObservableObject {
    static let shared = PopupManager()

    @Published var achievementToShow: (id: String, title: String, description: String, emoji: String)?
    @Published var challengeToShow: Challenge?

    private init() {}

    func showAchievement(_ achievement: (id: String, title: String, description: String, emoji: String)) {
        // Delay slightly to ensure smooth transition from payment view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.achievementToShow = achievement
        }
    }

    func showChallenge(_ challenge: Challenge) {
        // Delay slightly to ensure smooth transition from payment view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.challengeToShow = challenge
        }
    }

    func dismissAchievement() {
        achievementToShow = nil
    }

    func dismissChallenge() {
        challengeToShow = nil
    }
}
