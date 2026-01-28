import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query private var goals: [Goal]
    @Query private var debts: [Debt]
    @Query private var payments: [Payment]
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddGoal = false
    @State private var showSmartSuggestions = false

    // Smart calculations
    private var totalDebtRemaining: Double {
        debts.filter { !$0.isCompleted }.reduce(0) { $0 + $1.currentAmount }
    }

    private var averageMonthlyPayment: Double {
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        let recentPayments = payments.filter { $0.date >= threeMonthsAgo }

        guard !recentPayments.isEmpty else { return 0 }
        return recentPayments.reduce(0) { $0 + $1.amount } / 3
    }

    private var debtFreeDate: Date? {
        guard totalDebtRemaining > 0, averageMonthlyPayment > 0 else { return nil }
        let monthsNeeded = Int(ceil(totalDebtRemaining / averageMonthlyPayment))
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: monthsNeeded, to: Date())
    }

    private var activeGoals: [Goal] {
        goals.filter { !$0.isCompleted }.sorted { $0.targetDate < $1.targetDate }
    }

    private var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }.sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Debt-Free Date Prediction
                        if let debtFreeDate = debtFreeDate {
                            debtFreePredictionCard(date: debtFreeDate)
                        }

                        // Smart Suggestions
                        smartSuggestionsSection

                        // Active Goals
                        if !activeGoals.isEmpty {
                            activeGoalsSection
                        }

                        // Completed Goals
                        if !completedGoals.isEmpty {
                            completedGoalsSection
                        }

                        // Empty state
                        if activeGoals.isEmpty && completedGoals.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Goals")
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

    // MARK: - Debt-Free Prediction Card
    private func debtFreePredictionCard(date: Date) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(ColorTheme.success)

                Text("Smart Prediction")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("You could be debt-free by")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                Text(date, style: .date)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(ColorTheme.success)

                    Text("Based on your average monthly payment of \(currencyManager.format(averageMonthlyPayment))")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(ColorTheme.success.opacity(0.1))
            .cornerRadius(15)
        }
        .padding(20)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(25)
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Smart Suggestions
    private var smartSuggestionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Smart Suggestions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Spacer()

                Button(action: { showSmartSuggestions.toggle() }) {
                    Image(systemName: showSmartSuggestions ? "chevron.up" : "chevron.down")
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            if showSmartSuggestions {
                VStack(spacing: 12) {
                    // Suggestion: Monthly Goal
                    if averageMonthlyPayment > 0 {
                        SmartSuggestionCard(
                            icon: "calendar",
                            title: "Set Monthly Goal",
                            description: "Based on your history, aim to pay \(currencyManager.format(averageMonthlyPayment * 1.1)) this month",
                            action: {
                                createMonthlyGoal(amount: averageMonthlyPayment * 1.1)
                            }
                        )
                    }

                    // Suggestion: Focus on High Interest
                    if let highInterestDebt = debts.filter({ !$0.isCompleted && $0.category == .highInterest }).first {
                        SmartSuggestionCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Pay High Interest First",
                            description: "Focus on \(highInterestDebt.name) to save money on interest",
                            action: {
                                // Navigate to debt detail
                            }
                        )
                    }

                    // Suggestion: Milestone
                    if totalDebtRemaining > 0 {
                        let halfwayPoint = totalDebtRemaining / 2
                        SmartSuggestionCard(
                            icon: "flag.fill",
                            title: "Halfway Milestone",
                            description: "Create a goal to reach \(currencyManager.format(halfwayPoint)) remaining",
                            action: {
                                createMilestoneGoal(targetAmount: halfwayPoint)
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(25)
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Active Goals Section
    private var activeGoalsSection: some View {
        VStack(spacing: 16) {
            Text("Active Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(activeGoals) { goal in
                GoalCard(goal: goal)
                    .swipeToDelete {
                        withAnimation {
                            modelContext.delete(goal)
                        }
                    }
            }
        }
    }

    // MARK: - Completed Goals Section
    private var completedGoalsSection: some View {
        VStack(spacing: 16) {
            Text("Completed Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(completedGoals.prefix(5)) { goal in
                CompletedGoalCard(goal: goal)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 80))

            Text("Set Your First Goal")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            Text("Create smart goals to track your debt payoff journey")
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { showAddGoal = true }) {
                Text("Create Goal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(ColorTheme.gradient1)
                    .cornerRadius(15)
            }
            .bouncyPress()
        }
        .padding(.vertical, 40)
    }

    // MARK: - Helper Functions
    private func createMonthlyGoal(amount: Double) {
        let calendar = Calendar.current
        let endOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.date(byAdding: .month, value: 1, to: Date())!))!

        let goal = Goal(
            title: "Monthly Payment Goal",
            targetAmount: amount,
            targetDate: endOfMonth,
            category: .monthly
        )
        modelContext.insert(goal)
        HapticManager.shared.success()
    }

    private func createMilestoneGoal(targetAmount: Double) {
        let calendar = Calendar.current
        let threeMonthsLater = calendar.date(byAdding: .month, value: 3, to: Date())!

        let goal = Goal(
            title: "Halfway to Debt Free",
            targetAmount: targetAmount,
            targetDate: threeMonthsLater,
            category: .milestone
        )
        modelContext.insert(goal)
        HapticManager.shared.success()
    }
}

// MARK: - Supporting Views

struct SmartSuggestionCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(ColorTheme.blue)
                    .frame(width: 40, height: 40)
                    .background(ColorTheme.blue.opacity(0.15))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text(description)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(ColorTheme.blue)
            }
            .padding()
            .background(ColorTheme.blue.opacity(0.05))
            .cornerRadius(15)
        }
        .bouncyPress()
    }
}

