import Foundation
import SwiftUI

@MainActor
class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var showWelcomePopup = false
    @Published var isFirstTimeUser = false

    private let userDefaults = UserDefaults.standard
    private let firstTimeUserKey = "hasCompletedFirstLogin_"

    private init() {}

    // Check if this is the user's first time logging in
    func checkFirstTimeUser(userId: String) {
        let key = firstTimeUserKey + userId
        let hasCompletedFirstLogin = userDefaults.bool(forKey: key)

        if !hasCompletedFirstLogin {
            // This is the first time this user is logging in
            isFirstTimeUser = true
            showWelcomePopup = true
        } else {
            isFirstTimeUser = false
            showWelcomePopup = false
        }
    }

    // Mark that the user has completed their first login
    func markFirstLoginComplete(userId: String) {
        let key = firstTimeUserKey + userId
        userDefaults.set(true, forKey: key)
        isFirstTimeUser = false
        showWelcomePopup = false
    }

    // Reset first-time status (for testing)
    func resetFirstTimeStatus(userId: String) {
        let key = firstTimeUserKey + userId
        userDefaults.removeObject(forKey: key)
    }
}
