import SwiftUI
import SwiftData

struct GamificationView: View {
    @Query private var challenges: [Challenge]
    @Query private var userProgressList: [UserProgress]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab = 0

    private var userProgress: UserProgress? {
        userProgressList.first
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab Selector
                    customTabSelector

                    // Content
                    TabView(selection: $selectedTab) {
                        ChallengesTab(challenges: challenges)
                            .tag(0)

                        TitlesTab(userProgress: userProgress)
                            .tag(1)

                        PowerUpsTab()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Gamification")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var customTabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Challenges", icon: "flame.fill", isSelected: selectedTab == 0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 0
                }
            }

            TabButton(title: "Titles", icon: "crown.fill", isSelected: selectedTab == 1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 1
                }
            }

            TabButton(title: "Power-Ups", icon: "star.fill", isSelected: selectedTab == 2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedTab = 2
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? ColorTheme.pink : ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? ColorTheme.pink : ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? ColorTheme.pink.opacity(0.1)
                    : Color.clear
            )
            .cornerRadius(10)
        }
        .bouncyPress()
    }
}

// MARK: - Challenges Tab
struct ChallengesTab: View {
    let challenges: [Challenge]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var showNewChallengeAnimation = false

    private var activeChallenges: [Challenge] {
        challenges.filter { !$0.isCompleted && $0.expiresAt > Date() }
    }

    private var completedChallenges: [Challenge] {
        challenges.filter { $0.isCompleted }.sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Daily Challenge Generator
                if activeChallenges.isEmpty {
                    newChallengeSection
                }

                // Active Challenges
                if !activeChallenges.isEmpty {
                    activeChallengesSection
                }

                // Completed Challenges
                if !completedChallenges.isEmpty {
                    completedChallengesSection
                }
            }
            .padding()
        }
    }

    private var newChallengeSection: some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))

            Text("No Active Challenges")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            Text("Generate new challenges to earn XP and rewards!")
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button(action: {
                    generateDailyChallenge()
                }) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                        Text("Generate Daily Challenge")
                            .fontWeight(.semibold)
                        Text("+100 XP")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ColorTheme.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTheme.gradient1)
                    .cornerRadius(15)
                }
                .bouncyPress()

                Button(action: {
                    generateWeeklyChallenge()
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text("Generate Weekly Challenge")
                            .fontWeight(.semibold)
                        Text("+500 XP")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ColorTheme.purple.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [ColorTheme.purple, ColorTheme.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                }
                .bouncyPress()
            }
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

    private var activeChallengesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Active Challenges")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Spacer()

                Button(action: {
                    generateDailyChallenge()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(ColorTheme.pink)
                }
            }

            ForEach(activeChallenges) { challenge in
                ChallengeCard(challenge: challenge)
            }
        }
    }

    private var completedChallengesSection: some View {
        VStack(spacing: 16) {
            Text("Completed Challenges")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(completedChallenges.prefix(10)) { challenge in
                CompletedChallengeCard(challenge: challenge)
            }
        }
    }

    private func generateDailyChallenge() {
        let challenge = ChallengeGenerator.generateDailyChallenge()
        modelContext.insert(challenge)
        HapticManager.shared.success()
        showNewChallengeAnimation = true
    }

    private func generateWeeklyChallenge() {
        let challenge = ChallengeGenerator.generateWeeklyChallenge()
        modelContext.insert(challenge)
        HapticManager.shared.success()
        showNewChallengeAnimation = true
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: Challenge
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            HStack {
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
                        Text("\(challenge.hoursRemaining)h remaining")
                            .font(.caption2)
                    }
                    .foregroundColor(ColorTheme.orange)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("\(challenge.reward.xp)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.pink)

                    Text("XP")
                        .font(.caption2)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(challenge.currentValue)) / \(Int(challenge.targetValue))")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    Spacer()

                    Text("\(Int(challenge.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                }

                ParticleProgressBar(progress: challenge.progress, color: challengeColor)
            }
        }
        .padding()
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [challengeColor.opacity(0.3), challengeColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 5,
            x: 0,
            y: 2
        )
    }

    private var challengeColor: Color {
        switch challenge.type {
        case .daily: return ColorTheme.blue
        case .weekly: return ColorTheme.purple
        case .special: return ColorTheme.pink
        }
    }
}

