import SwiftUI

struct SignUpView: View {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.colorScheme) private var colorScheme

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    @Binding var showSignUp: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Logo/Icon
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.purple, ColorTheme.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Create Account".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text("Start your journey to financial freedom".localized)
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
                            .textContentType(.newPassword)
                            .padding()
                            .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.purple.opacity(0.3), lineWidth: 1)
                            )

                        // Password Requirements
                        Text("Minimum 8 characters".localized)
                            .font(.caption)
                            .foregroundColor(password.count >= 8 ? ColorTheme.green : ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                    }

                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                        SecureField("Confirm Password".localized, text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.purple.opacity(0.3), lineWidth: 1)
                            )

                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords do not match".localized)
                                .font(.caption)
                                .foregroundColor(.red)
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

                    // Sign Up Button
                    Button(action: {
                        Task {
                            await signUp()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Create Account".localized)
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
                    .disabled(isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                }
                .padding(.horizontal)

                // Sign In Link
                HStack {
                    Text("Already have an account?".localized)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    Button(action: {
                        showSignUp = false
                    }) {
                        Text("Sign In".localized)
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
        .alert("Check Your Email".localized, isPresented: $showSuccess) {
            Button("OK".localized) {
                showSignUp = false
            }
        } message: {
            Text("We've sent you a confirmation email. Please check your inbox to verify your account.".localized)
        }
    }

    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !email.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }

    // MARK: - Actions
    private func signUp() async {
        errorMessage = nil
        isLoading = true

        do {
            try await authManager.signUp(email: email, password: password)
            HapticManager.shared.success()
            // If email confirmation is required, show success message
            // Otherwise, user will be automatically authenticated
        } catch let error as AuthError {
            if case .emailConfirmationRequired = error {
                showSuccess = true
            } else {
                errorMessage = error.localizedDescription
            }
            HapticManager.shared.error()
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.shared.error()
        }

        isLoading = false
    }
}

#Preview {
    SignUpView(showSignUp: .constant(true))
}
