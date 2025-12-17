//
//  PrayerRequestTypes.swift
//  WePray - Prayer Request Community Models
//

import Foundation
import SwiftUI

// MARK: - Prayer Request Model
struct PrayerRequest: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var authorId: String
    var authorName: String
    var authorRole: UserRole = .user
    var isAnonymous: Bool
    var title: String
    var description: String
    var category: PrayerRequestCategory
    var urgency: PrayerUrgency
    var prayerCount: Int = 0
    var commentCount: Int = 0
    var createdAt: Date = Date()
    var expiresAt: Date?
    var isAnswered: Bool = false
    var answeredAt: Date?
    var testimonyText: String?

    var displayName: String { isAnonymous ? "Anonymous" : authorName }
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    var isExpired: Bool {
        guard let expires = expiresAt else { return false }
        return Date() > expires
    }
}

// MARK: - Prayer Request Category
enum PrayerRequestCategory: String, CaseIterable, Codable {
    case health = "Health & Healing"
    case family = "Family"
    case relationships = "Relationships"
    case financial = "Financial"
    case career = "Career & Work"
    case spiritual = "Spiritual Growth"
    case grief = "Grief & Loss"
    case anxiety = "Anxiety & Peace"
    case guidance = "Guidance & Decisions"
    case thanksgiving = "Thanksgiving"
    case other = "Other"

    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .family: return "house.fill"
        case .relationships: return "person.2.fill"
        case .financial: return "dollarsign.circle.fill"
        case .career: return "briefcase.fill"
        case .spiritual: return "sparkles"
        case .grief: return "cloud.rain.fill"
        case .anxiety: return "leaf.fill"
        case .guidance: return "signpost.right.fill"
        case .thanksgiving: return "hands.clap.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .health: return .red
        case .family: return .orange
        case .relationships: return .pink
        case .financial: return .green
        case .career: return .blue
        case .spiritual: return .purple
        case .grief: return .gray
        case .anxiety: return .teal
        case .guidance: return .indigo
        case .thanksgiving: return .yellow
        case .other: return .secondary
        }
    }
}

// MARK: - Prayer Urgency
enum PrayerUrgency: String, CaseIterable, Codable {
    case low = "Ongoing"
    case medium = "Important"
    case high = "Urgent"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }

    var icon: String {
        switch self {
        case .low: return "clock"
        case .medium: return "exclamationmark.circle"
        case .high: return "exclamationmark.triangle"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - Prayer Response Model
struct PrayerResponse: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var requestId: UUID
    var authorId: String
    var authorName: String
    var authorRole: UserRole = .user
    var message: String
    var createdAt: Date = Date()

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Prayer Warrior Stats
struct PrayerWarriorStats: Codable {
    var totalPrayersOffered: Int = 0
    var totalRequestsSubmitted: Int = 0
    var answeredPrayers: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var categoriesPrayedFor: [String: Int] = [:]
    var lastPrayerDate: Date?

    var prayerWarriorLevel: PrayerWarriorLevel {
        switch totalPrayersOffered {
        case 0..<10: return .beginner
        case 10..<50: return .faithful
        case 50..<100: return .devoted
        case 100..<500: return .warrior
        default: return .intercessor
        }
    }
}

// MARK: - Prayer Warrior Level
enum PrayerWarriorLevel: String, Codable {
    case beginner = "Prayer Beginner"
    case faithful = "Faithful Prayer"
    case devoted = "Devoted Intercessor"
    case warrior = "Prayer Warrior"
    case intercessor = "Master Intercessor"

    var icon: String {
        switch self {
        case .beginner: return "hands.sparkles"
        case .faithful: return "flame"
        case .devoted: return "heart.circle"
        case .warrior: return "shield.fill"
        case .intercessor: return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .beginner: return .gray
        case .faithful: return .blue
        case .devoted: return .purple
        case .warrior: return .orange
        case .intercessor: return .yellow
        }
    }

    var minPrayers: Int {
        switch self {
        case .beginner: return 0
        case .faithful: return 10
        case .devoted: return 50
        case .warrior: return 100
        case .intercessor: return 500
        }
    }
}

// MARK: - Filter Options
enum PrayerRequestFilter: String, CaseIterable {
    case all = "All"
    case recent = "Recent"
    case urgent = "Urgent"
    case answered = "Answered"
    case myRequests = "My Requests"
}

// MARK: - Sort Options
enum PrayerRequestSort: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case mostPrayed = "Most Prayed"
    case urgency = "Urgency"
}
