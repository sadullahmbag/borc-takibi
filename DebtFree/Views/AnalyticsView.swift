import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query private var debts: [Debt]
    @Query private var payments: [Payment]
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private var filteredDebts: [Debt] {
        guard let userId = authManager.userId else { return [] }
        return debts.filter { $0.userId == userId }
    }

    private var filteredPayments: [Payment] {
        guard let userId = authManager.userId else { return [] }
        return payments.filter { $0.userId == userId }
    }

    private var activeDebts: [Debt] {
        filteredDebts.filter { !$0.isCompleted }
    }

    private var completedDebts: [Debt] {
        filteredDebts.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Summary Cards
                        summaryCards

                        // Debt Breakdown Chart
                        debtBreakdownChart

                        // Payment Trend Chart
                        paymentTrendChart

                        // Category Breakdown
                        categoryBreakdownChart

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            AnalyticsCard(
                title: "Total Debt",
                value: currencyManager.format(totalDebtAmount),
                icon: "dollarsign.circle.fill",
                color: ColorTheme.red
            )

            AnalyticsCard(
                title: "Total Paid",
                value: currencyManager.format(totalPaidAmount),
                icon: "checkmark.circle.fill",
                color: ColorTheme.success
            )

            AnalyticsCard(
                title: "Active Debts",
                value: "\(activeDebts.count)",
                icon: "creditcard.fill",
                color: ColorTheme.blue
            )

            AnalyticsCard(
                title: "Completed",
                value: "\(completedDebts.count)",
                icon: "trophy.fill",
                color: ColorTheme.orange
            )
        }
    }

    // MARK: - Debt Breakdown Chart
    private var debtBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Debt Progress")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            if !activeDebts.isEmpty {
                VStack(spacing: 16) {
                    Chart(activeDebts) { debt in
                        BarMark(
                            x: .value("Debt", debt.name),
                            y: .value("Amount", debt.currentAmount)
                        )
                        .foregroundStyle(by: .value("Type", "Remaining"))
                        .foregroundStyle(ColorTheme.color(for: debt.color).opacity(0.7))

                        BarMark(
                            x: .value("Debt", debt.name),
                            y: .value("Amount", debt.amountPaid)
                        )
                        .foregroundStyle(by: .value("Type", "Paid"))
                        .foregroundStyle(ColorTheme.success.opacity(0.7))
                    }
                    .frame(height: 250)
                    .chartYAxis {
                        AxisMarks(position: .leading)
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
            } else {
                emptyStateView(message: "No active debts to display")
            }
        }
    }

    // MARK: - Payment Trend Chart
    private var paymentTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Trend (Last 30 Days)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            if !filteredPayments.isEmpty {
                let last30DaysPayments = paymentsLast30Days

                VStack(spacing: 16) {
                    Chart(last30DaysPayments) { payment in
                        LineMark(
                            x: .value("Date", payment.date),
                            y: .value("Amount", payment.amount)
                        )
                        .foregroundStyle(ColorTheme.gradient1)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", payment.date),
                            y: .value("Amount", payment.amount)
                        )
                        .foregroundStyle(ColorTheme.pink)
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }

                    // Summary stats
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                            Text(currencyManager.format(last30DaysTotal))
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                        }

                        Divider()
                            .frame(height: 30)

                        VStack(spacing: 4) {
                            Text("Payments")
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                            Text("\(last30DaysPayments.count)")
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                        }

                        Divider()
                            .frame(height: 30)

                        VStack(spacing: 4) {
                            Text("Average")
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                            Text(currencyManager.format(last30DaysAverage))
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                        }
                    }
                    .frame(maxWidth: .infinity)
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
            } else {
                emptyStateView(message: "No payments to display")
            }
        }
    }

    // MARK: - Category Breakdown Chart
    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Debt by Category")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

            if !filteredDebts.isEmpty {
                let categoryData = debtsByCategory

                VStack(spacing: 16) {
                    Chart(categoryData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Category", item.category))
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom, alignment: .center)

                    // Category list
                    VStack(spacing: 8) {
                        ForEach(categoryData, id: \.category) { item in
                            HStack {
                                Text(Debt.categoryEmojis[item.category] ?? "💰")
                                Text(item.category)
                                    .font(.subheadline)
                                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                                Spacer()
                                Text(currencyManager.format(item.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                            }
                            .padding(.vertical, 4)
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
            } else {
                emptyStateView(message: "No debts to categorize")
            }
        }
    }

    // MARK: - Helper Views
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("📊")
                .font(.system(size: 50))

            Text(message)
                .font(.subheadline)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
        .cornerRadius(20)
    }

    // MARK: - Computed Properties
    private var totalDebtAmount: Double {
        activeDebts.reduce(0) { $0 + $1.currentAmount }
    }

    private var totalPaidAmount: Double {
        filteredDebts.reduce(0) { $0 + $1.amountPaid }
    }

    private var paymentsLast30Days: [Payment] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return filteredPayments
            .filter { $0.date >= thirtyDaysAgo }
            .sorted { $0.date < $1.date }
    }

    private var last30DaysTotal: Double {
        paymentsLast30Days.reduce(0) { $0 + $1.amount }
    }

    private var last30DaysAverage: Double {
        let count = paymentsLast30Days.count
        return count > 0 ? last30DaysTotal / Double(count) : 0
    }

    private var debtsByCategory: [(category: String, amount: Double)] {
        let categories = Dictionary(grouping: filteredDebts, by: { $0.category })
        return categories.map { (category: $0.key, amount: $0.value.reduce(0) { $0 + $1.currentAmount }) }
            .sorted { $0.amount > $1.amount }
    }
}

// MARK: - Analytics Card
struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
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

#Preview {
    AnalyticsView()
        .modelContainer(for: [Debt.self, Payment.self], inMemory: true)
}
