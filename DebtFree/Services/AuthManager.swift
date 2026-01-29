import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true

    private let supabase = SupabaseConfig.shared.client

    private init() {
        Task {
            await checkAuthStatus()
        }
    }

    // MARK: - Authentication Status
    func checkAuthStatus() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.isAuthenticated = false
            self.currentUser = nil
            self.isLoading = false
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )

        if let session = response.session {
            self.currentUser = session.user
            self.isAuthenticated = true
        } else {
            // Email confirmation required
            throw AuthError.emailConfirmationRequired
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )

        self.currentUser = session.user
        self.isAuthenticated = true
    }

    // MARK: - Sign Out
    func signOut() async throws {
        try await supabase.auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }

    // MARK: - Reset Password
    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    // MARK: - Update Password
    func updatePassword(newPassword: String) async throws {
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case emailConfirmationRequired
    case invalidCredentials
    case networkError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .emailConfirmationRequired:
            return "Please check your email to confirm your account".localized
        case .invalidCredentials:
            return "Invalid email or password".localized
        case .networkError:
            return "Network error. Please try again".localized
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
