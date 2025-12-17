//
//  AppTheme.swift
//  WePray - App Colors and Theme
//

import Foundation
import SwiftUI

// MARK: - App Colors (Cinematic Navy Blue Theme)
struct AppColors {
    static let primary = Color(hex: "#1E3A8A")        // Navy Blue
    static let primaryLight = Color(hex: "#3B82F6")   // Royal Blue
    static let primaryDark = Color(hex: "#1A237E")    // Deep Navy
    static let secondary = Color(hex: "#2563EB")      // Bright Blue
    static let accent = Color(hex: "#60A5FA")         // Sky Blue
    static let background = Color(hex: "#0F172A")     // Dark Navy
    static let cardBackground = Color(hex: "#1E293B") // Card Navy
    static let text = Color(hex: "#F1F5F9")           // Light text for dark bg
    static let subtext = Color(hex: "#94A3B8")        // Muted blue-gray
    static let border = Color(hex: "#334155")         // Navy border
    static let success = Color(hex: "#3B82F6")        // Blue success
    static let error = Color(hex: "#EF4444")          // Keep red for errors
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
