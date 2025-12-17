//
//  ScriptureMemoryTypes.swift
//  WePray - Scripture Memory & Verse Cards
//

import Foundation
import SwiftUI

// MARK: - Memory Verse Model
struct MemoryVerse: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let reference: String
    let text: String
    let translation: String
    var category: VerseCategory
    var difficulty: VerseDifficulty
    var dateAdded: Date = Date()
    var lastReviewed: Date?
    var nextReview: Date?
    var reviewCount: Int = 0
    var correctCount: Int = 0
    var masteryLevel: MasteryLevel = .new
    var isFavorite: Bool = false
    var notes: String = ""

    var accuracy: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount)
    }

    var formattedAccuracy: String {
        "\(Int(accuracy * 100))%"
    }
}

// MARK: - Verse Category
enum VerseCategory: String, CaseIterable, Codable {
    case faith = "Faith"
    case hope = "Hope"
    case love = "Love"
    case peace = "Peace"
    case strength = "Strength"
    case wisdom = "Wisdom"
    case comfort = "Comfort"
    case salvation = "Salvation"
    case praise = "Praise"
    case guidance = "Guidance"

    var icon: String {
        switch self {
        case .faith: return "hands.sparkles"
        case .hope: return "sun.max.fill"
        case .love: return "heart.fill"
        case .peace: return "leaf.fill"
        case .strength: return "bolt.fill"
        case .wisdom: return "lightbulb.fill"
        case .comfort: return "hand.raised.fill"
        case .salvation: return "cross.fill"
        case .praise: return "music.note"
        case .guidance: return "signpost.right.fill"
        }
    }

    var color: Color {
        switch self {
        case .faith: return .purple
        case .hope: return .orange
        case .love: return .pink
        case .peace: return .green
        case .strength: return .blue
        case .wisdom: return .yellow
        case .comfort: return .teal
        case .salvation: return .red
        case .praise: return .indigo
        case .guidance: return .cyan
        }
    }
}

// MARK: - Verse Difficulty
enum VerseDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var wordLimit: Int {
        switch self {
        case .easy: return 20
        case .medium: return 40
        case .hard: return 100
        }
    }
}

// MARK: - Mastery Level (Spaced Repetition)
enum MasteryLevel: Int, CaseIterable, Codable {
    case new = 0
    case learning = 1
    case familiar = 2
    case confident = 3
    case mastered = 4

    var title: String {
        switch self {
        case .new: return "New"
        case .learning: return "Learning"
        case .familiar: return "Familiar"
        case .confident: return "Confident"
        case .mastered: return "Mastered"
        }
    }

    var color: Color {
        switch self {
        case .new: return .gray
        case .learning: return .red
        case .familiar: return .orange
        case .confident: return .blue
        case .mastered: return .green
        }
    }

    var icon: String {
        switch self {
        case .new: return "star"
        case .learning: return "star.leadinghalf.filled"
        case .familiar: return "star.fill"
        case .confident: return "star.circle"
        case .mastered: return "star.circle.fill"
        }
    }

    // Days until next review (spaced repetition)
    var reviewInterval: Int {
        switch self {
        case .new: return 0
        case .learning: return 1
        case .familiar: return 3
        case .confident: return 7
        case .mastered: return 14
        }
    }
}

// MARK: - Review Session
struct ReviewSession: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let versesReviewed: Int
    let correctAnswers: Int
    let duration: TimeInterval

    var accuracy: Double {
        guard versesReviewed > 0 else { return 0 }
        return Double(correctAnswers) / Double(versesReviewed)
    }
}

// MARK: - Memory Progress
struct MemoryProgress: Codable {
    var totalVerses: Int = 0
    var versesMemorized: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastReviewDate: Date?
    var totalReviews: Int = 0
    var totalCorrect: Int = 0
    var minutesPracticed: Int = 0
    var sessions: [ReviewSession] = []

    var overallAccuracy: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalReviews)
    }

    var streakStatus: String {
        if currentStreak == 0 { return "Start practicing!" }
        if currentStreak == 1 { return "1 day streak" }
        return "\(currentStreak) day streak"
    }
}

// MARK: - Practice Mode
enum PracticeMode: String, CaseIterable {
    case flashcard = "Flashcard"
    case fillBlank = "Fill in Blank"
    case typeVerse = "Type Verse"
    case reference = "Reference Quiz"

    var icon: String {
        switch self {
        case .flashcard: return "rectangle.on.rectangle"
        case .fillBlank: return "text.badge.minus"
        case .typeVerse: return "keyboard"
        case .reference: return "book.fill"
        }
    }

    var description: String {
        switch self {
        case .flashcard: return "Flip cards to reveal verse"
        case .fillBlank: return "Fill in missing words"
        case .typeVerse: return "Type the complete verse"
        case .reference: return "Match verse to reference"
        }
    }
}

// MARK: - Default Verses
extension MemoryVerse {
    static let defaultVerses: [MemoryVerse] = [
        MemoryVerse(
            reference: "John 3:16",
            text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
            translation: "NIV",
            category: .love,
            difficulty: .medium
        ),
        MemoryVerse(
            reference: "Jeremiah 29:11",
            text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.",
            translation: "NIV",
            category: .hope,
            difficulty: .medium
        ),
        MemoryVerse(
            reference: "Philippians 4:13",
            text: "I can do all this through him who gives me strength.",
            translation: "NIV",
            category: .strength,
            difficulty: .easy
        ),
        MemoryVerse(
            reference: "Psalm 23:1",
            text: "The Lord is my shepherd, I lack nothing.",
            translation: "NIV",
            category: .peace,
            difficulty: .easy
        ),
        MemoryVerse(
            reference: "Romans 8:28",
            text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
            translation: "NIV",
            category: .faith,
            difficulty: .medium
        ),
        MemoryVerse(
            reference: "Proverbs 3:5-6",
            text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
            translation: "NIV",
            category: .wisdom,
            difficulty: .medium
        ),
        MemoryVerse(
            reference: "Isaiah 41:10",
            text: "So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand.",
            translation: "NIV",
            category: .comfort,
            difficulty: .hard
        ),
        MemoryVerse(
            reference: "Psalm 46:1",
            text: "God is our refuge and strength, an ever-present help in trouble.",
            translation: "NIV",
            category: .strength,
            difficulty: .easy
        )
    ]
}
