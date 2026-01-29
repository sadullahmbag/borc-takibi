import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query private var goals: [Goal]
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddGoal = false

    private var activeGoals: [Goal] {
        guard let userId = authManager.userId else { return [] }
        return goals.filter { $0.userId == userId && !$0.isCompleted }.sorted { $0.targetDate < $1.targetDate }
    }

    private var completedGoals: [Goal] {
        guard let userId = authManager.userId else { return [] }
        return goals.filter { $0.userId == userId && $0.isCompleted }.sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Active Goals
                        if !activeGoals.isEmpty {
                            ForEach(activeGoals) { goal in
                                GoalCard(goal: goal, onComplete: {
                                    completeGoal(goal)
                                }, onDelete: {
                                    deleteGoal(goal)
                                })
                            }
                        }

                        // Completed Goals
                        if !completedGoals.isEmpty {
                            VStack(spacing: 12) {
                                Text("Completed".localized)
                                    .font(.headline)
                                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ForEach(completedGoals.prefix(5)) { goal in
                                    CompletedGoalCard(goal: goal, onDelete: {
                                        deleteGoal(goal)
                                    })
                                }
                            }
                        }

                        // Empty state
                        if activeGoals.isEmpty && completedGoals.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Goals".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(ColorTheme.pink)
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView()
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 60))

            Text("Set Your First Goal".localized)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            Text("Set goals to pay off your debts".localized)
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)

            Button(action: { showAddGoal = true }) {
                Text("Add Goal".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(ColorTheme.gradient1)
                    .cornerRadius(15)
            }
            .bouncyPress()
        }
        .padding(.vertical, 60)
    }

    // MARK: - Helper Functions
    private func completeGoal(_ goal: Goal) {
        withAnimation {
            goal.complete()
            HapticManager.shared.success()
        }
    }

    private func deleteGoal(_ goal: Goal) {
        withAnimation {
            modelContext.delete(goal)
            HapticManager.shared.light()
        }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: Goal
    let onComplete: () -> Void
    let onDelete: () -> Void
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text("\(goal.daysRemaining) \("days remaining".localized)")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }

                Spacer()

                // Complete Button
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(ColorTheme.success)
                }
                .bouncyPress()

                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(ColorTheme.red)
                }
                .bouncyPress()
            }

            // Progress
            VStack(spacing: 6) {
                HStack {
                    Text(currencyManager.format(goal.currentAmount))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Spacer()

                    Text(currencyManager.format(goal.targetAmount))
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 10)
                            .fill(ColorTheme.blue)
                            .frame(width: geometry.size.width * goal.progress, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goal.progress)
                    }
                }
                .frame(height: 8)
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

// MARK: - Completed Goal Card
struct CompletedGoalCard: View {
    let goal: Goal
    let onDelete: () -> Void
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundColor(ColorTheme.success)

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                if let completedDate = goal.completedAt {
                    Text(completedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.caption)
                    .foregroundColor(ColorTheme.red.opacity(0.7))
            }
            .bouncyPress()
        }
        .padding(12)
        .background(ColorTheme.success.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Add Goal View
struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var currencyManager = CurrencyManager.shared

    @State private var title = ""
    @State private var targetAmount = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedCategory: GoalCategory = .monthly

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name".localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            TextField("e.g., Pay off credit card".localized, text: $title)
                                .padding()
                                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                .cornerRadius(15)
                        }

                        // Target Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Amount".localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            TextField("0", text: $targetAmount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                .cornerRadius(15)
                        }

                        // Target Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Date".localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            DatePicker("", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                .cornerRadius(15)
                        }

                        // Save Button
                        Button(action: saveGoal) {
                            Text("Create Goal".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    isFormValid
                                        ? ColorTheme.gradient1
                                        : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(20)
                        }
                        .disabled(!isFormValid)
                        .bouncyPress()
                    }
                    .padding()
                }
            }
            .navigationTitle("New Goal".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !title.isEmpty && Double(targetAmount) ?? 0 > 0
    }

    private func saveGoal() {
        guard let amount = Double(targetAmount) else { return }
        guard let userId = authManager.userId else { return }

        let goal = Goal(
            userId: userId,
            title: title,
            targetAmount: amount,
            targetDate: targetDate,
            category: .monthly
        )

        modelContext.insert(goal)
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Goal.self], inMemory: true)
}
