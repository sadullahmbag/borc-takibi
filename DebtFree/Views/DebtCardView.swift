import SwiftUI

struct DebtCardView: View {
    let debt: Debt
    let onTap: () -> Void
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(debt.emoji)
                        .font(.system(size: 40))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(debt.name)
                            .font(.headline)
                            .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                        Text(debt.category)
                            .font(.caption)
                            .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(currencyManager.format(debt.currentAmount))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

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
                    .accessibilityValue("\(Int(debt.progress * 100)) percent paid")

                if let dueDate = debt.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("Due: \(dueDate, style: .date)")
                            .font(.caption)
                    }
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                    .shadow(
                        color: ColorTheme.color(for: debt.color).opacity(colorScheme == .dark ? 0.2 : 0.3),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(debt.name), \(debt.category), \(currencyManager.format(debt.currentAmount)) remaining, \(Int(debt.progress * 100)) percent paid")
        .accessibilityHint("Double tap to make a payment")
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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Total Debt")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                Text(currencyManager.format(totalDebt))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }

            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(debtsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.blue)

                    Text("Active Debts")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }

                Divider()
                    .frame(height: 40)
                    .background(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme).opacity(0.3))

                VStack(spacing: 4) {
                    Text(currencyManager.format(totalPaid))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.success)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)

                    Text("Total Paid")
                        .font(.caption)
                        .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [ColorTheme.pink.opacity(0.2), ColorTheme.purple.opacity(0.2)]
                            : [ColorTheme.pink.opacity(0.3), ColorTheme.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    colorScheme == .dark
                        ? ColorTheme.pink.opacity(0.3)
                        : Color.white,
                    lineWidth: 2
                )
        )
        .shadow(
            color: ColorTheme.dynamicShadow(colorScheme: colorScheme),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}
