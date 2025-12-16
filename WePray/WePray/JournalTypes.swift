//
//  JournalTypes.swift
//  WePray - Scripture-Based Prayer Journal
//

import Foundation
import SwiftUI

// MARK: - Scripture Verse Model
struct ScriptureVerse: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let book: String
    let chapter: Int
    let verse: Int
    let text: String
    let version: String

    var reference: String { "\(book) \(chapter):\(verse)" }

    static let verseOfTheDayList: [ScriptureVerse] = [
        ScriptureVerse(book: "Psalm", chapter: 23, verse: 1, text: "The Lord is my shepherd; I shall not want.", version: "ESV"),
        ScriptureVerse(book: "John", chapter: 3, verse: 16, text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.", version: "ESV"),
        ScriptureVerse(book: "Philippians", chapter: 4, verse: 13, text: "I can do all things through him who strengthens me.", version: "ESV"),
        ScriptureVerse(book: "Romans", chapter: 8, verse: 28, text: "And we know that for those who love God all things work together for good.", version: "ESV"),
        ScriptureVerse(book: "Jeremiah", chapter: 29, verse: 11, text: "For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.", version: "ESV"),
        ScriptureVerse(book: "Isaiah", chapter: 41, verse: 10, text: "Fear not, for I am with you; be not dismayed, for I am your God; I will strengthen you.", version: "ESV"),
        ScriptureVerse(book: "Proverbs", chapter: 3, verse: 5, text: "Trust in the Lord with all your heart, and do not lean on your own understanding.", version: "ESV"),
        ScriptureVerse(book: "Matthew", chapter: 11, verse: 28, text: "Come to me, all who labor and are heavy laden, and I will give you rest.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 46, verse: 10, text: "Be still, and know that I am God. I will be exalted among the nations.", version: "ESV"),
        ScriptureVerse(book: "Romans", chapter: 12, verse: 2, text: "Do not be conformed to this world, but be transformed by the renewal of your mind.", version: "ESV"),
        ScriptureVerse(book: "Joshua", chapter: 1, verse: 9, text: "Be strong and courageous. Do not be frightened, for the Lord your God is with you wherever you go.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 119, verse: 105, text: "Your word is a lamp to my feet and a light to my path.", version: "ESV"),
        ScriptureVerse(book: "1 Peter", chapter: 5, verse: 7, text: "Casting all your anxieties on him, because he cares for you.", version: "ESV"),
        ScriptureVerse(book: "Hebrews", chapter: 11, verse: 1, text: "Now faith is the assurance of things hoped for, the conviction of things not seen.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 27, verse: 1, text: "The Lord is my light and my salvation; whom shall I fear?", version: "ESV"),
        ScriptureVerse(book: "2 Timothy", chapter: 1, verse: 7, text: "For God gave us a spirit not of fear but of power and love and self-control.", version: "ESV"),
        ScriptureVerse(book: "Galatians", chapter: 5, verse: 22, text: "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness.", version: "ESV"),
        ScriptureVerse(book: "James", chapter: 1, verse: 5, text: "If any of you lacks wisdom, let him ask God, who gives generously to all without reproach.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 34, verse: 8, text: "Oh, taste and see that the Lord is good! Blessed is the man who takes refuge in him!", version: "ESV"),
        ScriptureVerse(book: "Colossians", chapter: 3, verse: 23, text: "Whatever you do, work heartily, as for the Lord and not for men.", version: "ESV"),
        ScriptureVerse(book: "Ephesians", chapter: 2, verse: 8, text: "For by grace you have been saved through faith. And this is not your own doing; it is the gift of God.", version: "ESV"),
        ScriptureVerse(book: "1 Corinthians", chapter: 10, verse: 13, text: "No temptation has overtaken you that is not common to man. God is faithful.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 37, verse: 4, text: "Delight yourself in the Lord, and he will give you the desires of your heart.", version: "ESV"),
        ScriptureVerse(book: "Lamentations", chapter: 3, verse: 22, text: "The steadfast love of the Lord never ceases; his mercies never come to an end.", version: "ESV"),
        ScriptureVerse(book: "Matthew", chapter: 6, verse: 33, text: "But seek first the kingdom of God and his righteousness, and all these things will be added.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 91, verse: 1, text: "He who dwells in the shelter of the Most High will abide in the shadow of the Almighty.", version: "ESV"),
        ScriptureVerse(book: "Isaiah", chapter: 40, verse: 31, text: "They who wait for the Lord shall renew their strength; they shall mount up with wings like eagles.", version: "ESV"),
        ScriptureVerse(book: "Nahum", chapter: 1, verse: 7, text: "The Lord is good, a stronghold in the day of trouble; he knows those who take refuge in him.", version: "ESV"),
        ScriptureVerse(book: "1 John", chapter: 4, verse: 19, text: "We love because he first loved us.", version: "ESV"),
        ScriptureVerse(book: "Psalm", chapter: 139, verse: 14, text: "I praise you, for I am fearfully and wonderfully made. Wonderful are your works.", version: "ESV")
    ]
}

// MARK: - Journal Entry Model
struct JournalEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var verse: ScriptureVerse?
    var reflection: String
    var prayer: String
    var gratitude: String
    var growthRating: Int // 1-5
    var mood: JournalMood
    var tags: [JournalTag]

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var dayOfYear: Int { Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0 }
}

// MARK: - Journal Mood
enum JournalMood: String, CaseIterable, Codable {
    case grateful = "Grateful"
    case peaceful = "Peaceful"
    case hopeful = "Hopeful"
    case joyful = "Joyful"
    case reflective = "Reflective"
    case anxious = "Anxious"
    case struggling = "Struggling"
    case seeking = "Seeking"

    var icon: String {
        switch self {
        case .grateful: return "heart.fill"
        case .peaceful: return "leaf.fill"
        case .hopeful: return "sun.max.fill"
        case .joyful: return "face.smiling.fill"
        case .reflective: return "brain.head.profile"
        case .anxious: return "waveform.path"
        case .struggling: return "cloud.rain.fill"
        case .seeking: return "magnifyingglass"
        }
    }

    var color: Color {
        switch self {
        case .grateful: return .pink
        case .peaceful: return .green
        case .hopeful: return .orange
        case .joyful: return .yellow
        case .reflective: return .purple
        case .anxious: return .gray
        case .struggling: return .blue
        case .seeking: return .teal
        }
    }
}

// MARK: - Journal Tag
enum JournalTag: String, CaseIterable, Codable {
    case prayer = "Prayer"
    case praise = "Praise"
    case confession = "Confession"
    case thanksgiving = "Thanksgiving"
    case intercession = "Intercession"
    case worship = "Worship"
    case healing = "Healing"
    case guidance = "Guidance"
}

// MARK: - Reflection Prompt
struct ReflectionPrompt {
    let prompt: String
    let category: String

    static let prompts: [ReflectionPrompt] = [
        ReflectionPrompt(prompt: "What is God teaching you through this verse?", category: "Learning"),
        ReflectionPrompt(prompt: "How can you apply this scripture to your life today?", category: "Application"),
        ReflectionPrompt(prompt: "What prayer rises in your heart from this verse?", category: "Prayer"),
        ReflectionPrompt(prompt: "What are you grateful for today?", category: "Gratitude"),
        ReflectionPrompt(prompt: "Where do you see God working in your life?", category: "Awareness"),
        ReflectionPrompt(prompt: "What fears or anxieties can you surrender to God?", category: "Surrender"),
        ReflectionPrompt(prompt: "Who can you pray for or bless today?", category: "Intercession"),
        ReflectionPrompt(prompt: "How has God answered your prayers recently?", category: "Testimony")
    ]

    static func randomPrompt() -> ReflectionPrompt { prompts.randomElement() ?? prompts[0] }
}

// MARK: - Growth Stats
struct GrowthStats: Codable {
    var totalEntries: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageRating: Double = 0.0
    var entriesByMood: [String: Int] = [:]
    var entriesByMonth: [String: Int] = [:]
}
