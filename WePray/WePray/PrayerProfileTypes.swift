//
//  PrayerProfileTypes.swift
//  WePray - Prayer Profile Data Models
//

import SwiftUI

// MARK: - Prayer Focus Area
enum PrayerFocusArea: String, CaseIterable, Codable, Identifiable {
    case health = "Health & Healing"
    case family = "Family"
    case relationships = "Relationships"
    case career = "Career & Work"
    case finances = "Finances"
    case spiritual = "Spiritual Growth"
    case peace = "Peace & Anxiety"
    case guidance = "Guidance & Direction"
    case gratitude = "Gratitude"
    case forgiveness = "Forgiveness"
    case strength = "Strength & Courage"
    case wisdom = "Wisdom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .family: return "house.fill"
        case .relationships: return "person.2.fill"
        case .career: return "briefcase.fill"
        case .finances: return "dollarsign.circle.fill"
        case .spiritual: return "sparkles"
        case .peace: return "leaf.fill"
        case .guidance: return "compass.drawing"
        case .gratitude: return "hands.clap.fill"
        case .forgiveness: return "arrow.triangle.2.circlepath"
        case .strength: return "bolt.fill"
        case .wisdom: return "lightbulb.fill"
        }
    }

    var color: Color {
        switch self {
        case .health: return Color(hex: "#EF4444")
        case .family: return Color(hex: "#F59E0B")
        case .relationships: return Color(hex: "#EC4899")
        case .career: return Color(hex: "#6366F1")
        case .finances: return Color(hex: "#10B981")
        case .spiritual: return Color(hex: "#8B5CF6")
        case .peace: return Color(hex: "#14B8A6")
        case .guidance: return Color(hex: "#3B82F6")
        case .gratitude: return Color(hex: "#F97316")
        case .forgiveness: return Color(hex: "#06B6D4")
        case .strength: return Color(hex: "#EAB308")
        case .wisdom: return Color(hex: "#A855F7")
        }
    }
}

// MARK: - Prayer Time Preference
enum PrayerTimePreference: String, CaseIterable, Codable {
    case earlyMorning = "Early Morning (5-7 AM)"
    case morning = "Morning (7-9 AM)"
    case midDay = "Mid-Day (11 AM-1 PM)"
    case afternoon = "Afternoon (3-5 PM)"
    case evening = "Evening (6-8 PM)"
    case night = "Night (9-11 PM)"
    case flexible = "Flexible"

    var icon: String {
        switch self {
        case .earlyMorning: return "sunrise.fill"
        case .morning: return "sun.max.fill"
        case .midDay: return "sun.min.fill"
        case .afternoon: return "sun.haze.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        case .flexible: return "clock.fill"
        }
    }
}

// MARK: - Prayer Style
enum PrayerStyle: String, CaseIterable, Codable {
    case contemplative = "Contemplative"
    case intercessory = "Intercessory"
    case worship = "Worship-focused"
    case scripture = "Scripture-based"
    case conversational = "Conversational"
    case liturgical = "Liturgical"
    case silent = "Silent/Meditative"

    var description: String {
        switch self {
        case .contemplative: return "Quiet, reflective prayers focused on God's presence"
        case .intercessory: return "Praying for others' needs and concerns"
        case .worship: return "Praise and adoration focused prayers"
        case .scripture: return "Praying through Bible verses"
        case .conversational: return "Talking with God like a friend"
        case .liturgical: return "Traditional, structured prayers"
        case .silent: return "Wordless communion with God"
        }
    }
}

// MARK: - Prayer Request Visibility
enum PrayerRequestVisibility: String, CaseIterable, Codable {
    case `public` = "Public"
    case connectionsOnly = "Connections Only"
    case `private` = "Private"

    var icon: String {
        switch self {
        case .public: return "globe"
        case .connectionsOnly: return "person.2.fill"
        case .private: return "lock.fill"
        }
    }
}

// MARK: - Favorite Scripture
struct FavoriteScripture: Identifiable, Codable, Equatable {
    let id: UUID
    var reference: String
    var text: String
    var note: String
    var addedAt: Date

