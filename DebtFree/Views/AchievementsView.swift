import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var userProgressList: [UserProgress]
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private var userProgress: UserProgress? {
        userProgressList.first
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let progress = userProgress {
                            profileSection(progress: progress)
                            statsSection(progress: progress)
                            achievementsSection(progress: progress)
                        } else {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func profileSection(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorTheme.gradient1)
                    .frame(width: 100, height: 100)

                VStack(spacing: 4) {
                    Text("\(progress.level)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            Text("Experience: \(progress.experience) / \(progress.experienceToNextLevel)")
                .font(.caption)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

            ProgressView(value: progress.currentLevelProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.purple))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .frame(width: 200)
        }
        .padding(24)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(25)
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    private func statsSection(progress: UserProgress) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Stats")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Total Paid",
                    value: currencyManager.format(progress.totalPaid),
                    color: ColorTheme.success,
                    icon: "dollarsign.circle.fill"
                )

                StatCard(
                    title: "Debts Completed",
                    value: "\(progress.debtsCompleted)",
                    color: ColorTheme.blue,
                    icon: "checkmark.circle.fill"
                )

                StatCard(
                    title: "Current Streak",
                    value: "\(progress.currentStreak) months",
                    color: ColorTheme.orange,
                    icon: "flame.fill"
                )

                StatCard(
                    title: "Longest Streak",
                    value: "\(progress.longestStreak) months",
                    color: ColorTheme.purple,
                    icon: "star.fill"
                )
            }
        }
    }

    private func achievementsSection(progress: UserProgress) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            Text("\(progress.achievementsUnlocked.count) of \(UserProgress.achievements.count) unlocked")
                .font(.caption)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(UserProgress.achievements, id: \.id) { achievement in
                    AchievementCard(
                        achievement: achievement,
                        isUnlocked: progress.achievementsUnlocked.contains(achievement.id)
                    )
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 80))

            Text("Start Your Journey")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)

            Text("Add a debt and make your first payment to start earning achievements!")
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(20)
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 5,
            x: 0,
            y: 2
        )
    }
}

struct AchievementCard: View {
    let achievement: (id: String, title: String, description: String, emoji: String, requirement: (UserProgress) -> Bool)
    let isUnlocked: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.emoji)
                .font(.system(size: 40))
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.4)

            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(achievement.description)
                .font(.system(size: 10))
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    colorScheme == .dark
                        ? (isUnlocked ? ColorTheme.dynamicCardBackground(colorScheme: colorScheme) : Color(hex: "2C2C2E").opacity(0.5))
                        : (isUnlocked ? Color.white : Color.white.opacity(0.6))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isUnlocked ? ColorTheme.success : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
}
