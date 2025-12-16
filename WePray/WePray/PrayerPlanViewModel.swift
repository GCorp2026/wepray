//
//  PrayerPlanViewModel.swift
//  WePray - Prayer Tutoring App
//

import Foundation
import SwiftUI
import Combine

// MARK: - Prayer Plan Manager
class PrayerPlanViewModel: ObservableObject {
    @Published var prayerPlans: [PrayerPlan] = []
    @Published var activePlan: PrayerPlan?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var todayCompleted = false

    private let userDefaultsKey = "savedPrayerPlans"
    private let activePlanKey = "activePrayerPlan"

    init() {
        loadPlans()
        checkTodayCompletion()
    }

    // MARK: - Plan Management
    func createPlan(name: String, description: String, themes: [PrayerTheme], frequency: PrayerFrequency, durationDays: Int, prayersPerDay: Int, isShared: Bool = false) {
        let newPlan = PrayerPlan(
            name: name,
            description: description,
            themes: themes,
            frequency: frequency,
            durationDays: durationDays,
            prayersPerDay: prayersPerDay,
            startDate: Date(),
            isShared: isShared
        )
        prayerPlans.append(newPlan)
        savePlans()
    }

    func createFromTemplate(_ template: PrayerPlan) {
        var newPlan = template
        newPlan.id = UUID()
        newPlan.startDate = Date()
        newPlan.completedDays = []
        newPlan.createdAt = Date()
        prayerPlans.append(newPlan)
        savePlans()
    }

    func deletePlan(_ plan: PrayerPlan) {
        prayerPlans.removeAll { $0.id == plan.id }
        if activePlan?.id == plan.id {
            activePlan = nil
            UserDefaults.standard.removeObject(forKey: activePlanKey)
        }
        savePlans()
    }

    func setActivePlan(_ plan: PrayerPlan) {
        activePlan = plan
        if let encoded = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(encoded, forKey: activePlanKey)
        }
    }

    // MARK: - Progress Tracking
    func markTodayComplete() {
        guard var plan = activePlan else { return }
        let today = Calendar.current.startOfDay(for: Date())
        if !plan.completedDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            plan.completedDays.append(today)
            updatePlan(plan)
            todayCompleted = true
        }
    }

    func checkTodayCompletion() {
        guard let plan = activePlan else {
            todayCompleted = false
            return
        }
        let today = Calendar.current.startOfDay(for: Date())
        todayCompleted = plan.completedDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) })
    }

    func updatePlan(_ plan: PrayerPlan) {
        if let index = prayerPlans.firstIndex(where: { $0.id == plan.id }) {
            prayerPlans[index] = plan
            if activePlan?.id == plan.id {
                activePlan = plan
                if let encoded = try? JSONEncoder().encode(plan) {
                    UserDefaults.standard.set(encoded, forKey: activePlanKey)
                }
            }
            savePlans()
        }
    }

    func getStreak() -> Int {
        guard let plan = activePlan else { return 0 }
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())
        while plan.completedDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: checkDate) }) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        return streak
    }

    // MARK: - Persistence
    private func savePlans() {
        if let encoded = try? JSONEncoder().encode(prayerPlans) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadPlans() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let plans = try? JSONDecoder().decode([PrayerPlan].self, from: data) {
            prayerPlans = plans
        }
        if let data = UserDefaults.standard.data(forKey: activePlanKey),
           let plan = try? JSONDecoder().decode(PrayerPlan.self, from: data) {
            activePlan = plan
        }
    }

    // MARK: - Helpers
    func getActivePlans() -> [PrayerPlan] {
        return prayerPlans.filter { $0.isActive }
    }

    func getCompletedPlans() -> [PrayerPlan] {
        return prayerPlans.filter { $0.progress >= 1.0 }
    }

    func getPlansByTheme(_ theme: PrayerTheme) -> [PrayerPlan] {
        return prayerPlans.filter { $0.themes.contains(theme) }
    }

    func getDaysRemaining(for plan: PrayerPlan) -> Int {
        let endDate = Calendar.current.date(byAdding: .day, value: plan.durationDays, to: plan.startDate) ?? plan.startDate
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, remaining)
    }

    func formatProgress(_ plan: PrayerPlan) -> String {
        let completed = plan.completedDays.count
        let total = plan.durationDays
        return "\(completed)/\(total) days"
    }
}
