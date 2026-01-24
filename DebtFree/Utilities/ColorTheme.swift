import SwiftUI

struct ColorTheme {
    static let background = Color(hex: "FFF5F7")
    static let cardBackground = Color.white

    static let pink = Color(hex: "FFB4D2")
    static let purple = Color(hex: "E7C6FF")
    static let blue = Color(hex: "B4D4FF")
    static let teal = Color(hex: "A8E6CF")
    static let green = Color(hex: "C1FFC1")
    static let yellow = Color(hex: "FFF9B0")
    static let orange = Color(hex: "FFDAB9")
    static let red = Color(hex: "FFB3BA")

    static let textPrimary = Color(hex: "2D3142")
    static let textSecondary = Color(hex: "6B7280")

    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")

    static func color(for name: String) -> Color {
        switch name.lowercased() {
        case "pink": return pink
        case "purple": return purple
        case "blue": return blue
        case "teal": return teal
        case "green": return green
        case "yellow": return yellow
        case "orange": return orange
        case "red": return red
        default: return blue
        }
    }

    static let gradient1 = LinearGradient(
        colors: [pink, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradient2 = LinearGradient(
        colors: [blue, teal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradient3 = LinearGradient(
        colors: [yellow, orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [green, teal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
