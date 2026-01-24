import SwiftUI
import SwiftData

struct PaymentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var debt: Debt
    @Query private var userProgressList: [UserProgress]

    @State private var paymentAmount: String = ""
    @State private var paymentNote: String = ""
    @State private var showCelebration: Bool = false
    @State private var celebrationMessage: String = ""
    @State private var celebrationEmoji: String = "🎉"
    @State private var showAchievement: Bool = false
    @State private var newAchievement: String = ""
    @State private var isPayingFull: Bool = false

    private var userProgress: UserProgress {
        if let progress = userProgressList.first {
            return progress
        } else {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            return newProgress
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        debtInfoCard

                        paymentAmountSection

                        noteSection

                        quickAmountButtons

                        paymentButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Make Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay(
                CelebrationOverlay(
                    isPresented: $showCelebration,
                    message: celebrationMessage,
                    emoji: celebrationEmoji
                )
            )
        }
    }

    private var debtInfoCard: some View {
        VStack(spacing: 16) {
            Text(debt.emoji)
                .font(.system(size: 60))

            Text(debt.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)

            VStack(spacing: 8) {
                Text("Current Balance")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)

                Text("$\(debt.currentAmount, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.color(for: debt.color))
            }

            ProgressView(value: debt.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.color(for: debt.color)))
                .scaleEffect(x: 1, y: 3, anchor: .center)
                .padding(.horizontal)

            Text("\(Int(debt.progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(25)
    }

    private var paymentAmountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment Amount")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)

            HStack {
                Text("$")
                    .font(.title2)
                    .foregroundColor(ColorTheme.textSecondary)

                TextField("0.00", text: $paymentAmount)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)

            Toggle("Pay Full Amount", isOn: $isPayingFull)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .onChange(of: isPayingFull) { _, newValue in
                    if newValue {
                        paymentAmount = String(format: "%.2f", debt.currentAmount)
                    }
                    HapticManager.shared.light()
                }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note (Optional)")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)

            TextField("Add a note...", text: $paymentNote, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
        }
    }

    private var quickAmountButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Amounts")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickAmountButton(amount: 50, action: { paymentAmount = "50.00" })
                QuickAmountButton(amount: 100, action: { paymentAmount = "100.00" })
                QuickAmountButton(amount: 250, action: { paymentAmount = "250.00" })
            }
        }
    }

    private var paymentButton: some View {
        Button(action: processPayment) {
            Text("Make Payment")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [ColorTheme.success, ColorTheme.teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
        }
        .disabled(paymentAmount.isEmpty || Double(paymentAmount) ?? 0 <= 0)
        .opacity(paymentAmount.isEmpty || Double(paymentAmount) ?? 0 <= 0 ? 0.5 : 1.0)
    }

    private func processPayment() {
        guard let amount = Double(paymentAmount), amount > 0 else { return }

        let actualPayment = min(amount, debt.currentAmount)

        let payment = Payment(amount: actualPayment, note: paymentNote.isEmpty ? nil : paymentNote, debt: debt)
        modelContext.insert(payment)

        debt.currentAmount -= actualPayment

        userProgress.addPayment(amount: actualPayment)

        if debt.currentAmount <= 0 {
            debt.currentAmount = 0
            debt.isCompleted = true
            userProgress.completeDebt()
            celebrateDebtCompletion()
        } else {
            celebratePayment(amount: actualPayment)
        }

        checkForAchievements()

        HapticManager.shared.celebration()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }

    private func celebratePayment(amount: Double) {
        celebrationEmoji = "🎉"
        celebrationMessage = "Great job!\nYou paid $\(String(format: "%.2f", amount))"
        showCelebration = true
    }

    private func celebrateDebtCompletion() {
        celebrationEmoji = "🎊"
        celebrationMessage = "Debt Completed!\n\(debt.name) is paid off!"
        showCelebration = true
    }

    private func checkForAchievements() {
        for achievement in UserProgress.achievements {
            if !userProgress.achievementsUnlocked.contains(achievement.id) &&
               achievement.requirement(userProgress) {
                userProgress.achievementsUnlocked.append(achievement.id)
                newAchievement = achievement.title
                showAchievement = true
            }
        }
    }
}

struct QuickAmountButton: View {
    let amount: Double
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            Text("$\(Int(amount))")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
        }
    }
}
