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

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
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
