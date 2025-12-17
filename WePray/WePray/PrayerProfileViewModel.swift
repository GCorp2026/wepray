//
//  PrayerProfileViewModel.swift
//  WePray - Prayer Profile ViewModel
//

import SwiftUI

class PrayerProfileViewModel: ObservableObject {
    @Published var profile: PrayerProfile?
    @Published var stats: PrayerProfileStats = PrayerProfileStats()
    @Published var isLoading = false
    @Published var isSaving = false

    private let profileKey = "WePrayPrayerProfile"
    private let statsKey = "WePrayPrayerProfileStats"
    private var currentUserId: String = ""

    init() {}

    // MARK: - Load Profile
    func loadProfile(for userId: String) {
        currentUserId = userId
        let key = "\(profileKey)_\(userId)"

        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PrayerProfile.self, from: data) {
            profile = decoded
        } else {
            profile = PrayerProfile(userId: userId)
        }

        loadStats()
    }

    // MARK: - Save Profile
    func saveProfile() {
        guard var profile = profile else { return }
        profile.updatedAt = Date()
        self.profile = profile

        let key = "\(profileKey)_\(currentUserId)"
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // MARK: - Load Stats
    private func loadStats() {
        let key = "\(statsKey)_\(currentUserId)"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PrayerProfileStats.self, from: data) {
            stats = decoded
        }
    }

    // MARK: - Save Stats
    private func saveStats() {
        let key = "\(statsKey)_\(currentUserId)"
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // MARK: - Update Bio
    func updateBio(_ bio: String) {
        profile?.bio = bio
        saveProfile()
    }

    // MARK: - Update Prayer Goal
    func updatePrayerGoal(_ goal: String) {
        profile?.prayerGoal = goal
        saveProfile()
    }

    // MARK: - Update Prayer Journey Since
    func updatePrayerJourneySince(_ date: Date?) {
        profile?.prayerJourneySince = date
        saveProfile()
    }

    // MARK: - Toggle Focus Area
    func toggleFocusArea(_ area: PrayerFocusArea) {
        guard var profile = profile else { return }
        if let index = profile.focusAreas.firstIndex(of: area) {
            profile.focusAreas.remove(at: index)
        } else {
            profile.focusAreas.append(area)
        }
        self.profile = profile
        saveProfile()
    }

    // MARK: - Toggle Preferred Time
    func togglePreferredTime(_ time: PrayerTimePreference) {
        guard var profile = profile else { return }
        if let index = profile.preferredTimes.firstIndex(of: time) {
            profile.preferredTimes.remove(at: index)
        } else {
            profile.preferredTimes.append(time)
        }
        self.profile = profile
        saveProfile()
    }

    // MARK: - Toggle Prayer Style
    func togglePrayerStyle(_ style: PrayerStyle) {
        guard var profile = profile else { return }
        if let index = profile.prayerStyles.firstIndex(of: style) {
            profile.prayerStyles.remove(at: index)
        } else {
            profile.prayerStyles.append(style)
        }
        self.profile = profile
        saveProfile()
    }

    // MARK: - Update Visibility
    func updateVisibility(_ visibility: PrayerRequestVisibility) {
        profile?.prayerRequestVisibility = visibility
        saveProfile()
    }

    // MARK: - Toggle Prayer Partner Availability
    func togglePrayerPartnerAvailability() {
        profile?.openToBeingPrayerPartner.toggle()
        saveProfile()
    }

    // MARK: - Add Scripture
    func addScripture(reference: String, text: String, note: String) {
        let scripture = FavoriteScripture(reference: reference, text: text, note: note)
        profile?.favoriteScriptures.append(scripture)
        saveProfile()
    }

    // MARK: - Remove Scripture
    func removeScripture(_ id: UUID) {
        profile?.favoriteScriptures.removeAll { $0.id == id }
        saveProfile()
    }

    // MARK: - Add Testimony
    func addTestimony(title: String, story: String, category: PrayerFocusArea, isPublic: Bool) {
        let testimony = PrayerTestimony(title: title, story: story, category: category, isPublic: isPublic)
        profile?.testimonies.append(testimony)
        stats.testimonyCount += 1
        saveProfile()
        saveStats()
    }

    // MARK: - Remove Testimony
    func removeTestimony(_ id: UUID) {
        profile?.testimonies.removeAll { $0.id == id }
        stats.testimonyCount = max(0, stats.testimonyCount - 1)
        saveProfile()
        saveStats()
    }

    // MARK: - Update Testimony Visibility
    func updateTestimonyVisibility(_ id: UUID, isPublic: Bool) {
        guard let index = profile?.testimonies.firstIndex(where: { $0.id == id }) else { return }
        profile?.testimonies[index].isPublic = isPublic
        saveProfile()
    }

    // MARK: - Increment Stats
    func incrementPrayers() {
        stats.totalPrayers += 1
        saveStats()
    }

    func incrementAnsweredPrayers() {
        stats.answeredPrayers += 1
        saveStats()
    }

    func updateStreak(_ streak: Int) {
        stats.prayerStreak = streak
        saveStats()
    }

    func updatePrayerPartners(_ count: Int) {
        stats.prayerPartners = count
        saveStats()
    }
}
