import SwiftUI

struct WelcomePopup: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var userManager = UserManager.shared
    @Environment(\.colorScheme) private var colorScheme

    @State private var isVisible = false
    @State private var sparkleAnimating = false

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            VStack(spacing: 24) {
                // Welcome Icon with glow effect
                ZStack {
                    // Glow background
                    Circle()
                        .fill(ColorTheme.gradient2)
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .opacity(sparkleAnimating ? 0.8 : 0.3)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                            value: sparkleAnimating
                        )

                    Text("🎉")
                        .font(.system(size: 70))
                        .scaleEffect(isVisible ? 1.0 : 0.1)
                        .rotationEffect(.degrees(isVisible ? 0 : 180))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.6)
                            .delay(0.1),
                            value: isVisible
                        )
                }

                // Welcome Badge
                Text("Welcome!".localized)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [ColorTheme.purple, ColorTheme.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .scaleEffect(isVisible ? 1.0 : 0.1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(0.2),
                        value: isVisible
                    )

                VStack(spacing: 8) {
                    // User Email
                    if let email = authManager.currentUser?.email {
                        Text("Hi, \(email.components(separatedBy: "@").first ?? "there")!".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                            .multilineTextAlignment(.center)
                    }

                    // Welcome Message
                    Text("Welcome to your debt-free journey!".localized)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Features List
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(emoji: "💳", text: "Track all your debts in one place".localized)
                    FeatureRow(emoji: "🎯", text: "Set goals and monitor progress".localized)
                    FeatureRow(emoji: "🏆", text: "Earn achievements and XP".localized)
                    FeatureRow(emoji: "📊", text: "Visualize your journey to freedom".localized)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorTheme.purple.opacity(0.1))
                )

                // Get Started Button
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Get Started!".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [ColorTheme.purple, ColorTheme.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .bouncyPress()
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                    .shadow(
                        color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
            )
            .padding(.horizontal, 40)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.75),
                value: isVisible
            )

            // Sparkle effects
            if sparkleAnimating {
                SparkleEffectView()
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }

            // Trigger sparkle and haptic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                sparkleAnimating = true
                HapticManager.shared.success()
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let userId = authManager.userId {
                userManager.markFirstLoginComplete(userId: userId)
            }
            onDismiss()
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title3)

            Text(text)
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            Spacer()
        }
    }
}

#Preview {
    WelcomePopup(onDismiss: {})
}
