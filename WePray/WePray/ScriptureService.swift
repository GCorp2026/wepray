//
//  ScriptureService.swift
//  WePray - Scripture Verse Service
//

import Foundation
import SwiftUI

// MARK: - Scripture Service
@MainActor
class ScriptureService: ObservableObject {
    static let shared = ScriptureService()

    @Published var verseOfTheDay: ScriptureVerse?
    @Published var favoriteVerses: [ScriptureVerse] = []
    @Published var recentVerses: [ScriptureVerse] = []

    private let favoritesKey = "favorite_verses"
    private let recentKey = "recent_verses"
    private let lastVerseDateKey = "last_verse_date"
    private let cachedVerseKey = "cached_verse_of_day"

    init() {
        loadFavorites()
        loadRecent()
        loadVerseOfTheDay()
    }

    // MARK: - Verse of the Day
    func loadVerseOfTheDay() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = UserDefaults.standard.object(forKey: lastVerseDateKey) as? Date,
           Calendar.current.isDate(lastDate, inSameDayAs: today),
           let data = UserDefaults.standard.data(forKey: cachedVerseKey),
           let cached = try? JSONDecoder().decode(ScriptureVerse.self, from: data) {
            verseOfTheDay = cached
            return
        }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: today) ?? 1
        let index = (dayOfYear - 1) % ScriptureVerse.verseOfTheDayList.count
        verseOfTheDay = ScriptureVerse.verseOfTheDayList[index]

        if let verse = verseOfTheDay, let encoded = try? JSONEncoder().encode(verse) {
            UserDefaults.standard.set(encoded, forKey: cachedVerseKey)
            UserDefaults.standard.set(today, forKey: lastVerseDateKey)
        }
        addToRecent(verseOfTheDay)
    }

    func getRandomVerse() -> ScriptureVerse {
        ScriptureVerse.verseOfTheDayList.randomElement() ?? ScriptureVerse.verseOfTheDayList[0]
    }

    func getVerseByBook(_ book: String) -> [ScriptureVerse] {
        ScriptureVerse.verseOfTheDayList.filter { $0.book.lowercased().contains(book.lowercased()) }
    }

    // MARK: - Favorites
    func addToFavorites(_ verse: ScriptureVerse?) {
        guard let verse = verse, !favoriteVerses.contains(verse) else { return }
        favoriteVerses.insert(verse, at: 0)
        saveFavorites()
    }

    func removeFromFavorites(_ verse: ScriptureVerse) {
        favoriteVerses.removeAll { $0.id == verse.id }
        saveFavorites()
    }

    func isFavorite(_ verse: ScriptureVerse?) -> Bool {
        guard let verse = verse else { return false }
        return favoriteVerses.contains { $0.book == verse.book && $0.chapter == verse.chapter && $0.verse == verse.verse }
    }

    func toggleFavorite(_ verse: ScriptureVerse?) {
        guard let verse = verse else { return }
        if isFavorite(verse) { removeFromFavorites(verse) }
        else { addToFavorites(verse) }
    }

    // MARK: - Recent Verses
    func addToRecent(_ verse: ScriptureVerse?) {
        guard let verse = verse else { return }
        recentVerses.removeAll { $0.id == verse.id }
        recentVerses.insert(verse, at: 0)
        if recentVerses.count > 10 { recentVerses = Array(recentVerses.prefix(10)) }
        saveRecent()
    }

    // MARK: - Persistence
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteVerses) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([ScriptureVerse].self, from: data) else { return }
        favoriteVerses = decoded
    }

    private func saveRecent() {
        if let encoded = try? JSONEncoder().encode(recentVerses) {
            UserDefaults.standard.set(encoded, forKey: recentKey)
        }
    }

    private func loadRecent() {
        guard let data = UserDefaults.standard.data(forKey: recentKey),
              let decoded = try? JSONDecoder().decode([ScriptureVerse].self, from: data) else { return }
        recentVerses = decoded
    }

    // MARK: - Search
    func searchVerses(_ query: String) -> [ScriptureVerse] {
        guard !query.isEmpty else { return ScriptureVerse.verseOfTheDayList }
        let lowercased = query.lowercased()
        return ScriptureVerse.verseOfTheDayList.filter {
            $0.text.lowercased().contains(lowercased) ||
            $0.book.lowercased().contains(lowercased) ||
            $0.reference.lowercased().contains(lowercased)
        }
    }

    // MARK: - Verse Sharing
    func shareText(for verse: ScriptureVerse) -> String {
        "\"\(verse.text)\"\n\n- \(verse.reference) (\(verse.version))\n\nShared via WePray"
    }
}
