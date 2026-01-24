import SwiftUI

struct DebtCardView: View {
    let debt: Debt
    let onTap: () -> Void
    @StateObject private var currencyManager = CurrencyManager.shared

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(debt.emoji)
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(debt.name)
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)

                        Text(debt.category)
                            .font(.caption)
                            .foregroundColor(ColorTheme.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(currencyManager.format(debt.currentAmount))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)

                        if debt.originalAmount > 0 {
                            Text("\(Int(debt.progress * 100))% paid")
                                .font(.caption)
                                .foregroundColor(ColorTheme.success)
                        }
                    }
                }

                ProgressView(value: debt.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.color(for: debt.color)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)

                if let dueDate = debt.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("Due: \(dueDate, style: .date)")
                            .font(.caption)
                    }
                    .foregroundColor(ColorTheme.textSecondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: ColorTheme.color(for: debt.color).opacity(0.3), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct DebtSummaryCard: View {
    let totalDebt: Double
    let debtsCount: Int
    let totalPaid: Double
    @StateObject private var currencyManager = CurrencyManager.shared

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Total Debt")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)

                Text(currencyManager.format(totalDebt))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.textPrimary)
            }

            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(debtsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.blue)

                    Text("Active Debts")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text(currencyManager.format(totalPaid))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.success)

                    Text("Total Paid")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [ColorTheme.pink.opacity(0.3), ColorTheme.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 2)
        )
    }
}
