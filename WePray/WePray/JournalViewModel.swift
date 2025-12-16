//
//  JournalViewModel.swift
//  WePray - Prayer Journal Management
//

import Foundation
import SwiftUI
import Combine

// MARK: - Journal View Model
@MainActor
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var stats: GrowthStats = GrowthStats()
    @Published var isLoading = false
    @Published var selectedEntry: JournalEntry?
    @Published var filterMood: JournalMood?
    @Published var searchText = ""

    private let entriesKey = "journal_entries"
    private let statsKey = "journal_stats"

    init() {
        loadEntries()
        calculateStats()
    }

    // MARK: - Entry Management
    func createEntry(verse: ScriptureVerse?, reflection: String, prayer: String, gratitude: String, rating: Int, mood: JournalMood, tags: [JournalTag]) {
        let entry = JournalEntry(
            date: Date(),
            verse: verse,
            reflection: reflection,
            prayer: prayer,
            gratitude: gratitude,
            growthRating: rating,
            mood: mood,
            tags: tags
        )
        entries.insert(entry, at: 0)
        saveEntries()
        calculateStats()
    }

    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
            calculateStats()
        }
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
        calculateStats()
    }

    func getEntry(for date: Date) -> JournalEntry? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func hasEntryToday() -> Bool { getEntry(for: Date()) != nil }

    // MARK: - Filtering & Search
    var filteredEntries: [JournalEntry] {
        var result = entries
        if let mood = filterMood { result = result.filter { $0.mood == mood } }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.reflection.lowercased().contains(query) ||
                $0.prayer.lowercased().contains(query) ||
                $0.gratitude.lowercased().contains(query) ||
                $0.verse?.text.lowercased().contains(query) ?? false
            }
        }
        return result
    }

    func entriesForMonth(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
    }

    func entriesWithTag(_ tag: JournalTag) -> [JournalEntry] { entries.filter { $0.tags.contains(tag) } }

    // MARK: - Stats Calculation
    func calculateStats() {
        stats.totalEntries = entries.count
        stats.averageRating = entries.isEmpty ? 0 : Double(entries.map { $0.growthRating }.reduce(0, +)) / Double(entries.count)
        calculateStreak()
        calculateMoodDistribution()
        calculateMonthlyDistribution()
    }

    private func calculateStreak() {
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())
        while entries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: checkDate) }) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        stats.currentStreak = streak
        if streak > stats.longestStreak { stats.longestStreak = streak }
    }

    private func calculateMoodDistribution() {
        var distribution: [String: Int] = [:]
        for entry in entries { distribution[entry.mood.rawValue, default: 0] += 1 }
        stats.entriesByMood = distribution
    }

    private func calculateMonthlyDistribution() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        var distribution: [String: Int] = [:]
        for entry in entries {
            let key = formatter.string(from: entry.date)
            distribution[key, default: 0] += 1
        }
        stats.entriesByMonth = distribution
    }

    // MARK: - Growth Data for Charts
    func getWeeklyGrowthData() -> [(date: Date, rating: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var data: [(Date, Double)] = []
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let avg = dayEntries.isEmpty ? 0 : Double(dayEntries.map { $0.growthRating }.reduce(0, +)) / Double(dayEntries.count)
            data.append((date, avg))
        }
        return data.reversed()
    }

    func getMonthlyGrowthData() -> [(month: String, rating: Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let calendar = Calendar.current
        var data: [(String, Double)] = []
        for i in 0..<6 {
            guard let date = calendar.date(byAdding: .month, value: -i, to: Date()) else { continue }
            let monthEntries = entriesForMonth(date)
            let avg = monthEntries.isEmpty ? 0 : Double(monthEntries.map { $0.growthRating }.reduce(0, +)) / Double(monthEntries.count)
            data.append((formatter.string(from: date), avg))
        }
        return data.reversed()
    }

    // MARK: - Persistence
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = decoded
    }

    // MARK: - Export
    func exportEntries() -> String {
        var text = "Prayer Journal Export\n\n"
        for entry in entries {
            text += "---\n"
            text += "Date: \(entry.formattedDate)\n"
            if let verse = entry.verse { text += "Verse: \(verse.reference) - \(verse.text)\n" }
            text += "Mood: \(entry.mood.rawValue)\n"
            text += "Reflection: \(entry.reflection)\n"
            text += "Prayer: \(entry.prayer)\n"
            text += "Gratitude: \(entry.gratitude)\n"
            text += "Growth Rating: \(entry.growthRating)/5\n\n"
        }
        return text
    }
}
