//
//  AppTheme.swift
//  WePray - App Colors and Theme
//

import Foundation
import SwiftUI

// MARK: - Theme Mode
enum ThemeMode: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: ThemeMode {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "WePrayThemeMode")
        }
    }

    static let shared = ThemeManager()

    init() {
        if let saved = UserDefaults.standard.string(forKey: "WePrayThemeMode"),
           let theme = ThemeMode(rawValue: saved) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .dark // Default to dark mode
        }
    }
}

// MARK: - App Colors (Dynamic Light/Dark Theme)
struct AppColors {
    // MARK: - Dark Mode Colors (Cinematic Navy Blue)
    private static let darkPrimary = Color(hex: "#1E3A8A")
    private static let darkPrimaryLight = Color(hex: "#3B82F6")
    private static let darkPrimaryDark = Color(hex: "#1A237E")
    private static let darkSecondary = Color(hex: "#2563EB")
    private static let darkAccent = Color(hex: "#60A5FA")
    private static let darkBackground = Color(hex: "#0F172A")
    private static let darkCardBackground = Color(hex: "#1E293B")
    private static let darkText = Color(hex: "#F1F5F9")
    private static let darkSubtext = Color(hex: "#94A3B8")
    private static let darkBorder = Color(hex: "#334155")

    // MARK: - Light Mode Colors (Clean Blue Theme)
    private static let lightPrimary = Color(hex: "#1E40AF")
    private static let lightPrimaryLight = Color(hex: "#3B82F6")
    private static let lightPrimaryDark = Color(hex: "#1E3A8A")
    private static let lightSecondary = Color(hex: "#2563EB")
    private static let lightAccent = Color(hex: "#3B82F6")
    private static let lightBackground = Color(hex: "#F8FAFC")
    private static let lightCardBackground = Color(hex: "#FFFFFF")
    private static let lightText = Color(hex: "#0F172A")
    private static let lightSubtext = Color(hex: "#64748B")
    private static let lightBorder = Color(hex: "#E2E8F0")

    // MARK: - Dynamic Colors (based on current theme)
    static var primary: Color { isDarkMode ? darkPrimary : lightPrimary }
    static var primaryLight: Color { isDarkMode ? darkPrimaryLight : lightPrimaryLight }
    static var primaryDark: Color { isDarkMode ? darkPrimaryDark : lightPrimaryDark }
    static var secondary: Color { isDarkMode ? darkSecondary : lightSecondary }
    static var accent: Color { isDarkMode ? darkAccent : lightAccent }
    static var background: Color { isDarkMode ? darkBackground : lightBackground }
    static var cardBackground: Color { isDarkMode ? darkCardBackground : lightCardBackground }
    static var text: Color { isDarkMode ? darkText : lightText }
    static var subtext: Color { isDarkMode ? darkSubtext : lightSubtext }
    static var border: Color { isDarkMode ? darkBorder : lightBorder }
    static var success: Color { Color(hex: "#10B981") }
    static var error: Color { Color(hex: "#EF4444") }

    // MARK: - Theme Detection
    private static var isDarkMode: Bool {
        let theme = ThemeManager.shared.currentTheme
        switch theme {
        case .dark: return true
        case .light: return false
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
}

// MARK: - Color Hex Extension
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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
