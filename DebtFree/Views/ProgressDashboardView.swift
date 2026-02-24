import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query private var debts: [Debt]
    @Query private var payments: [Payment]
    @Query private var userProgressList: [UserProgress]
    @StateObject private var currencyManager = CurrencyManager.shared
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private var filteredDebts: [Debt] {
        guard let userId = authManager.userId else { return [] }
        return debts.filter { $0.userId == userId }
    }

    private var filteredPayments: [Payment] {
        guard let userId = authManager.userId else { return [] }
        return payments.filter { $0.userId == userId }
    }

    private var userProgress: UserProgress? {
        guard let userId = authManager.userId else { return nil }
        return userProgressList.first { $0.userId == userId }
    }

    // Calculate total debt (original)
    private var totalOriginalDebt: Double {
        filteredDebts.reduce(0) { $0 + $1.originalAmount }
    }

    // Calculate remaining debt
    private var totalRemainingDebt: Double {
        filteredDebts.filter { !$0.isCompleted }.reduce(0) { $0 + $1.currentAmount }
    }

    // Calculate overall progress
    private var overallProgress: Double {
        guard totalOriginalDebt > 0 else { return 0 }
        return (totalOriginalDebt - totalRemainingDebt) / totalOriginalDebt
    }

    // Get payment activity for heat map
    private var paymentsByMonth: [String: [Payment]] {
        let calendar = Calendar.current
        var result: [String: [Payment]] = [:]

        for payment in filteredPayments {
            let components = calendar.dateComponents([.year, .month], from: payment.date)
            if let year = components.year, let month = components.month {
                let key = "\(year)-\(String(format: "%02d", month))"
                result[key, default: []].append(payment)
            }
        }

        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Rings Section
                progressRingsSection

                // Monthly Heat Map
                monthlyHeatMapSection

                // Yearly Overview
                yearlyOverviewSection

                // Milestones
                milestonesSection

                // Before/After Comparison
                beforeAfterSection
            }
            .padding()
        }
        .background(ColorTheme.dynamicBackground(colorScheme: colorScheme).ignoresSafeArea())
    }

    // MARK: - Progress Rings (Apple Health Style)
    private var progressRingsSection: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                // Outer ring - Total Progress
                Circle()
                    .stroke(
                        ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.2),
                        lineWidth: 20
                    )
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: overallProgress)
                    .stroke(
                        LinearGradient(
                            colors: [ColorTheme.pink, ColorTheme.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: overallProgress)

                // Inner content
                VStack(spacing: 4) {
                    Text("\(Int(overallProgress * 100))%")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                    Text("Debt Free")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }
            .padding(.vertical, 24)

            // Stats Grid
            HStack(spacing: 16) {
                ProgressStatCard(
                    title: "Paid",
                    value: currencyManager.format(totalOriginalDebt - totalRemainingDebt),
                    color: ColorTheme.success,
                    icon: "checkmark.circle.fill"
                )

                ProgressStatCard(
                    title: "Remaining",
                    value: currencyManager.format(totalRemainingDebt),
                    color: ColorTheme.orange,
                    icon: "clock.fill"
                )
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

    // MARK: - Monthly Heat Map
    private var monthlyHeatMapSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                Spacer()

                Text("Last 12 Months")
                    .font(.caption)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
            }

            MonthlyHeatMap(payments: payments)
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

    // MARK: - Yearly Overview
    private var yearlyOverviewSection: some View {
        VStack(spacing: 16) {
            Text("This Year")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            YearlyContributionGraph(payments: payments)
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

    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(spacing: 16) {
            Text("Milestones")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                MilestoneRow(
                    title: "First Payment",
                    isCompleted: payments.count > 0,
                    date: payments.first?.date
                )

                MilestoneRow(
                    title: "10 Payments",
                    isCompleted: payments.count >= 10,
                    date: payments.count >= 10 ? payments.sorted(by: { $0.date < $1.date })[9].date : nil
                )

                MilestoneRow(
                    title: "First Debt Paid Off",
                    isCompleted: filteredDebts.contains(where: { $0.isCompleted }),
                    date: filteredDebts.contains(where: { $0.isCompleted }) ? Date() : nil
                )

                MilestoneRow(
                    title: "3-Month Streak",
                    isCompleted: (userProgress?.longestStreak ?? 0) >= 3,
                    date: (userProgress?.longestStreak ?? 0) >= 3 ? userProgress?.lastPaymentDate : nil
                )

                MilestoneRow(
                    title: "50% Debt Free",
                    isCompleted: overallProgress >= 0.5,
                    date: overallProgress >= 0.5 ? Date() : nil
                )

                MilestoneRow(
                    title: "100% Debt Free",
                    isCompleted: overallProgress >= 1.0,
                    date: overallProgress >= 1.0 ? Date() : nil
                )
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

    // MARK: - Before/After Comparison
    private var beforeAfterSection: some View {
        VStack(spacing: 16) {
            Text("Journey Overview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // Before
                VStack(spacing: 12) {
                    Text("Before")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(ColorTheme.orange)

                        Text(currencyManager.format(totalOriginalDebt))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                        Text("\(filteredDebts.count) debts")
                            .font(.caption)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTheme.orange.opacity(0.1))
                    .cornerRadius(15)
                }

                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                // After
                VStack(spacing: 12) {
                    Text("Now")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    VStack(spacing: 8) {
                        Image(systemName: overallProgress >= 1.0 ? "checkmark.circle.fill" : "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(overallProgress >= 1.0 ? ColorTheme.success : ColorTheme.blue)

                        Text(currencyManager.format(totalRemainingDebt))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                        Text("\(filteredDebts.filter { !$0.isCompleted }.count) debts left")
                            .font(.caption)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((overallProgress >= 1.0 ? ColorTheme.success : ColorTheme.blue).opacity(0.1))
                    .cornerRadius(15)
                }
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
}

// MARK: - Supporting Views

struct ProgressStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

struct MonthlyHeatMap: View {
    let payments: [Payment]
    @Environment(\.colorScheme) private var colorScheme

    private var monthlyData: [(month: String, count: Int, amount: Double)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"

        var data: [String: (count: Int, amount: Double)] = [:]

        // Get last 12 months
        for i in 0..<12 {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let monthKey = dateFormatter.string(from: date)
                data[monthKey] = (0, 0)
            }
        }

        // Fill with actual payment data
        for payment in payments {
            let monthKey = dateFormatter.string(from: payment.date)
            if data[monthKey] != nil {
                data[monthKey]!.count += 1
                data[monthKey]!.amount += payment.amount
            }
        }

        return data.map { (month: $0.key, count: $0.value.count, amount: $0.value.amount) }
            .sorted { first, second in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                guard let date1 = formatter.date(from: first.month),
                      let date2 = formatter.date(from: second.month) else {
                    return false
                }
                return date1 > date2
            }
            .reversed()
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(monthlyData, id: \.month) { data in
                    VStack(spacing: 4) {
                        // Heat map cell
                        RoundedRectangle(cornerRadius: 8)
                            .fill(heatMapColor(for: data.count))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("\(data.count)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )

                        Text(data.month)
                            .font(.caption2)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                    }
                }
            }
        }
    }

    private func heatMapColor(for count: Int) -> Color {
        switch count {
        case 0:
            return ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.1)
        case 1...2:
            return ColorTheme.blue.opacity(0.3)
        case 3...5:
            return ColorTheme.blue.opacity(0.6)
        default:
            return ColorTheme.blue
        }
    }
}

struct YearlyContributionGraph: View {
    let payments: [Payment]
    @Environment(\.colorScheme) private var colorScheme

    private var weeklyData: [[Int]] {
        let calendar = Calendar.current
        let today = Date()
        var data: [[Int]] = Array(repeating: Array(repeating: 0, count: 7), count: 52)

        for payment in payments {
            let components = calendar.dateComponents([.weekOfYear, .weekday, .year], from: payment.date)
            let currentComponents = calendar.dateComponents([.year], from: today)

            if components.year == currentComponents.year,
               let week = components.weekOfYear,
               let day = components.weekday,
               week >= 1, week <= 52 {
                data[week - 1][day - 1] += 1
            }
        }

        return data
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<52, id: \.self) { week in
                        VStack(spacing: 2) {
                            ForEach(0..<7, id: \.self) { day in
                                let count = weeklyData[week][day]
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(contributionColor(for: count))
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                }

                HStack {
                    Text("Less")
                        .font(.caption2)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(contributionColor(for: level))
                            .frame(width: 12, height: 12)
                    }

                    Text("More")
                        .font(.caption2)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
                .padding(.top, 8)
            }
        }
    }

    private func contributionColor(for count: Int) -> Color {
        switch count {
        case 0:
            return ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.1)
        case 1:
            return ColorTheme.success.opacity(0.3)
        case 2:
            return ColorTheme.success.opacity(0.5)
        case 3:
            return ColorTheme.success.opacity(0.7)
        default:
            return ColorTheme.success
        }
    }
}

struct MilestoneRow: View {
    let title: String
    let isCompleted: Bool
    let date: Date?
    @Environment(\.colorScheme) private var colorScheme

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isCompleted ? ColorTheme.success : ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.3))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                if let date = date {
                    Text(dateFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            isCompleted
                ? ColorTheme.success.opacity(0.1)
                : ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.05)
        )
        .cornerRadius(12)
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(for: [Debt.self, Payment.self, UserProgress.self], inMemory: true)
}
