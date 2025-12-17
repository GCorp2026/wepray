//
//  DevotionalTypes.swift
//  WePray - Daily Devotionals & Bible Reading Plans
//

import Foundation
import SwiftUI

// MARK: - Daily Devotional Model
struct DailyDevotional: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let title: String
    let date: Date
    let scripture: ScriptureReference
    let reflection: String
    let prayer: String
    let application: String
    let author: String
    let category: DevotionalCategory
    var isRead: Bool = false
    var isFavorite: Bool = false
    var notes: String = ""

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Scripture Reference
struct ScriptureReference: Codable, Equatable {
    let book: String
    let chapter: Int
    let verseStart: Int
    let verseEnd: Int?
    let text: String

    var reference: String {
        if let end = verseEnd, end != verseStart {
            return "\(book) \(chapter):\(verseStart)-\(end)"
        }
        return "\(book) \(chapter):\(verseStart)"
    }
}

// MARK: - Devotional Category
enum DevotionalCategory: String, CaseIterable, Codable {
    case faith = "Faith"
    case hope = "Hope"
    case love = "Love"
    case peace = "Peace"
    case wisdom = "Wisdom"
    case strength = "Strength"
    case gratitude = "Gratitude"
    case forgiveness = "Forgiveness"
    case purpose = "Purpose"
    case prayer = "Prayer"

    var icon: String {
        switch self {
        case .faith: return "hands.sparkles"
        case .hope: return "sun.max.fill"
        case .love: return "heart.fill"
        case .peace: return "leaf.fill"
        case .wisdom: return "lightbulb.fill"
        case .strength: return "bolt.fill"
        case .gratitude: return "gift.fill"
        case .forgiveness: return "hand.raised.fill"
        case .purpose: return "target"
        case .prayer: return "figure.mind.and.body"
        }
    }

    var color: Color {
        switch self {
        case .faith: return .purple
        case .hope: return .orange
        case .love: return .pink
        case .peace: return .green
        case .wisdom: return .yellow
        case .strength: return .blue
        case .gratitude: return .teal
        case .forgiveness: return .indigo
        case .purpose: return .red
        case .prayer: return .cyan
        }
    }
}

// MARK: - Bible Reading Plan
struct ReadingPlan: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let duration: Int // days
    let category: PlanCategory
    var readings: [DailyReading]
    var startDate: Date?
    var currentDay: Int = 0
    var isActive: Bool = false

    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        let completed = readings.filter { $0.isCompleted }.count
        return Double(completed) / Double(duration)
    }

    var daysRemaining: Int {
        max(0, duration - currentDay)
    }
}

// MARK: - Daily Reading
struct DailyReading: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let day: Int
    let title: String
    let passages: [ScriptureReference]
    var isCompleted: Bool = false
    var completedDate: Date?
    var notes: String = ""
}

// MARK: - Plan Category
enum PlanCategory: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case gospels = "Gospels"
    case psalms = "Psalms & Proverbs"
    case newTestament = "New Testament"
    case oldTestament = "Old Testament"
    case wholeBible = "Whole Bible"
    case topical = "Topical"
    case seasonal = "Seasonal"

    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .gospels: return "book.fill"
        case .psalms: return "music.note"
        case .newTestament: return "cross.fill"
        case .oldTestament: return "scroll.fill"
        case .wholeBible: return "books.vertical.fill"
        case .topical: return "list.bullet"
        case .seasonal: return "calendar"
        }
    }

    var color: Color {
        switch self {
        case .beginner: return .green
        case .gospels: return .blue
        case .psalms: return .purple
        case .newTestament: return .orange
        case .oldTestament: return .brown
        case .wholeBible: return .red
        case .topical: return .teal
        case .seasonal: return .pink
        }
    }
}

// MARK: - Devotional Progress
struct DevotionalProgress: Codable {
    var totalRead: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastReadDate: Date?
    var favoriteCategory: String?
    var minutesSpent: Int = 0
    var notesWritten: Int = 0

    var streakStatus: String {
        if currentStreak == 0 { return "Start reading!" }
        if currentStreak == 1 { return "1 day streak" }
        return "\(currentStreak) day streak"
    }
}

