import SwiftUI

struct ChallengeCompletionPopup: View {
    let challenge: Challenge
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var sparkleAnimating = false
    @State private var xpCountUp = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            VStack(spacing: 24) {
                // Challenge Emoji with glow effect
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

                    Text(challenge.emoji)
                        .font(.system(size: 70))
                        .scaleEffect(isVisible ? 1.0 : 0.1)
                        .rotationEffect(.degrees(isVisible ? 0 : 180))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.6)
                            .delay(0.1),
                            value: isVisible
                        )
                }

                // Challenge Completed Badge
                Text("Challenge Completed!".localized)
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
                    // Challenge Title
                    Text(challenge.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                        .multilineTextAlignment(.center)

                    // Challenge Details
                    Text(challenge.details)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // XP Reward with count-up animation
                VStack(spacing: 8) {
                    Text("You earned".localized)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    HStack(spacing: 8) {
                        Text("+\(xpCountUp)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(ColorTheme.pink)

                        Text("XP".localized)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.purple)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorTheme.pink.opacity(0.1))
                )

                // Dismiss Button
                Button(action: {
                    dismissWithAnimation()
                }) {
                    Text("Awesome!".localized)
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

            // Animate XP count-up
            animateXPCountUp()

            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                dismissWithAnimation()
            }
        }
    }

    private func animateXPCountUp() {
        let targetXP = challenge.reward.xp
        let duration = 1.0
        let steps = 30
        let increment = targetXP / steps
        let stepDuration = duration / Double(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                xpCountUp = min(increment * (i + 1), targetXP)
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

// MARK: - Sparkle Effect View
struct SparkleEffectView: View {
    @State private var sparkles: [Sparkle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparkles) { sparkle in
                    Image(systemName: "star.fill")
                        .font(.system(size: sparkle.size))
                        .foregroundColor(sparkle.color)
                        .position(x: sparkle.x, y: sparkle.y)
                        .opacity(sparkle.opacity)
                        .scaleEffect(sparkle.scale)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            generateSparkles()
        }
    }

    private func generateSparkles() {
        let sparkleCount = 20
        let colors: [Color] = [
            ColorTheme.pink,
            ColorTheme.purple,
            ColorTheme.yellow,
            .white
        ]

        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2

        for i in 0..<sparkleCount {
            let angle = Double(i) * (360.0 / Double(sparkleCount)) * .pi / 180
            let distance: CGFloat = 150

            let sparkle = Sparkle(
                x: centerX + cos(angle) * 50,
                y: centerY + sin(angle) * 50,
                color: colors.randomElement() ?? ColorTheme.yellow,
                size: CGFloat.random(in: 15...25),
                scale: 0.1,
                opacity: 1.0
            )

            sparkles.append(sparkle)

            // Animate each sparkle outward
            withAnimation(
                .easeOut(duration: 1.0)
                .delay(Double(i) * 0.03)
            ) {
                if let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                    sparkles[index].x = centerX + cos(angle) * distance
                    sparkles[index].y = centerY + sin(angle) * distance
                    sparkles[index].scale = 1.0
                    sparkles[index].opacity = 0.0
                }
            }
        }
    }
}

// MARK: - Sparkle
struct Sparkle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var scale: CGFloat
    var opacity: Double
}

#Preview {
    ChallengeCompletionPopup(
        challenge: Challenge(
            userId: "preview",
            title: "Daily Warrior",
            details: "Make a payment today",
            type: .daily,
            targetValue: 1,
            expiresAt: Date().addingTimeInterval(86400),
            reward: ChallengeReward(xp: 100),
            emoji: "⚡"
        ),
        onDismiss: {}
    )
}
