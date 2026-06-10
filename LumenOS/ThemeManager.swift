import SwiftUI
import Combine

// MARK: - App Themes
enum AppTheme: String, CaseIterable, Identifiable {
    case classic = "Classic Gold"
    case cyber = "Cyber Neon"
    case midnight = "Midnight Blue"
    case lava = "Volcanic Red"
    case emerald = "Emerald Sea"

    var id: String { self.rawValue }

    var isPro: Bool {
        return self != .classic
    }

    var primary: Color {
        switch self {
        case .classic: return Color(red: 1.00, green: 0.84, blue: 0.29)
        case .cyber: return Color(red: 0.0, green: 1.0, blue: 1.0)
        case .midnight: return Color(red: 0.4, green: 0.6, blue: 1.0)
        case .lava: return Color(red: 1.0, green: 0.2, blue: 0.0)
        case .emerald: return Color(red: 0.00, green: 0.85, blue: 0.55)
        }
    }

    var secondary: Color {
        switch self {
        case .classic: return Color(red: 1.00, green: 0.58, blue: 0.00)
        case .cyber: return Color(red: 1.0, green: 0.0, blue: 1.0)
        case .midnight: return Color(red: 0.1, green: 0.2, blue: 0.5)
        case .lava: return Color(red: 1.0, green: 0.5, blue: 0.0)
        case .emerald: return Color(red: 0.00, green: 0.45, blue: 0.35)
        }
    }

    var background: Color {
        switch self {
        case .midnight: return Color(red: 0.02, green: 0.03, blue: 0.05)
        case .lava: return Color(red: 0.06, green: 0.02, blue: 0.02)
        default: return Color(red: 0.04, green: 0.05, blue: 0.08)
        }
    }

    var surface: Color {
        switch self {
        case .lava: return Color(red: 0.15, green: 0.1, blue: 0.1)
        case .cyber: return Color(red: 0.1, green: 0.12, blue: 0.2)
        default: return Color(red: 0.11, green: 0.12, blue: 0.16)
        }
    }

    // 不同皮肤的发光强度
    var glowScale: Double {
        switch self {
        case .cyber: return 1.8
        case .lava: return 1.4
        default: return 1.0
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .classic {
        willSet {
            objectWillChange.send()
        }
    }

    private init() {}
}

extension Color {
    static var l_gold: Color { ThemeManager.shared.selectedTheme.primary }
    static var l_accent: Color { ThemeManager.shared.selectedTheme.secondary }
    static var l_background: Color { ThemeManager.shared.selectedTheme.background }
    static var l_surface: Color { ThemeManager.shared.selectedTheme.surface }
}
