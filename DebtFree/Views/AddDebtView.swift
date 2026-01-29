import SwiftUI
import SwiftData

struct AddDebtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared

    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var category: String = "Other"
    @State private var selectedColor: String = "blue"
    @State private var selectedEmoji: String = "💰"
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var showEmojiPicker: Bool = false

    let emojis = ["💰", "💳", "🎓", "🚗", "🏠", "💵", "🏥", "📱", "🛒", "✈️", "🎮", "📚", "💻", "🎵", "🍕", "⚡", "🌟", "🎯", "🔥", "✨"]

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        emojiSection

                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "Debt Name",
                                text: $name,
                                placeholder: "e.g., Credit Card"
                            )

                            CustomTextField(
                                title: "Amount",
                                text: $amount,
                                placeholder: "0.00",
                                keyboardType: .decimalPad
                            )

                            categoryPicker

                            colorPicker

                            dueDateToggle
                        }
                        .padding(.horizontal)

                        Button(action: saveDebt) {
                            Text("Add Debt")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.gradient1)
                                .cornerRadius(20)
                        }
                        .padding(.horizontal)
                        .disabled(name.isEmpty || amount.isEmpty)
                        .opacity(name.isEmpty || amount.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("New Debt")
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

    private var emojiSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showEmojiPicker.toggle()
                HapticManager.shared.light()
            }) {
                Text(selectedEmoji)
                    .font(.system(size: 80))
                    .padding(30)
                    .background(
                        Circle()
                            .fill(ColorTheme.color(for: selectedColor).opacity(0.3))
                    )
            }

            if showEmojiPicker {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            showEmojiPicker = false
                            HapticManager.shared.selection()
                        }) {
                            Text(emoji)
                                .font(.system(size: 40))
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: showEmojiPicker)
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            Picker("Category", selection: $category) {
                ForEach(Debt.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .onChange(of: category) { _, newValue in
                if let emoji = Debt.categoryEmojis[newValue] {
                    selectedEmoji = emoji
                }
                HapticManager.shared.selection()
            }
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color Theme")
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Debt.colors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                            HapticManager.shared.light()
                        }) {
                            Circle()
                                .fill(ColorTheme.color(for: color))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .shadow(radius: 3)
                                )
                                .overlay(
                                    selectedColor == color ?
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                    : nil
                                )
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }

    private var dueDateToggle: some View {
        VStack(spacing: 12) {
            Toggle("Set Due Date", isOn: $hasDueDate)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .onChange(of: hasDueDate) { _, _ in
                    HapticManager.shared.light()
                }

            if hasDueDate {
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: hasDueDate)
    }

    private func saveDebt() {
        guard let debtAmount = Double(amount) else { return }
        guard let userId = authManager.userId else { return }

        let newDebt = Debt(
            userId: userId,
            name: name,
            amount: debtAmount,
            category: category,
            emoji: selectedEmoji,
            color: selectedColor,
            dueDate: hasDueDate ? dueDate : nil
        )

        modelContext.insert(newDebt)

        HapticManager.shared.success()
        dismiss()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
        }
    }
}
