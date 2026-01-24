import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Debt.createdDate, order: .reverse) private var debts: [Debt]
    @Query private var userProgressList: [UserProgress]

    @State private var showAddDebt = false
    @State private var selectedDebt: Debt?
    @State private var showPayment = false

    private var activeDebts: [Debt] {
        debts.filter { !$0.isCompleted }
    }

    private var totalDebt: Double {
        activeDebts.reduce(0) { $0 + $1.currentAmount }
    }

    private var totalPaid: Double {
        debts.reduce(0) { $0 + $1.amountPaid }
    }

    private var userProgress: UserProgress? {
        userProgressList.first
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        DebtSummaryCard(
                            totalDebt: totalDebt,
                            debtsCount: activeDebts.count,
                            totalPaid: totalPaid
                        )
                        .padding(.horizontal)

                        if let progress = userProgress {
                            progressBanner(progress: progress)
                                .padding(.horizontal)
                        }

                        debtsListSection
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("DebtFree")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(ColorTheme.gradient1)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddDebt = true
                        HapticManager.shared.light()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ColorTheme.gradient1)
                    }
                }
            }
            .sheet(isPresented: $showAddDebt) {
                AddDebtView()
            }
            .sheet(item: $selectedDebt) { debt in
                PaymentView(debt: debt)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🎯")
                .font(.system(size: 50))

            if activeDebts.isEmpty {
                Text("You're debt-free!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTheme.success)
            } else {
                Text("Your Debt Journey")
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

                    Text("LVL")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(progress.level)")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)

                ProgressView(value: progress.currentLevelProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.blue))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)

                Text("\(progress.experience) / \(progress.experienceToNextLevel) XP")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
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
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }

    private var debtsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Debts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.textPrimary)

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

            if activeDebts.isEmpty {
                emptyStateView
            } else {
                ForEach(activeDebts) { debt in
                    DebtCardView(debt: debt) {
                        selectedDebt = debt
                        showPayment = true
                    }
                    .padding(.horizontal)
                }
            }

            if !debts.filter({ $0.isCompleted }).isEmpty {
                completedDebtsSection
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 60))

            Text("No Active Debts")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(ColorTheme.textPrimary)

            Text("Tap the + button to add a new debt")
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            Button(action: {
                showAddDebt = true
                HapticManager.shared.light()
            }) {
                Text("Add Your First Debt")
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
            Text("Completed")
                .font(.headline)
                .foregroundColor(ColorTheme.textSecondary)
                .padding(.horizontal)

            ForEach(debts.filter { $0.isCompleted }) { debt in
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

                Text("Completed")
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
