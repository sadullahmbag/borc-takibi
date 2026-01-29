import SwiftUI

struct AchievementPopupOverlay: View {
    let achievement: (id: String, title: String, description: String, emoji: String)
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var confettiAnimating = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            VStack(spacing: 20) {
                // Emoji with pulse animation
                Text(achievement.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(isVisible ? 1.0 : 0.1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.6)
                        .delay(0.1),
                        value: isVisible
                    )

                // Achievement Unlocked Badge
                Text("Achievement Unlocked!".localized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(ColorTheme.gradient1)
                    )
                    .scaleEffect(isVisible ? 1.0 : 0.1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(0.2),
                        value: isVisible
                    )

                // Achievement Title
                Text(achievement.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                    .multilineTextAlignment(.center)

                // Achievement Description
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Dismiss Button
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Awesome!".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.gradient1)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
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

            // Confetti effect
            if confettiAnimating {
                ConfettiView()
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }

            // Trigger confetti after a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confettiAnimating = true
                HapticManager.shared.success()
            }

            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                dismissWithAnimation()
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

#Preview {
    AchievementPopupOverlay(
        achievement: (
            id: "test",
            title: "First Steps".localized,
            description: "First payment made".localized,
            emoji: "🎯"
        ),
        onDismiss: {}
    )
}
