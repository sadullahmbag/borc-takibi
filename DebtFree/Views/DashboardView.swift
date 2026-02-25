import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var authManager = AuthManager.shared
    @Query(sort: \Debt.createdDate, order: .reverse) private var debts: [Debt]
    @Query private var userProgressList: [UserProgress]
    @Query private var challenges: [Challenge]
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    @StateObject private var popupManager = PopupManager.shared

    @State private var showAddDebt = false
    @State private var selectedDebt: Debt?
    @State private var showPayment = false
    @State private var isRefreshing = false
    @State private var showDeleteConfirmation = false
    @State private var debtToDelete: Debt?

    private var filteredDebts: [Debt] {
        guard let userId = authManager.userId else { return [] }
        return debts.filter { $0.userId == userId }
    }

    private var activeDebts: [Debt] {
        filteredDebts.filter { !$0.isCompleted }
    }

    private var totalDebt: Double {
        activeDebts.reduce(0) { $0 + $1.currentAmount }
    }

    private var totalPaid: Double {
        filteredDebts.reduce(0) { $0 + $1.amountPaid }
    }

    private var userProgress: UserProgress? {
        guard let userId = authManager.userId else { return nil }
        return userProgressList.first { $0.userId == userId }
    }

    private var filteredChallenges: [Challenge] {
        guard let userId = authManager.userId else { return [] }
        return challenges.filter { $0.userId == userId }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        DebtSummaryCard(
                            totalDebt: totalDebt,
                            debtsCount: activeDebts.count,
                            totalPaid: totalPaid
                        )
                        .padding(.horizontal)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Total debt summary".localized)

                        if let progress = userProgress {
                            progressBanner(progress: progress)
                                .padding(.horizontal)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\("Level".localized) \(progress.level) \("Progress".localized)")
                        }

                        // Analytics Link
                        NavigationLink(destination: AnalyticsView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("View Analytics")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                                    Text("Detailed charts and insights")
                                        .font(.caption)
                                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                                }

                                Spacer()

                                Image(systemName: "chart.bar.fill")
                                    .font(.title2)
                                    .foregroundColor(ColorTheme.pink)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [ColorTheme.pink.opacity(0.15), ColorTheme.purple.opacity(0.15)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(ColorTheme.pink.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)

                        debtsListSection
                    }
                    .padding(.vertical)
                }
                .pullToRefresh {
                    await refreshData()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Borciva")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorTheme.gradient1)
                        .accessibilityAddTraits(.isHeader)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddDebt = true
                        HapticManager.shared.light()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ColorTheme.gradient1)
                            .symbolEffect(.bounce, value: showAddDebt)
                    }
                    .accessibilityLabel("Add new debt".localized)
                }
            }
            .sheet(isPresented: $showAddDebt) {
                AddDebtView()
            }
            .sheet(item: $selectedDebt) { debt in
                PaymentView(debt: debt)
            }
            .alert("Delete Debt?".localized, isPresented: $showDeleteConfirmation) {
                Button("Cancel".localized, role: .cancel) {
                    debtToDelete = nil
                }
                Button("Delete".localized, role: .destructive) {
                    if let debt = debtToDelete {
                        deleteDebt(debt)
                    }
                }
            } message: {
                if debtToDelete != nil {
                    Text("Are you sure you want to delete this debt? This action cannot be undone.".localized)
                }
            }
            .overlay {
                // Achievement Popup
                if let achievement = popupManager.achievementToShow {
                    AchievementPopupOverlay(
                        achievement: achievement,
                        onDismiss: {
                            popupManager.dismissAchievement()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .overlay {
                // Challenge Completion Popup
                if let challenge = popupManager.challengeToShow {
                    ChallengeCompletionPopup(
                        challenge: challenge,
                        onDismiss: {
                            popupManager.dismissChallenge()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
        }
    }

    private func refreshData() async {
        isRefreshing = true
        HapticManager.shared.light()
        try? await Task.sleep(nanoseconds: 500_000_000)
        isRefreshing = false
    }

    private func deleteDebt(_ debt: Debt) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            modelContext.delete(debt)
            HapticManager.shared.success()
        }
        debtToDelete = nil
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🎯")
                .font(.system(size: 50))

            if activeDebts.isEmpty {
                Text("You're debt-free!".localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTheme.success)
            } else {
                Text("Your Debt Journey".localized)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textSecondary)
            }
        }
        .padding(.top)
    }

    private func progressBanner(progress: UserProgress) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorTheme.gradient2)
                    .frame(width: 60, height: 60)

                VStack(spacing: 0) {
                    Text("\(progress.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("LVL".localized)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\("Level".localized) \(progress.level)")

            VStack(alignment: .leading, spacing: 4) {
                Text("\("Level".localized) \(progress.level)")
                    .font(.headline)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                ProgressView(value: progress.currentLevelProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.blue))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .accessibilityValue("\(Int(progress.currentLevelProgress * 100)) percent")

                Text("\(progress.experience) / \(progress.experienceToNextLevel) \("XP".localized)")
                    .font(.caption)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
            }

            Spacer()

            if progress.currentStreak > 0 {
                VStack(spacing: 4) {
                    Text("🔥")
                        .font(.title)

                    Text("\(progress.currentStreak)")
                        .font(.headline)
                        .foregroundColor(ColorTheme.orange)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(progress.currentStreak) \("month streak".localized)")
            }
        }
        .padding(20)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(20)
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    private var debtsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Debts".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Spacer()

                if !activeDebts.isEmpty {
                    Text("\(activeDebts.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ColorTheme.pink)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\("Your Debts".localized), \(activeDebts.count) \("Active Debts".localized)")

            if activeDebts.isEmpty {
                emptyStateView
            } else {
                ForEach(activeDebts.indices, id: \.self) { index in
                    DebtCardView(debt: activeDebts[index]) {
                        selectedDebt = activeDebts[index]
                        showPayment = true
                    }
                    .padding(.horizontal)
                    .transition(
                        accessibilityManager.reduceMotion
                            ? .opacity
                            : .asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            )
                    )
                    .swipeToDelete {
                        debtToDelete = activeDebts[index]
                        showDeleteConfirmation = true
                    }
                    .longPressMenu {
                        Button(action: {
                            selectedDebt = activeDebts[index]
                            showPayment = true
                        }) {
                            Label("Make Payment".localized, systemImage: "dollarsign.circle")
                        }

                        Button(role: .destructive, action: {
                            debtToDelete = activeDebts[index]
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete".localized, systemImage: "trash")
                        }
                    }
                    .animation(
                        accessibilityManager.reduceMotion
                            ? .none
                            : .spring(response: 0.5, dampingFraction: 0.8),
                        value: activeDebts.count
                    )
                }
            }

            if !filteredDebts.filter({ $0.isCompleted }).isEmpty {
                completedDebtsSection
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 60))

            Text("No Active Debts".localized)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(ColorTheme.textPrimary)

            Text("Tap the + button to add a new debt".localized)
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            Button(action: {
                showAddDebt = true
                HapticManager.shared.light()
            }) {
                Text("Add Your First Debt".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(ColorTheme.gradient1)
                    .cornerRadius(25)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private var completedDebtsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completed".localized)
                .font(.headline)
                .foregroundColor(ColorTheme.textSecondary)
                .padding(.horizontal)

            ForEach(filteredDebts.filter { $0.isCompleted }) { debt in
                CompletedDebtCard(debt: debt)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

struct CompletedDebtCard: View {
    let debt: Debt

    var body: some View {
        HStack {
            Text(debt.emoji)
                .font(.title)
                .grayscale(0.5)
                .opacity(0.6)

            VStack(alignment: .leading, spacing: 4) {
                Text(debt.name)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textSecondary)
                    .strikethrough()

                Text("Completed".localized)
                    .font(.caption)
                    .foregroundColor(ColorTheme.success)
            }

            Spacer()

            Text("✓")
                .font(.title2)
                .foregroundColor(ColorTheme.success)
        }
        .padding(16)
        .background(Color.white.opacity(0.5))
        .cornerRadius(15)
    }
}
