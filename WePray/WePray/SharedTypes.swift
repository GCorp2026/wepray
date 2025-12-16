//
//  SharedTypes.swift
//  WePray - Prayer Tutoring App
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
    var preferredVoice: String = "nova"  // OpenAI TTS voice: alloy, echo, fable, onyx, nova, shimmer
    var playbackSpeed: Double = 1.0      // 0.5 to 2.0
    var realtimeVoiceEnabled: Bool = false  // Use OpenAI Realtime API for low-latency voice

    static let sample = UserProfile(
        displayName: "Guest",
        email: "guest@wepray.app",
        selectedLanguage: Language.defaultLanguages.first(where: { $0.code == "en" })!,
        selectedDenomination: ChristianDenomination.defaultDenominations.first(where: { $0.name == "Protestant" })!
    )

    static let availableVoices = [
        ("alloy", "Alloy (Neutral)"),
        ("echo", "Echo (Male)"),
        ("fable", "Fable (Expressive)"),
        ("onyx", "Onyx (Deep Male)"),
        ("nova", "Nova (Female)"),
        ("shimmer", "Shimmer (Warm Female)")
    ]

    static let playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
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
            gradientColors: ["#191970", "#4169E1"]  // Midnight to Royal Blue
        ),
        FeaturedPrayer(
            title: "Orthodox Jesus Prayer",
            prayerText: "Lord Jesus Christ, Son of God, have mercy on me, a sinner.",
            denomination: "Orthodox",
            iconName: "cross.fill",
            gradientColors: ["#2E4053", "#6495ED"]  // Navy to Cornflower
        ),
        FeaturedPrayer(
            title: "Hail Mary",
            prayerText: "Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus.",
            denomination: "Catholic",
            iconName: "star.fill",
            gradientColors: ["#000080", "#87CEEB"]  // Navy to Sky Blue
        ),
        FeaturedPrayer(
            title: "Prayer of Jabez",
            prayerText: "Oh, that you would bless me and enlarge my territory! Let your hand be with me, and keep me from harm.",
            denomination: "Protestant",
            iconName: "sun.max.fill",
            gradientColors: ["#3434A8", "#007FFF"]  // Deep Blue to Azure
        ),
        FeaturedPrayer(
            title: "Serenity Prayer",
            prayerText: "God, grant me the serenity to accept the things I cannot change, courage to change the things I can, and wisdom to know the difference.",
            denomination: "Non-denominational",
            iconName: "leaf.fill",
            gradientColors: ["#00008B", "#ADD8E6"]  // Dark Blue to Light Blue
        ),
        FeaturedPrayer(
            title: "Prayer of St. Francis",
            prayerText: "Lord, make me an instrument of your peace: where there is hatred, let me sow love; where there is injury, pardon.",
            denomination: "Catholic",
            iconName: "hands.sparkles",
            gradientColors: ["#232B52", "#4682B4"]  // Navy to Steel Blue
        ),
        FeaturedPrayer(
            title: "Gloria Patri",
            prayerText: "Glory be to the Father, and to the Son, and to the Holy Spirit; as it was in the beginning, is now, and ever shall be.",
            denomination: "Universal",
            iconName: "sparkles",
            gradientColors: ["#001F3F", "#B0E2FF"]  // Navy to Light Sky
        ),
        FeaturedPrayer(
            title: "Apostles' Creed",
            prayerText: "I believe in God, the Father almighty, creator of heaven and earth. I believe in Jesus Christ, his only Son, our Lord.",
            denomination: "Universal",
            iconName: "book.closed.fill",
            gradientColors: ["#1E2340", "#5F9EA0"]  // Deep Navy to Cadet Blue
        ),
        FeaturedPrayer(
            title: "Act of Contrition",
            prayerText: "My God, I am heartily sorry for having offended You, and I detest all my sins because of Your just punishments.",
            denomination: "Catholic",
            iconName: "heart.fill",
            gradientColors: ["#101240", "#7DF9FF"]  // Midnight to Electric Blue
        ),
        FeaturedPrayer(
            title: "Magnificat",
            prayerText: "My soul magnifies the Lord, and my spirit rejoices in God my Savior, for he has looked with favor on his humble servant.",
            denomination: "Catholic",
            iconName: "music.note",
            gradientColors: ["#000040", "#AFEEEE"]  // Navy to Pale Turquoise
        )
    ]
}

// MARK: - Featured Article Model
struct Article: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var iconName: String
    var gradientColors: [String]
    var link: String
    var isActive: Bool = true
    var order: Int

    static let defaultArticles: [Article] = [
        Article(title: "The Power of Morning Prayer", description: "Discover how starting your day with prayer can transform your mindset and productivity.", iconName: "sunrise.fill", gradientColors: ["#1E3A8A", "#3B82F6"], link: "", order: 1),
        Article(title: "Building a Prayer Habit", description: "Learn practical tips for making prayer a consistent part of your daily routine.", iconName: "calendar.badge.clock", gradientColors: ["#1A237E", "#5C6BC0"], link: "", order: 2),
        Article(title: "Prayers for Peace", description: "Find comfort and tranquility through these powerful prayers for inner peace.", iconName: "leaf.fill", gradientColors: ["#0D47A1", "#42A5F5"], link: "", order: 3),
        Article(title: "Understanding Contemplative Prayer", description: "Explore the ancient practice of contemplative prayer and its modern applications.", iconName: "brain.head.profile", gradientColors: ["#283593", "#7986CB"], link: "", order: 4),
        Article(title: "Family Prayer Traditions", description: "Create meaningful prayer traditions that bring your family closer together.", iconName: "figure.2.and.child.holdinghands", gradientColors: ["#1565C0", "#64B5F6"], link: "", order: 5),
        Article(title: "Gratitude Prayers", description: "Express thankfulness to God for all blessings. Reflect on His goodness and provision.", iconName: "sun.max.fill", gradientColors: ["#0277BD", "#4FC3F7"], link: "", order: 6),
        Article(title: "Prayers for Healing", description: "Seek God's healing touch for yourself or loved ones. Believe in His power to restore.", iconName: "heart.circle.fill", gradientColors: ["#01579B", "#29B6F6"], link: "", order: 7),
        Article(title: "Intercessory Prayer", description: "Lift up the needs of others to God. Pray for healing, comfort, and guidance.", iconName: "person.2.fill", gradientColors: ["#0288D1", "#81D4FA"], link: "", order: 8),
        Article(title: "Scripture Meditation", description: "Reflect on Bible verses and allow God's Word to speak to your heart.", iconName: "book.circle.fill", gradientColors: ["#039BE5", "#B3E5FC"], link: "", order: 9),
        Article(title: "Evening Prayers", description: "End your day with prayer, seeking God's peace and protection.", iconName: "moon.stars.fill", gradientColors: ["#0F172A", "#60A5FA"], link: "", order: 10)
    ]
}

// MARK: - Admin Settings
struct AdminSettings: Codable {
    var chatAPIService: AIServiceType = .claude
    var voiceAPIService: AIServiceType = .openai
    var prayerTutorAPIService: AIServiceType = .claude
    var featuredPrayers: [FeaturedPrayer] = FeaturedPrayer.defaultPrayers
    var featuredArticles: [Article] = Article.defaultArticles

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
