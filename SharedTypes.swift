//
//  SharedTypes.swift
//  WePray - Prayer Tutoring App
//

import Foundation
import SwiftUI

// MARK: - App Colors
struct AppColors {
    static let primary = Color(hex: "#6B4EFF")
    static let primaryLight = Color(hex: "#8B73FF")
    static let primaryDark = Color(hex: "#4A35B3")
    static let secondary = Color(hex: "#00C9A7")
    static let accent = Color(hex: "#FFB800")
    static let background = Color(hex: "#F8F9FA")
    static let cardBackground = Color(hex: "#FFFFFF")
    static let text = Color(hex: "#2D3436")
    static let subtext = Color(hex: "#636E72")
    static let border = Color(hex: "#DFE6E9")
    static let success = Color(hex: "#00B894")
    static let error = Color(hex: "#D63031")
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
}

// MARK: - Language Model (Alphabetized)
struct Language: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    let code: String
    let name: String
    let nativeName: String
    let flag: String
    var isCustom: Bool = false

    static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.code == rhs.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    // Default languages (alphabetized by name)
    static let defaultLanguages: [Language] = [
        Language(code: "pt-BR", name: "Brazilian Portuguese", nativeName: "Portugues Brasileiro", flag: "🇧🇷"),
        Language(code: "zh", name: "Chinese", nativeName: "中文", flag: "🇨🇳"),
        Language(code: "en", name: "English", nativeName: "English", flag: "🇺🇸"),
        Language(code: "fr", name: "French", nativeName: "Francais", flag: "🇫🇷"),
        Language(code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        Language(code: "es", name: "Spanish", nativeName: "Espanol", flag: "🇪🇸")
    ]
}

// MARK: - Christian Denomination Model
struct ChristianDenomination: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    let name: String
    let description: String
    var isCustom: Bool = false

    static func == (lhs: ChristianDenomination, rhs: ChristianDenomination) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }

    // Default denominations (alphabetized)
    static let defaultDenominations: [ChristianDenomination] = [
        ChristianDenomination(name: "Anglican", description: "Anglican/Episcopal tradition"),
        ChristianDenomination(name: "Baptist", description: "Baptist tradition"),
        ChristianDenomination(name: "Catholic", description: "Roman Catholic tradition"),
        ChristianDenomination(name: "Lutheran", description: "Lutheran tradition"),
        ChristianDenomination(name: "Methodist", description: "Methodist/Wesleyan tradition"),
        ChristianDenomination(name: "Non-denominational", description: "Non-denominational Protestant"),
        ChristianDenomination(name: "Orthodox", description: "Eastern Orthodox tradition"),
        ChristianDenomination(name: "Pentecostal", description: "Pentecostal/Charismatic tradition"),
        ChristianDenomination(name: "Presbyterian", description: "Presbyterian/Reformed tradition"),
        ChristianDenomination(name: "Protestant", description: "General Protestant tradition")
    ]
}

// MARK: - AI Service Type
enum AIServiceType: String, CaseIterable, Codable {
    case openai = "openai"
    case claude = "claude"
    case deepseek = "deepseek"

    var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .claude: return "Claude (Anthropic)"
        case .deepseek: return "DeepSeek"
        }
    }
}

// MARK: - User Profile
struct UserProfile: Identifiable, Codable {
    var id: UUID = UUID()
    var displayName: String
    var email: String
    var selectedLanguage: Language
    var selectedDenomination: ChristianDenomination
    var isAdmin: Bool = false

    static let sample = UserProfile(
        displayName: "Guest",
        email: "guest@wepray.app",
        selectedLanguage: Language.defaultLanguages.first(where: { $0.code == "en" })!,
        selectedDenomination: ChristianDenomination.defaultDenominations.first(where: { $0.name == "Protestant" })!
    )
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    var audioURL: URL?

    init(content: String, isFromUser: Bool, timestamp: Date = Date(), audioURL: URL? = nil) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.audioURL = audioURL
    }
}

// MARK: - Featured Prayer Model
struct FeaturedPrayer: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var prayerText: String
    var denomination: String
    var iconName: String
    var gradientColors: [String]
    var isActive: Bool = true

    static let defaultPrayers: [FeaturedPrayer] = [
        FeaturedPrayer(
            title: "The Lord's Prayer",
            prayerText: "Our Father, who art in heaven, hallowed be thy name. Thy kingdom come, thy will be done, on earth as it is in heaven.",
            denomination: "Universal",
            iconName: "hands.sparkles.fill",
            gradientColors: ["#6B4EFF", "#8B73FF"]
        ),
        FeaturedPrayer(
            title: "Orthodox Jesus Prayer",
            prayerText: "Lord Jesus Christ, Son of God, have mercy on me, a sinner.",
            denomination: "Orthodox",
            iconName: "cross.fill",
            gradientColors: ["#D4AF37", "#FFD700"]
        ),
        FeaturedPrayer(
            title: "Hail Mary",
            prayerText: "Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus.",
            denomination: "Catholic",
            iconName: "star.fill",
            gradientColors: ["#4169E1", "#1E90FF"]
        ),
        FeaturedPrayer(
            title: "Prayer of Jabez",
            prayerText: "Oh, that you would bless me and enlarge my territory! Let your hand be with me, and keep me from harm.",
            denomination: "Protestant",
            iconName: "sun.max.fill",
            gradientColors: ["#00C9A7", "#00B894"]
        ),
        FeaturedPrayer(
            title: "Serenity Prayer",
            prayerText: "God, grant me the serenity to accept the things I cannot change, courage to change the things I can, and wisdom to know the difference.",
            denomination: "Non-denominational",
            iconName: "leaf.fill",
            gradientColors: ["#9B59B6", "#8E44AD"]
        )
    ]
}

// MARK: - Admin Settings
struct AdminSettings: Codable {
    var chatAPIService: AIServiceType = .claude
    var voiceAPIService: AIServiceType = .openai
    var prayerTutorAPIService: AIServiceType = .claude
    var featuredPrayers: [FeaturedPrayer] = FeaturedPrayer.defaultPrayers

    static let `default` = AdminSettings()
}

// MARK: - App Configuration
struct AppConfig {
    static let openAIAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    static let claudeAPIKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] ?? ""
    static let deepseekAPIKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] ?? ""
    static let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
    static let supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
}
