import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @Namespace private var animation

    private let pages: [(emoji: String, title: String, description: String)] = [
        ("🎯", "Welcome to Borciva", "Your journey to financial freedom starts here. Track, manage, and celebrate every step."),
        ("💰", "Add Your Debts", "Tap + to add debts. Customize with emojis, colors, and categories for a personal touch."),
        ("🎉", "Make Payments", "Every payment triggers celebrations! Watch your progress grow and earn achievements."),
        ("🏆", "Level Up & Achieve", "Gain XP, unlock achievements, and build payment streaks. Make debt payoff fun!")
    ]

    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            completeOnboarding()
                        }
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ColorTheme.textSecondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPage(
                            emoji: pages[index].emoji,
                            title: pages[index].title,
                            description: pages[index].description
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        if index == currentPage {
                            Capsule()
                                .fill(ColorTheme.gradient1)
                                .frame(width: 24, height: 8)
                                .matchedGeometryEffect(id: "indicator", in: animation)
                        } else {
                            Circle()
                                .fill(ColorTheme.textSecondary.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.bottom, 30)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentPage)

                // Action button
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                            HapticManager.shared.light()
                        } else {
                            completeOnboarding()
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                            .font(.headline)
                            .foregroundColor(.white)

                        Image(systemName: currentPage == pages.count - 1 ? "checkmark" : "arrow.right")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [ColorTheme.pink, ColorTheme.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: ColorTheme.pink.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        HapticManager.shared.success()
        showOnboarding = false
    }
}

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text(emoji)
                .font(.system(size: 120))
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: emoji)

            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(ColorTheme.gradient1)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
