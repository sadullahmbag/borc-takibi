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
    // Dynamic colors that adapt to dark mode - Soft, beautiful palette inspired by Mimo
    static func dynamicBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "0D0D0D") : background
    }

    static func dynamicCardBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "1C1C1E") : .white
    }

    static func dynamicTextPrimary(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "F5F5F7") : textPrimary
    }

    static func dynamicTextSecondary(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "98989D") : textSecondary
    }

    static func dynamicShadow(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15)
    }

    // Softer accent colors for dark mode
    static func dynamicPink(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "FF9EBB") : pink
    }

    static func dynamicPurple(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "D4A5FF") : purple
    }

    static func dynamicBlue(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "A8C7FA") : blue
    }

    static func dynamicTeal(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "94D9C3") : teal
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
