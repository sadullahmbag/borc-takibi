import SwiftUI

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }

    private let themeKey = "appTheme"

    private init() {
        if let themeString = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: themeString) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }

    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }
}

// MARK: - Dark Mode Color Extensions
extension ColorTheme {
    // Dynamic colors that adapt to dark mode
    static func dynamicBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "1C1C1E") : background
    }

    static func dynamicCardBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "2C2C2E") : .white
    }

    static func dynamicTextPrimary(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "FFFFFF") : textPrimary
    }

    static func dynamicTextSecondary(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "AEAEB2") : textSecondary
    }

    static func dynamicShadow(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.2)
    }
}

// MARK: - Accessibility Support
class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()

    @Published var reduceMotion: Bool = false
    @Published var prefersCrossFadeTransitions: Bool = false

    private init() {
        updateAccessibilitySettings()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAccessibilitySettings),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func updateAccessibilitySettings() {
        reduceMotion = UIAccessibility.isReduceMotionEnabled
        prefersCrossFadeTransitions = UIAccessibility.prefersCrossFadeTransitions
    }
}