    init(id: UUID = UUID(), reference: String, text: String, note: String = "", addedAt: Date = Date()) {
        self.id = id
        self.reference = reference
        self.text = text
        self.note = note
        self.addedAt = addedAt
    }
}

// MARK: - Prayer Testimony
struct PrayerTestimony: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var story: String
    var category: PrayerFocusArea
    var isPublic: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, story: String, category: PrayerFocusArea, isPublic: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.story = story
        self.category = category
        self.isPublic = isPublic
        self.createdAt = createdAt
    }
}

// MARK: - Prayer Profile
struct PrayerProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: String
    var bio: String
    var prayerJourneySince: Date?
    var focusAreas: [PrayerFocusArea]
    var preferredTimes: [PrayerTimePreference]
    var prayerStyles: [PrayerStyle]
    var favoriteScriptures: [FavoriteScripture]
    var testimonies: [PrayerTestimony]
    var prayerRequestVisibility: PrayerRequestVisibility
    var openToBeingPrayerPartner: Bool
    var prayerGoal: String
    var updatedAt: Date

    init(id: UUID = UUID(), userId: String, bio: String = "", prayerJourneySince: Date? = nil,
         focusAreas: [PrayerFocusArea] = [], preferredTimes: [PrayerTimePreference] = [],
         prayerStyles: [PrayerStyle] = [], favoriteScriptures: [FavoriteScripture] = [],
         testimonies: [PrayerTestimony] = [], prayerRequestVisibility: PrayerRequestVisibility = .connectionsOnly,
         openToBeingPrayerPartner: Bool = true, prayerGoal: String = "", updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.bio = bio
        self.prayerJourneySince = prayerJourneySince
        self.focusAreas = focusAreas
        self.preferredTimes = preferredTimes
        self.prayerStyles = prayerStyles
        self.favoriteScriptures = favoriteScriptures
        self.testimonies = testimonies
        self.prayerRequestVisibility = prayerRequestVisibility
        self.openToBeingPrayerPartner = openToBeingPrayerPartner
        self.prayerGoal = prayerGoal
        self.updatedAt = updatedAt
    }

    var prayerJourneyYears: Int? {
        guard let since = prayerJourneySince else { return nil }
        let years = Calendar.current.dateComponents([.year], from: since, to: Date()).year
        return years
    }
}

// MARK: - Prayer Profile Stats
struct PrayerProfileStats: Codable, Equatable {
    var totalPrayers: Int
    var prayerStreak: Int
    var answeredPrayers: Int
    var prayerPartners: Int
    var testimonyCount: Int

    init(totalPrayers: Int = 0, prayerStreak: Int = 0, answeredPrayers: Int = 0, prayerPartners: Int = 0, testimonyCount: Int = 0) {
        self.totalPrayers = totalPrayers
        self.prayerStreak = prayerStreak
        self.answeredPrayers = answeredPrayers
        self.prayerPartners = prayerPartners
        self.testimonyCount = testimonyCount
    }
}

// MARK: - Sample Data
extension PrayerProfile {
    static let sample = PrayerProfile(
        userId: "user1",
        bio: "Passionate about growing closer to God through daily prayer and scripture study.",
        prayerJourneySince: Calendar.current.date(byAdding: .year, value: -5, to: Date()),
        focusAreas: [.spiritual, .family, .gratitude],
        preferredTimes: [.earlyMorning, .evening],
        prayerStyles: [.contemplative, .scripture],
        favoriteScriptures: [
            FavoriteScripture(reference: "Philippians 4:6-7", text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.", note: "My go-to verse for anxiety"),
            FavoriteScripture(reference: "Jeremiah 29:11", text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.", note: "")
        ],
        testimonies: [
            PrayerTestimony(title: "Healing Journey", story: "After months of praying for my health, God answered in an unexpected way...", category: .health, isPublic: true)
        ],
        prayerRequestVisibility: .connectionsOnly,
        openToBeingPrayerPartner: true,
        prayerGoal: "To develop a consistent daily prayer habit and grow in intercessory prayer"
    )
}