// MARK: - Default Devotionals
extension DailyDevotional {
    static let sampleDevotionals: [DailyDevotional] = [
        DailyDevotional(
            title: "Walking in Faith",
            date: Date(),
            scripture: ScriptureReference(
                book: "Hebrews",
                chapter: 11,
                verseStart: 1,
                verseEnd: nil,
                text: "Now faith is confidence in what we hope for and assurance about what we do not see."
            ),
            reflection: "Faith is the foundation of our relationship with God. It's not about seeing everything clearly, but trusting in God's promises even when the path ahead seems uncertain. Today, consider the areas of your life where you're being called to trust God more deeply.",
            prayer: "Lord, increase my faith. Help me to trust You even when I cannot see the way forward. Strengthen my confidence in Your promises and Your perfect plan for my life. Amen.",
            application: "Identify one area where you're struggling to trust God. Write it down and commit to praying about it daily this week.",
            author: "WePray Team",
            category: .faith
        ),
        DailyDevotional(
            title: "The Gift of Peace",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            scripture: ScriptureReference(
                book: "John",
                chapter: 14,
                verseStart: 27,
                verseEnd: nil,
                text: "Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid."
            ),
            reflection: "Jesus offers us a peace that transcends circumstances. While the world's peace depends on everything going well, Christ's peace remains steady even in storms. This supernatural peace is available to every believer.",
            prayer: "Prince of Peace, fill my heart with Your supernatural peace today. When anxiety rises, remind me of Your presence. Help me to rest in Your love. Amen.",
            application: "When you feel anxious today, pause and take three deep breaths while repeating: 'Jesus gives me peace.'",
            author: "WePray Team",
            category: .peace
        ),
        DailyDevotional(
            title: "Strength in Weakness",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            scripture: ScriptureReference(
                book: "2 Corinthians",
                chapter: 12,
                verseStart: 9,
                verseEnd: 10,
                text: "But he said to me, 'My grace is sufficient for you, for my power is made perfect in weakness.' Therefore I will boast all the more gladly about my weaknesses, so that Christ's power may rest on me."
            ),
            reflection: "Our weaknesses are not obstacles to God's work—they're opportunities for His power to shine. When we acknowledge our limitations, we make room for God's unlimited strength to flow through us.",
            prayer: "Father, I surrender my weaknesses to You. Use them to display Your power and glory. Help me embrace my limitations as opportunities for Your grace. Amen.",
            application: "Instead of hiding your struggles today, share one weakness with a trusted friend and ask for prayer.",
            author: "WePray Team",
            category: .strength
        )
    ]
}

// MARK: - Default Reading Plans
extension ReadingPlan {
    static let defaultPlans: [ReadingPlan] = [
        ReadingPlan(
            title: "7 Days of Psalms",
            description: "A week-long journey through selected Psalms for comfort and praise.",
            duration: 7,
            category: .psalms,
            readings: (1...7).map { day in
                DailyReading(
                    day: day,
                    title: "Day \(day): Psalm \(day * 3)",
                    passages: [ScriptureReference(book: "Psalm", chapter: day * 3, verseStart: 1, verseEnd: nil, text: "")]
                )
            }
        ),
        ReadingPlan(
            title: "Gospel of John",
            description: "Read through the Gospel of John in 21 days.",
            duration: 21,
            category: .gospels,
            readings: (1...21).map { day in
                DailyReading(
                    day: day,
                    title: "Day \(day): John \(day)",
                    passages: [ScriptureReference(book: "John", chapter: day, verseStart: 1, verseEnd: nil, text: "")]
                )
            }
        ),
        ReadingPlan(
            title: "30 Days of Proverbs",
            description: "One chapter of Proverbs each day for a month of wisdom.",
            duration: 30,
            category: .psalms,
            readings: (1...30).map { day in
                DailyReading(
                    day: day,
                    title: "Day \(day): Proverbs \(day)",
                    passages: [ScriptureReference(book: "Proverbs", chapter: day, verseStart: 1, verseEnd: nil, text: "")]
                )
            }
        )
    ]
}
