import SwiftUI
import SwiftData

struct GamificationView: View {
    @Query private var challenges: [Challenge]
    @Query private var userProgressList: [UserProgress]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var authManager = AuthManager.shared

    private var userProgress: UserProgress? {
        guard let userId = authManager.userId else { return nil }
        return userProgressList.first { $0.userId == userId }
    }

    private var activeChallenges: [Challenge] {
        guard let userId = authManager.userId else { return [] }
        return challenges.filter { $0.userId == userId && !$0.isCompleted && $0.expiresAt > Date() }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Progress Section
                        if let progress = userProgress {
                            progressSection(progress: progress)
                        }

                        // Challenges
                        challengesSection

                        // Quick Challenge Buttons
                        quickChallengeButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Progress Section
    private func progressSection(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorTheme.gradient1)
                    .frame(width: 100, height: 100)

                VStack(spacing: 4) {
                    Text("\(progress.level)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Level".localized)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            Text("\("Experience".localized): \(progress.experience) / \(progress.experienceToNextLevel)")
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

    // MARK: - Challenges Section
    private var challengesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Active Challenges".localized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Spacer()
            }

            if activeChallenges.isEmpty {
                emptyChallengesView
            } else {
                ForEach(activeChallenges) { challenge in
                    SimpleChallengeCard(challenge: challenge, onDelete: {
                        deleteChallenge(challenge)
                    })
                }
            }
        }
    }

    // MARK: - Empty Challenges View
    private var emptyChallengesView: some View {
        VStack(spacing: 12) {
            Text("🎯")
                .font(.system(size: 50))

            Text("No challenges".localized)
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(20)
    }

    // MARK: - Quick Challenge Buttons
    private var quickChallengeButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                generateDailyChallenge()
            }) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(ColorTheme.orange)
                    Text("Add Daily Challenge".localized)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("+100 \("XP".localized)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ColorTheme.orange.opacity(0.2))
                        .cornerRadius(8)
                }
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .padding()
                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                .cornerRadius(15)
            }
            .bouncyPress()

            Button(action: {
                generateWeeklyChallenge()
            }) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(ColorTheme.purple)
                    Text("Add Weekly Challenge".localized)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("+500 \("XP".localized)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ColorTheme.purple.opacity(0.2))
                        .cornerRadius(8)
                }
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .padding()
                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                .cornerRadius(15)
            }
            .bouncyPress()
        }
    }

    // MARK: - Helper Functions
    private func generateDailyChallenge() {
        guard let userId = authManager.userId else { return }
        let challenge = ChallengeGenerator.generateDailyChallenge(for: userId)
        modelContext.insert(challenge)
        HapticManager.shared.success()
    }

    private func generateWeeklyChallenge() {
        guard let userId = authManager.userId else { return }
        let challenge = ChallengeGenerator.generateWeeklyChallenge(for: userId)
        modelContext.insert(challenge)
        HapticManager.shared.success()
    }

    private func deleteChallenge(_ challenge: Challenge) {
        withAnimation {
            modelContext.delete(challenge)
            HapticManager.shared.light()
        }
    }
}

// MARK: - Simple Challenge Card
struct SimpleChallengeCard: View {
    let challenge: Challenge
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Text(challenge.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.headline)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Text(challenge.details)
                    .font(.caption)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(challenge.hoursRemaining)\("h left".localized)")
                        .font(.caption2)
                }
                .foregroundColor(ColorTheme.orange)
            }

            Spacer()

            VStack(spacing: 8) {
                Text("+\(challenge.reward.xp)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.pink)

                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundColor(ColorTheme.red.opacity(0.7))
                }
                .bouncyPress()
            }
        }
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

#Preview {
    GamificationView()
        .modelContainer(for: [Challenge.self, UserProgress.self], inMemory: true)
}