struct CompletedChallengeCard: View {
    let challenge: Challenge
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(ColorTheme.success)

            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                if let completedDate = challenge.completedAt {
                    Text(completedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("+\(challenge.reward.xp)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.success)

                Text("XP")
                    .font(.caption2)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
            }
        }
        .padding()
        .background(ColorTheme.success.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Titles Tab
struct TitlesTab: View {
    let userProgress: UserProgress?
    @Environment(\.colorScheme) private var colorScheme

    private var availableTitles: [(id: String, name: String, requirement: String, emoji: String, unlocked: Bool)] {
        let progress = userProgress

        return [
            ("novice", "Novice", "Start your journey", "🌱", true),
            ("beginner", "Beginner", "Reach level 3", "📚", (progress?.level ?? 0) >= 3),
            ("determined", "Determined", "Maintain a 3-month streak", "🔥", (progress?.longestStreak ?? 0) >= 3),
            ("achiever", "Achiever", "Complete 5 debts", "🏆", (progress?.debtsCompleted ?? 0) >= 5),
            ("warrior", "Debt Warrior", "Reach level 10", "⚔️", (progress?.level ?? 0) >= 10),
            ("champion", "Champion", "Complete 10 debts", "👑", (progress?.debtsCompleted ?? 0) >= 10),
            ("legend", "Legend", "Reach level 20", "⭐", (progress?.level ?? 0) >= 20),
            ("master", "Debt Master", "Complete 20 debts", "💎", (progress?.debtsCompleted ?? 0) >= 20),
            ("guru", "Financial Guru", "Maintain a 12-month streak", "🧘", (progress?.longestStreak ?? 0) >= 12),
            ("titan", "Titan", "Reach level 50", "🌟", (progress?.level ?? 0) >= 50)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Current Title
                currentTitleSection

                // All Titles
                allTitlesSection
            }
            .padding()
        }
    }

    private var currentTitleSection: some View {
        VStack(spacing: 16) {
            Text("Your Current Title")
                .font(.headline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

            let unlockedTitles = availableTitles.filter { $0.unlocked }
            let currentTitle = unlockedTitles.last ?? availableTitles.first!

            VStack(spacing: 12) {
                Text(currentTitle.emoji)
                    .font(.system(size: 60))
                    .pulseEffect(color: ColorTheme.pink)

                Text(currentTitle.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Text(currentTitle.requirement)
                    .font(.caption)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                LinearGradient(
                    colors: [ColorTheme.pink.opacity(0.15), ColorTheme.purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(25)
        }
    }

    private var allTitlesSection: some View {
        VStack(spacing: 16) {
            Text("All Titles")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(availableTitles, id: \.id) { title in
                    TitleCard(
                        emoji: title.emoji,
                        name: title.name,
                        requirement: title.requirement,
                        isUnlocked: title.unlocked
                    )
                }
            }
        }
    }
}

struct TitleCard: View {
    let emoji: String
    let name: String
    let requirement: String
    let isUnlocked: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.4)

            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Text(requirement)
                .font(.caption)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            isUnlocked
                ? LinearGradient(
                    colors: [ColorTheme.pink.opacity(0.1), ColorTheme.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                : LinearGradient(
                    colors: [ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    isUnlocked ? ColorTheme.pink.opacity(0.3) : Color.gray.opacity(0.2),
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Power-Ups Tab
struct PowerUpsTab: View {
    @Environment(\.colorScheme) private var colorScheme

    private let powerUps: [(name: String, description: String, cost: Int, emoji: String, color: Color)] = [
        ("Double XP", "2x XP for next payment", 500, "⚡", ColorTheme.orange),
        ("Streak Shield", "Protect your streak", 1000, "🛡️", ColorTheme.blue),
        ("Instant Goal", "Complete a goal instantly", 2000, "🎯", ColorTheme.purple),
        ("XP Boost", "Gain 500 XP instantly", 300, "🚀", ColorTheme.success),
        ("Lucky Spin", "Random reward bonus", 100, "🎰", ColorTheme.pink)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                ForEach(powerUps, id: \.name) { powerUp in
                    PowerUpCard(
                        name: powerUp.name,
                        description: powerUp.description,
                        cost: powerUp.cost,
                        emoji: powerUp.emoji,
                        color: powerUp.color
                    )
                }
            }
            .padding()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("⚡")
                .font(.system(size: 60))

            Text("Power-Ups")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            Text("Boost your progress with special abilities!")
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PowerUpCard: View {
    let name: String
    let description: String
    let cost: Int
    let emoji: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: {
            HapticManager.shared.medium()
        }) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(color.opacity(0.15))
                    .cornerRadius(15)

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text(description)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        .lineLimit(2)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("\(cost)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(color)

                    Text("XP")
                        .font(.caption2)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }
            .padding()
            .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
            .shadow(
                color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
                radius: 5,
                x: 0,
                y: 2
            )
        }
        .bouncyPress()
    }
}

#Preview {
    GamificationView()
        .modelContainer(for: [Challenge.self, UserProgress.self], inMemory: true)
}