struct GoalCard: View {
    let goal: Goal
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: goal.category.icon)
                    .font(.title3)
                    .foregroundColor(categoryColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text(goal.category.rawValue)
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(goal.daysRemaining) days")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    Text(goal.targetDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text(currencyManager.format(goal.currentAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Spacer()

                    Text(currencyManager.format(goal.targetAmount))
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.2))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor, categoryColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * goal.progress, height: 12)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goal.progress)
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("\(Int(goal.progress * 100))% complete")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    Spacer()
                }
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

    private var categoryColor: Color {
        switch goal.category {
        case .monthly: return ColorTheme.blue
        case .milestone: return ColorTheme.purple
        case .custom: return ColorTheme.pink
        case .debtFree: return ColorTheme.success
        }
    }
}

struct CompletedGoalCard: View {
    let goal: Goal
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(ColorTheme.success)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                if let completedDate = goal.completedAt {
                    Text("Completed \(completedDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            Spacer()

            Text(currencyManager.format(goal.targetAmount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ColorTheme.success)
        }
        .padding()
        .background(ColorTheme.success.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Add Goal View
struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
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
                    VStack(spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Title")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            TextField("e.g., Pay off credit card", text: $title)
                                .padding()
                                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                .cornerRadius(15)
                        }

                        // Target Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Amount")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            TextField("0.00", text: $targetAmount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                .cornerRadius(15)
                        }

                        // Target Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Date")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            DatePicker("", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                .cornerRadius(15)
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack {
                                        Image(systemName: category.icon)
                                            .foregroundColor(selectedCategory == category ? ColorTheme.pink : ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                                        Text(category.rawValue)
                                            .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                                        Spacer()

                                        if selectedCategory == category {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(ColorTheme.pink)
                                        }
                                    }
                                    .padding()
                                    .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                                    .cornerRadius(15)
                                }
                                .bouncyPress()
                            }
                        }

                        // Save Button
                        Button(action: saveGoal) {
                            Text("Create Goal")
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
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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

        let goal = Goal(
            title: title,
            targetAmount: amount,
            targetDate: targetDate,
            category: selectedCategory
        )

        modelContext.insert(goal)
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Goal.self, Debt.self, Payment.self], inMemory: true)
}
