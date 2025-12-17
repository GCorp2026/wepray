//
//  ScriptureMemoryViewModel.swift
//  WePray - Scripture Memory Management
//

import Foundation
import SwiftUI

// MARK: - Scripture Memory View Model
@MainActor
class ScriptureMemoryViewModel: ObservableObject {
    @Published var verses: [MemoryVerse] = []
    @Published var progress: MemoryProgress = MemoryProgress()
    @Published var selectedCategory: VerseCategory?
    @Published var searchText = ""
    @Published var currentPracticeMode: PracticeMode = .flashcard

    private let versesKey = "memory_verses"
    private let progressKey = "memory_progress"

    init() {
        loadData()
    }

    // MARK: - Filtered Verses
    var filteredVerses: [MemoryVerse] {
        var result = verses

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.reference.lowercased().contains(query) ||
                $0.text.lowercased().contains(query)
            }
        }

        return result.sorted { $0.dateAdded > $1.dateAdded }
    }

    var versesForReview: [MemoryVerse] {
        let today = Date()
        return verses.filter { verse in
            guard let nextReview = verse.nextReview else { return true }
            return nextReview <= today
        }.sorted { ($0.nextReview ?? .distantPast) < ($1.nextReview ?? .distantPast) }
    }

    var masteredVerses: [MemoryVerse] {
        verses.filter { $0.masteryLevel == .mastered }
    }

    var newVerses: [MemoryVerse] {
        verses.filter { $0.masteryLevel == .new }
    }

    var favoriteVerses: [MemoryVerse] {
        verses.filter { $0.isFavorite }
    }

    // MARK: - Verse Actions
    func addVerse(_ verse: MemoryVerse) {
        var newVerse = verse
        newVerse.nextReview = Date()
        verses.append(newVerse)
        progress.totalVerses += 1
        saveData()
    }

    func removeVerse(_ verse: MemoryVerse) {
        verses.removeAll { $0.id == verse.id }
        progress.totalVerses = max(0, progress.totalVerses - 1)
        saveData()
    }

    func toggleFavorite(_ verse: MemoryVerse) {
        guard let index = verses.firstIndex(where: { $0.id == verse.id }) else { return }
        verses[index].isFavorite.toggle()
        saveData()
    }

    func updateNotes(_ verse: MemoryVerse, notes: String) {
        guard let index = verses.firstIndex(where: { $0.id == verse.id }) else { return }
        verses[index].notes = notes
        saveData()
    }

    // MARK: - Review Actions
    func recordReview(_ verse: MemoryVerse, correct: Bool) {
        guard let index = verses.firstIndex(where: { $0.id == verse.id }) else { return }

        verses[index].reviewCount += 1
        verses[index].lastReviewed = Date()
        progress.totalReviews += 1

        if correct {
            verses[index].correctCount += 1
            progress.totalCorrect += 1

            // Advance mastery level
            if verses[index].masteryLevel.rawValue < MasteryLevel.mastered.rawValue {
                let newLevel = MasteryLevel(rawValue: verses[index].masteryLevel.rawValue + 1) ?? .mastered
                verses[index].masteryLevel = newLevel

                if newLevel == .mastered {
                    progress.versesMemorized += 1
                }
            }
        } else {
            // Decrease mastery level on incorrect answer
            if verses[index].masteryLevel.rawValue > MasteryLevel.learning.rawValue {
                verses[index].masteryLevel = MasteryLevel(rawValue: verses[index].masteryLevel.rawValue - 1) ?? .learning
            }
        }

        // Calculate next review date using spaced repetition
        let interval = verses[index].masteryLevel.reviewInterval
        verses[index].nextReview = Calendar.current.date(byAdding: .day, value: interval, to: Date())

        updateStreak()
        saveData()
    }

    func completeSession(versesReviewed: Int, correctAnswers: Int, duration: TimeInterval) {
        let session = ReviewSession(
            date: Date(),
            versesReviewed: versesReviewed,
            correctAnswers: correctAnswers,
            duration: duration
        )
        progress.sessions.append(session)
        progress.minutesPracticed += Int(duration / 60)
        saveData()
    }

    // MARK: - Streak Tracking
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = progress.lastReviewDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)

            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                return // Already reviewed today
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      Calendar.current.isDate(lastDay, inSameDayAs: yesterday) {
                progress.currentStreak += 1
            } else {
                progress.currentStreak = 1
            }
        } else {
            progress.currentStreak = 1
        }

        progress.lastReviewDate = today
        if progress.currentStreak > progress.longestStreak {
            progress.longestStreak = progress.currentStreak
        }
    }

    // MARK: - Stats
    func versesByMastery(_ level: MasteryLevel) -> [MemoryVerse] {
        verses.filter { $0.masteryLevel == level }
    }

    var masteryDistribution: [MasteryLevel: Int] {
        var distribution: [MasteryLevel: Int] = [:]
        for level in MasteryLevel.allCases {
            distribution[level] = versesByMastery(level).count
        }
        return distribution
    }

    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(verses) {
            UserDefaults.standard.set(encoded, forKey: versesKey)
        }
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: versesKey),
           let decoded = try? JSONDecoder().decode([MemoryVerse].self, from: data) {
            verses = decoded
        } else {
            verses = MemoryVerse.defaultVerses
        }

        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(MemoryProgress.self, from: data) {
            progress = decoded
        }

        progress.totalVerses = verses.count
        progress.versesMemorized = masteredVerses.count
    }
}
