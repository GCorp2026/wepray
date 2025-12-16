//
//  PrayerRequestViewModel.swift
//  WePray - Prayer Request Management
//

import Foundation
import SwiftUI
import Combine

// MARK: - Prayer Request View Model
@MainActor
class PrayerRequestViewModel: ObservableObject {
    @Published var requests: [PrayerRequest] = []
    @Published var myRequests: [PrayerRequest] = []
    @Published var responses: [UUID: [PrayerResponse]] = [:]
    @Published var stats: PrayerWarriorStats = PrayerWarriorStats()
    @Published var isLoading = false
    @Published var selectedFilter: PrayerRequestFilter = .all
    @Published var selectedSort: PrayerRequestSort = .newest
    @Published var selectedCategory: PrayerRequestCategory?
    @Published var searchText = ""

    private let requestsKey = "prayer_requests"
    private let responsesKey = "prayer_responses"
    private let statsKey = "prayer_warrior_stats"
    private let prayedRequestsKey = "prayed_requests"
    private var prayedRequestIds: Set<UUID> = []

    init() {
        loadData()
    }

    // MARK: - Filtered & Sorted Requests
    var filteredRequests: [PrayerRequest] {
        var result = requests.filter { !$0.isExpired }

        switch selectedFilter {
        case .all: break
        case .recent:
            let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            result = result.filter { $0.createdAt > dayAgo }
        case .urgent:
            result = result.filter { $0.urgency == .high || $0.urgency == .critical }
        case .answered:
            result = result.filter { $0.isAnswered }
        case .myRequests:
            result = myRequests
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }

        switch selectedSort {
        case .newest: result.sort { $0.createdAt > $1.createdAt }
        case .oldest: result.sort { $0.createdAt < $1.createdAt }
        case .mostPrayed: result.sort { $0.prayerCount > $1.prayerCount }
        case .urgency: result.sort { urgencyOrder($0.urgency) > urgencyOrder($1.urgency) }
        }

        return result
    }

    private func urgencyOrder(_ urgency: PrayerUrgency) -> Int {
        switch urgency {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }

    // MARK: - Request Management
    func createRequest(title: String, description: String, category: PrayerRequestCategory, urgency: PrayerUrgency, isAnonymous: Bool, authorId: String, authorName: String, expiresIn: Int?) {
        var expiresAt: Date?
        if let days = expiresIn {
            expiresAt = Calendar.current.date(byAdding: .day, value: days, to: Date())
        }

        let request = PrayerRequest(
            authorId: authorId,
            authorName: authorName,
            isAnonymous: isAnonymous,
            title: title,
            description: description,
            category: category,
            urgency: urgency,
            expiresAt: expiresAt
        )

        requests.insert(request, at: 0)
        myRequests.insert(request, at: 0)
        stats.totalRequestsSubmitted += 1
        saveData()
    }

    func deleteRequest(_ request: PrayerRequest) {
        requests.removeAll { $0.id == request.id }
        myRequests.removeAll { $0.id == request.id }
        responses.removeValue(forKey: request.id)
        saveData()
    }

    func markAsAnswered(_ request: PrayerRequest, testimony: String?) {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index].isAnswered = true
            requests[index].answeredAt = Date()
            requests[index].testimonyText = testimony
            stats.answeredPrayers += 1
            saveData()
        }
    }

    // MARK: - Prayer Actions
    func prayForRequest(_ request: PrayerRequest) {
        guard !hasPrayedFor(request) else { return }

        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index].prayerCount += 1
        }

        prayedRequestIds.insert(request.id)
        stats.totalPrayersOffered += 1
        stats.categoriesPrayedFor[request.category.rawValue, default: 0] += 1
        updateStreak()
        saveData()
    }

    func hasPrayedFor(_ request: PrayerRequest) -> Bool {
        prayedRequestIds.contains(request.id)
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = stats.lastPrayerDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                return // Already prayed today
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      Calendar.current.isDate(lastDay, inSameDayAs: yesterday) {
                stats.currentStreak += 1
            } else {
                stats.currentStreak = 1
            }
        } else {
            stats.currentStreak = 1
        }
        stats.lastPrayerDate = today
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
    }

    // MARK: - Response Management
    func addResponse(to request: PrayerRequest, message: String, authorId: String, authorName: String) {
        let response = PrayerResponse(
            requestId: request.id,
            authorId: authorId,
            authorName: authorName,
            message: message
        )

        if responses[request.id] == nil {
            responses[request.id] = []
        }
        responses[request.id]?.insert(response, at: 0)

        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index].commentCount += 1
        }
        saveData()
    }

    func getResponses(for request: PrayerRequest) -> [PrayerResponse] {
        responses[request.id] ?? []
    }

    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(encoded, forKey: requestsKey)
        }
        if let encoded = try? JSONEncoder().encode(responses) {
            UserDefaults.standard.set(encoded, forKey: responsesKey)
        }
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
        if let encoded = try? JSONEncoder().encode(Array(prayedRequestIds)) {
            UserDefaults.standard.set(encoded, forKey: prayedRequestsKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: requestsKey),
           let decoded = try? JSONDecoder().decode([PrayerRequest].self, from: data) {
            requests = decoded
        }
        if let data = UserDefaults.standard.data(forKey: responsesKey),
           let decoded = try? JSONDecoder().decode([UUID: [PrayerResponse]].self, from: data) {
            responses = decoded
        }
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(PrayerWarriorStats.self, from: data) {
            stats = decoded
        }
        if let data = UserDefaults.standard.data(forKey: prayedRequestsKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            prayedRequestIds = Set(decoded)
        }
        loadSampleRequests()
    }

    private func loadSampleRequests() {
        guard requests.isEmpty else { return }
        requests = [
            PrayerRequest(authorId: "sample1", authorName: "Sarah M.", isAnonymous: false, title: "Healing for my mother", description: "Please pray for my mother who is battling cancer. She starts chemotherapy next week.", category: .health, urgency: .high, prayerCount: 45),
            PrayerRequest(authorId: "sample2", authorName: "Anonymous", isAnonymous: true, title: "Job interview tomorrow", description: "I have a big job interview tomorrow. Please pray for wisdom and peace.", category: .career, urgency: .medium, prayerCount: 23),
            PrayerRequest(authorId: "sample3", authorName: "Michael T.", isAnonymous: false, title: "Marriage restoration", description: "My wife and I are going through a difficult time. Please pray for healing.", category: .relationships, urgency: .high, prayerCount: 67),
            PrayerRequest(authorId: "sample4", authorName: "Anonymous", isAnonymous: true, title: "Struggling with anxiety", description: "I've been dealing with severe anxiety. Please pray for peace and strength.", category: .anxiety, urgency: .medium, prayerCount: 89),
            PrayerRequest(authorId: "sample5", authorName: "Grace L.", isAnonymous: false, title: "Grateful for answered prayer!", description: "God answered our prayers! My son got accepted into college!", category: .thanksgiving, urgency: .low, prayerCount: 34, isAnswered: true)
        ]
    }
}
