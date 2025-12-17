//
//  DevotionalViewModel.swift
//  WePray - Daily Devotionals & Bible Reading Plans Management
//

import Foundation
import SwiftUI

// MARK: - Devotional View Model
@MainActor
class DevotionalViewModel: ObservableObject {
    @Published var devotionals: [DailyDevotional] = []
    @Published var readingPlans: [ReadingPlan] = []
    @Published var progress: DevotionalProgress = DevotionalProgress()
    @Published var selectedCategory: DevotionalCategory?
    @Published var searchText = ""

    private let devotionalsKey = "daily_devotionals"
    private let plansKey = "reading_plans"
    private let progressKey = "devotional_progress"

    init() {
        loadData()
    }

    // MARK: - Filtered Devotionals
    var filteredDevotionals: [DailyDevotional] {
        var result = devotionals.sorted { $0.date > $1.date }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.reflection.lowercased().contains(query) ||
                $0.scripture.reference.lowercased().contains(query)
            }
        }

        return result
    }

    var todaysDevotional: DailyDevotional? {
        let today = Calendar.current.startOfDay(for: Date())
        return devotionals.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var favoriteDevotionals: [DailyDevotional] {
        devotionals.filter { $0.isFavorite }
    }

    var activePlan: ReadingPlan? {
        readingPlans.first { $0.isActive }
    }

    // MARK: - Devotional Actions
    func markAsRead(_ devotional: DailyDevotional) {
        guard let index = devotionals.firstIndex(where: { $0.id == devotional.id }) else { return }
        devotionals[index].isRead = true
        progress.totalRead += 1
        updateStreak()
        saveData()
    }

    func toggleFavorite(_ devotional: DailyDevotional) {
        guard let index = devotionals.firstIndex(where: { $0.id == devotional.id }) else { return }
        devotionals[index].isFavorite.toggle()
        saveData()
    }

    func updateNotes(_ devotional: DailyDevotional, notes: String) {
        guard let index = devotionals.firstIndex(where: { $0.id == devotional.id }) else { return }
        devotionals[index].notes = notes
        if !notes.isEmpty { progress.notesWritten += 1 }
        saveData()
    }

    // MARK: - Reading Plan Actions
    func startPlan(_ plan: ReadingPlan) {
        // Deactivate current plan
        for i in readingPlans.indices { readingPlans[i].isActive = false }

        // Activate selected plan
        guard let index = readingPlans.firstIndex(where: { $0.id == plan.id }) else { return }
        readingPlans[index].isActive = true
        readingPlans[index].startDate = Date()
        readingPlans[index].currentDay = 1
        saveData()
    }

    func completeReading(_ plan: ReadingPlan, day: Int) {
        guard let planIndex = readingPlans.firstIndex(where: { $0.id == plan.id }),
              let readingIndex = readingPlans[planIndex].readings.firstIndex(where: { $0.day == day })
        else { return }

        readingPlans[planIndex].readings[readingIndex].isCompleted = true
        readingPlans[planIndex].readings[readingIndex].completedDate = Date()

        // Advance current day if needed
        if day == readingPlans[planIndex].currentDay && day < readingPlans[planIndex].duration {
            readingPlans[planIndex].currentDay += 1
        }

        updateStreak()
        saveData()
    }

    func updateReadingNotes(_ plan: ReadingPlan, day: Int, notes: String) {
        guard let planIndex = readingPlans.firstIndex(where: { $0.id == plan.id }),
              let readingIndex = readingPlans[planIndex].readings.firstIndex(where: { $0.day == day })
        else { return }

        readingPlans[planIndex].readings[readingIndex].notes = notes
        if !notes.isEmpty { progress.notesWritten += 1 }
        saveData()
    }

    func abandonPlan(_ plan: ReadingPlan) {
        guard let index = readingPlans.firstIndex(where: { $0.id == plan.id }) else { return }
        readingPlans[index].isActive = false
        saveData()
    }

    // MARK: - Streak Tracking
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = progress.lastReadDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)

            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                return // Already read today
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      Calendar.current.isDate(lastDay, inSameDayAs: yesterday) {
                progress.currentStreak += 1
            } else {
                progress.currentStreak = 1
            }
        } else {
            progress.currentStreak = 1
        }

        progress.lastReadDate = today
        if progress.currentStreak > progress.longestStreak {
            progress.longestStreak = progress.currentStreak
        }
    }

    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(devotionals) {
            UserDefaults.standard.set(encoded, forKey: devotionalsKey)
        }
        if let encoded = try? JSONEncoder().encode(readingPlans) {
            UserDefaults.standard.set(encoded, forKey: plansKey)
        }
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: devotionalsKey),
           let decoded = try? JSONDecoder().decode([DailyDevotional].self, from: data) {
            devotionals = decoded
        } else {
            devotionals = DailyDevotional.sampleDevotionals
        }

        if let data = UserDefaults.standard.data(forKey: plansKey),
           let decoded = try? JSONDecoder().decode([ReadingPlan].self, from: data) {
            readingPlans = decoded
        } else {
            readingPlans = ReadingPlan.defaultPlans
        }

        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(DevotionalProgress.self, from: data) {
            progress = decoded
        }
    }

    // MARK: - Helpers
    func getTodaysReading(for plan: ReadingPlan) -> DailyReading? {
        plan.readings.first { $0.day == plan.currentDay }
    }

    func formattedProgress(for plan: ReadingPlan) -> String {
        let completed = plan.readings.filter { $0.isCompleted }.count
        return "\(completed)/\(plan.duration) days"
    }
}
