import Foundation
#if canImport(Supabase)
import Supabase
#endif
import SwiftUI
import AuthenticationServices
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = true  // Start as authenticated in local mode
    @Published var currentUser: LocalUser?
    @Published var isLoading = false

    #if canImport(Supabase)
    private var supabase: SupabaseClient? {
        SupabaseConfig.shared.isAvailable ? SupabaseConfig.shared.client : nil
    }
    #endif

    // Computed property for easy access to userId
    var userId: String? {
        return currentUser?.id
    }

    private init() {
        // Initialize local user immediately for local mode
        createLocalUser()

        // Check for Supabase session in background if available
        #if canImport(Supabase)
        if SupabaseConfig.shared.isAvailable {
            Task {
                await checkAuthStatus()
            }
        }
        #endif
    }

    // MARK: - Authentication Status
    func checkAuthStatus() async {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            return
        }

        do {
            let session = try await supabase.auth.session
            self.currentUser = LocalUser(id: session.user.id.uuidString, email: session.user.email ?? "")
            self.isAuthenticated = true
        } catch {
            // Already have local user, so do nothing
            print("No Supabase session, using local mode")
        }
        #endif
    }

    private func createLocalUser() {
        // Create a local user for offline mode
        let localUserId = UserDefaults.standard.string(forKey: "localUserId") ?? UUID().uuidString
        UserDefaults.standard.set(localUserId, forKey: "localUserId")

        self.currentUser = LocalUser(id: localUserId, email: "local@user.com")
        self.isAuthenticated = true
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            // Local mode - create local user
            createLocalUser()
            return
        }

        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )

        if let session = response.session {
            self.currentUser = LocalUser(id: session.user.id.uuidString, email: session.user.email ?? email)
            self.isAuthenticated = true
        } else {
            // Email confirmation required
            throw AuthError.emailConfirmationRequired
        }
        #else
        // Local mode
        createLocalUser()
        #endif
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            // Local mode - create local user
            createLocalUser()
            return
        }

        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )

        self.currentUser = LocalUser(id: session.user.id.uuidString, email: session.user.email ?? email)
        self.isAuthenticated = true
        #else
        // Local mode
        createLocalUser()
        #endif
    }

    // MARK: - Sign Out
    func signOut() async throws {
        #if canImport(Supabase)
        if let supabase = supabase {
            try await supabase.auth.signOut()
        }
        #endif
        self.currentUser = nil
        self.isAuthenticated = false
    }

    // MARK: - Reset Password
    func resetPassword(email: String) async throws {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            throw AuthError.featureNotAvailableInLocalMode
        }
        try await supabase.auth.resetPasswordForEmail(email)
        #else
        throw AuthError.featureNotAvailableInLocalMode
        #endif
    }

    // MARK: - Update Password
    func updatePassword(newPassword: String) async throws {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            throw AuthError.featureNotAvailableInLocalMode
        }
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
        #else
        throw AuthError.featureNotAvailableInLocalMode
        #endif
    }

    // MARK: - Apple Sign In
    func signInWithApple(idToken: String, nonce: String) async throws {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            createLocalUser()
            return
        }

        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )

        self.currentUser = LocalUser(id: session.user.id.uuidString, email: session.user.email ?? "")
        self.isAuthenticated = true
        #else
        createLocalUser()
        #endif
    }

    // MARK: - Google Sign In
    func signInWithGoogle(idToken: String) async throws {
        #if canImport(Supabase)
        guard let supabase = supabase else {
            createLocalUser()
            return
        }

        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken
            )
        )

        self.currentUser = LocalUser(id: session.user.id.uuidString, email: session.user.email ?? "")
        self.isAuthenticated = true
        #else
        createLocalUser()
        #endif
    }
}

// MARK: - Local User Model
struct LocalUser {
    let id: String
    let email: String
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case emailConfirmationRequired
    case invalidCredentials
    case networkError
    case featureNotAvailableInLocalMode
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .emailConfirmationRequired:
            return "Please check your email to confirm your account".localized
        case .invalidCredentials:
            return "Invalid email or password".localized
        case .networkError:
            return "Network error. Please try again".localized
        case .featureNotAvailableInLocalMode:
            return "This feature requires cloud sync. Please add Supabase package to enable.".localized
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
