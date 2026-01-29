import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appleSignInHelper = AppleSignInHelper()
    @Environment(\.colorScheme) private var colorScheme

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showForgotPassword = false

    @Binding var showSignUp: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Logo/Icon
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.purple, ColorTheme.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Welcome Back!".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text("Sign in to continue your debt-free journey".localized)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                        TextField("Email".localized, text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.purple.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                        SecureField("Password".localized, text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.purple.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Forgot Password?".localized)
                                .font(.caption)
                                .foregroundColor(ColorTheme.purple)
                        }
                    }

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Sign In Button
                    Button(action: {
                        Task {
                            await signIn()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Sign In".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(
                        LinearGradient(
                            colors: [ColorTheme.purple, ColorTheme.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal)

                // Divider with "Or continue with"
                HStack {
                    Rectangle()
                        .fill(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.3))
                        .frame(height: 1)

                    Text("Or continue with".localized)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        .padding(.horizontal, 12)

                    Rectangle()
                        .fill(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Social Sign In Buttons
                VStack(spacing: 12) {
                    // Apple Sign In
                    Button(action: {
                        signInWithApple()
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.title3)

                            Text("Continue with Apple".localized)
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)

                    // Google Sign In (Coming Soon)
                    Button(action: {
                        // Google Sign In will be implemented
                        errorMessage = "Google Sign In coming soon!".localized
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)

                            Text("Continue with Google".localized)
                                .font(.headline)
                        }
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ColorTheme.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal)

                // Sign Up Link
                HStack {
                    Text("Don't have an account?".localized)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Sign Up".localized)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.purple)
                    }
                }
                .font(.subheadline)

                Spacer()
            }
            .padding()
        }
        .background(ColorTheme.dynamicBackground(colorScheme: colorScheme))
        .alert("Reset Password".localized, isPresented: $showForgotPassword) {
            TextField("Email".localized, text: $email)
            Button("Cancel".localized, role: .cancel) {}
            Button("Send Reset Link".localized) {
                Task {
                    await resetPassword()
                }
            }
        } message: {
            Text("Enter your email to receive a password reset link".localized)
        }
    }

    // MARK: - Actions
    private func signIn() async {
        errorMessage = nil
        isLoading = true

        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.shared.error()
        }

        isLoading = false
    }

    private func resetPassword() async {
        do {
            try await authManager.resetPassword(email: email)
            errorMessage = nil
            HapticManager.shared.success()
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.shared.error()
        }
    }

    private func signInWithApple() {
        isLoading = true
        errorMessage = nil

        appleSignInHelper.signIn(
            onSuccess: { idToken, nonce in
                Task {
                    do {
                        try await authManager.signInWithApple(idToken: idToken, nonce: nonce)
                        HapticManager.shared.success()
                    } catch {
                        errorMessage = error.localizedDescription
                        HapticManager.shared.error()
                    }
                    isLoading = false
                }
            },
            onError: { error in
                errorMessage = error.localizedDescription
                HapticManager.shared.error()
                isLoading = false
            }
        )
    }
}

#Preview {
    LoginView(showSignUp: .constant(false))
}
