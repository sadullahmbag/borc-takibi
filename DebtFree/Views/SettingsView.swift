import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var settingsList: [AppSettings]
    @StateObject private var currencyManager = CurrencyManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var showCurrencyPicker = false
    @State private var selectedCurrency: Currency
    @State private var showSignOutAlert = false
    @State private var isSigningOut = false

    private var settings: AppSettings? {
        guard let userId = authManager.userId else { return nil }
        return settingsList.first { $0.userId == userId }
    }

    init() {
        _selectedCurrency = State(initialValue: CurrencyManager.shared.selectedCurrency)
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        currencySection

                        themeSection

                        preferencesSection

                        remindersSection

                        exportSection

                        accountSection

                        aboutSection

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorTheme.gradient1)
                }
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $selectedCurrency) {
                    currencyManager.selectedCurrency = selectedCurrency
                    if let appSettings = settings {
                        appSettings.currency = selectedCurrency
                    } else if let userId = authManager.userId {
                        let newSettings = AppSettings(userId: userId)
                        newSettings.currency = selectedCurrency
                        modelContext.insert(newSettings)
                    }
                    HapticManager.shared.success()
                }
            }
            .onAppear {
                ensureSettingsExist()
                selectedCurrency = settings?.currency ?? .usd
                currencyManager.selectedCurrency = selectedCurrency
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ColorTheme.gradient1)
                    .frame(width: 80, height: 80)

                Text("⚙️")
                    .font(.system(size: 40))
            }

            Text("Customize Your Experience")
                .font(.headline)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .padding(.vertical)
    }

    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Currency")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
                .padding(.horizontal, 4)

            Button(action: {
                showCurrencyPicker = true
                HapticManager.shared.light()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Preferred Currency")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)

                        HStack(spacing: 8) {
                            Text(selectedCurrency.symbol)
                                .font(.title2)

                            Text(selectedCurrency.name)
                                .font(.headline)
                                .foregroundColor(ColorTheme.textPrimary)

                            Text("(\(selectedCurrency.code))")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
            }
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.headline)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                ForEach(AppTheme.allCases) { theme in
                    Button(action: {
                        themeManager.currentTheme = theme
                        HapticManager.shared.light()
                    }) {
                        HStack {
                            Image(systemName: themeIcon(for: theme))
                                .font(.title3)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(theme.rawValue)
                                    .font(.headline)
                                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                                Text(themeDescription(for: theme))
                                    .font(.caption)
                                    .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                            }

                            Spacer()

                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ColorTheme.success)
                                    .font(.title3)
                            }
                        }
                        .padding(16)
                        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                    }
                    .bouncyPress()
                }
            }
        }
    }

    private func themeIcon(for theme: AppTheme) -> String {
        switch theme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    private func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .light: return "Light mode always"
        case .dark: return "Dark mode always"
        case .system: return "Matches system settings"
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                SettingToggleRow(
                    icon: "🎉",
                    title: "Celebrations",
                    description: "Show confetti on payments",
                    isOn: Binding(
                        get: { settings?.showCelebrations ?? true },
                        set: { newValue in
                            if let appSettings = settings {
                                appSettings.showCelebrations = newValue
                            }
                        }
                    )
                )

                Divider()
                    .padding(.leading, 60)

                SettingToggleRow(
                    icon: "📳",
                    title: "Haptic Feedback",
                    description: "Vibration on interactions",
                    isOn: Binding(
                        get: { settings?.enableHaptics ?? true },
                        set: { newValue in
                            if let appSettings = settings {
                                appSettings.enableHaptics = newValue
                            }
                        }
                    )
                )

                Divider()
                    .padding(.leading, 60)

                SettingToggleRow(
                    icon: "🔔",
                    title: "Notifications",
                    description: "Debt reminders",
                    isOn: Binding(
                        get: { settings?.enableNotifications ?? true },
                        set: { newValue in
                            if let appSettings = settings {
                                appSettings.enableNotifications = newValue
                            }
                        }
                    )
                )
            }
            .background(Color.white)
            .cornerRadius(15)
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reminders".localized)
                .font(.headline)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                // Reminders toggle
                Toggle(isOn: $notificationManager.remindersEnabled) {
                    HStack(spacing: 16) {
                        Text("🔔")
                            .font(.title2)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Payment Reminders")
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            Text("Get daily reminders to track payments")
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        }
                    }
                }
                .tint(ColorTheme.pink)
                .padding(20)
                .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                .cornerRadius(12)
                .onChange(of: notificationManager.remindersEnabled) { _, _ in
                    HapticManager.shared.light()
                }

                // Time picker (only show if reminders are enabled)
                if notificationManager.remindersEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 16) {
                            Text("⏰")
                                .font(.title2)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reminder Time")
                                    .font(.headline)
                                    .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                                DatePicker("", selection: $notificationManager.reminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }

                            Spacer()
                        }
                        .padding(20)
                        .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(), value: notificationManager.remindersEnabled)
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Data".localized)
                .font(.headline)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                // CSV Export
                Button(action: {
                    exportToCSV()
                }) {
                    HStack(spacing: 16) {
                        Text("📊")
                            .font(.title2)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Export to CSV")
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            Text("Export your data as a spreadsheet")
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        }

                        Spacer()

                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(ColorTheme.blue)
                    }
                    .padding(20)
                    .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                    .cornerRadius(12)
                }
                .bouncyPress()

                // PDF Export
                Button(action: {
                    exportToPDF()
                }) {
                    HStack(spacing: 16) {
                        Text("📄")
                            .font(.title2)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Export to PDF")
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))

                            Text("Create a detailed PDF report")
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))
                        }

                        Spacer()

                        Image(systemName: "doc.fill")
                            .foregroundColor(ColorTheme.purple)
                    }
                    .padding(20)
                    .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                    .cornerRadius(12)
                }
                .bouncyPress()
            }
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account".localized)
                .font(.headline)
                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                // User email
                if let user = authManager.currentUser {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(ColorTheme.purple)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Signed in as".localized)
                                .font(.caption)
                                .foregroundColor(ColorTheme.dynamicTextSecondary(colorScheme: colorScheme))

                            Text(user.email)
                                .font(.headline)
                                .foregroundColor(ColorTheme.dynamicTextPrimary(colorScheme: colorScheme))
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                    .cornerRadius(12)
                }

                // Sign out button
                Button(action: {
                    showSignOutAlert = true
                    HapticManager.shared.light()
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 40)

                        Text("Sign Out".localized)
                            .font(.headline)
                            .foregroundColor(.red)

                        Spacer()

                        if isSigningOut {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        }
                    }
                    .padding(16)
                    .background(ColorTheme.dynamicCardBackground(colorScheme: colorScheme))
                    .cornerRadius(12)
                }
                .disabled(isSigningOut)
                .bouncyPress()
            }
        }
        .alert("Sign Out".localized, isPresented: $showSignOutAlert) {
            Button("Cancel".localized, role: .cancel) {}
            Button("Sign Out".localized, role: .destructive) {
                Task {
                    await signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?".localized)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                SettingInfoRow(
                    icon: "📱",
                    title: "Version",
                    value: "1.0.0"
                )

                Divider()
                    .padding(.leading, 60)

                SettingInfoRow(
                    icon: "💝",
                    title: "Made with",
                    value: "Love & SwiftUI"
                )
            }
            .background(Color.white)
            .cornerRadius(15)
        }
    }

    private func ensureSettingsExist() {
        guard let userId = authManager.userId else { return }
        if settingsList.first(where: { $0.userId == userId }) == nil {
            let newSettings = AppSettings(userId: userId)
            modelContext.insert(newSettings)
        }
    }

    private func exportToCSV() {
        // TODO: Implement CSV export
        HapticManager.shared.success()
        print("📊 CSV Export requested")
    }

    private func exportToPDF() {
        // TODO: Implement PDF export
        HapticManager.shared.success()
        print("📄 PDF Export requested")
    }

    private func signOut() async {
        isSigningOut = true

        do {
            try await authManager.signOut()
            HapticManager.shared.success()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            HapticManager.shared.error()
        }

        isSigningOut = false
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title2)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ColorTheme.pink)
                .onChange(of: isOn) { _, _ in
                    HapticManager.shared.light()
                }
        }
        .padding(20)
    }
}

struct SettingInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title2)
                .frame(width: 40)

            Text(title)
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .padding(20)
    }
}

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: Currency
    let onSelect: () -> Void

    @State private var searchText = ""

    private var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return Currency.allCurrencies
        }
        return Currency.allCurrencies.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    SearchBar(text: $searchText)
                        .padding()

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCurrencies) { currency in
                                CurrencyRow(
                                    currency: currency,
                                    isSelected: currency.id == selectedCurrency.id
                                ) {
                                    selectedCurrency = currency
                                    HapticManager.shared.light()
                                    onSelect()
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.pink)
                }
            }
        }
    }
}

struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(currency.symbol)
                    .font(.title2)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.name)
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)

                    Text(currency.code)
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorTheme.success)
                        .font(.title3)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTheme.textSecondary)

            TextField("Search currencies...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    HapticManager.shared.light()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
