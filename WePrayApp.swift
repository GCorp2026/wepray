//
//  WePrayApp.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

@main
struct WePrayApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State Manager
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserProfile?
    @Published var languages: [Language] = []
    @Published var denominations: [ChristianDenomination] = []
    @Published var adminSettings: AdminSettings = .default

    private let userDefaultsKey = "wepray_app_data"

    init() {
        loadSavedData()
    }

    func loadSavedData() {
        // Load languages
        if let savedLanguages = UserDefaults.standard.data(forKey: "wepray_languages"),
           let decoded = try? JSONDecoder().decode([Language].self, from: savedLanguages) {
            languages = decoded
        } else {
            languages = Language.defaultLanguages
        }

        // Load denominations
        if let savedDenominations = UserDefaults.standard.data(forKey: "wepray_denominations"),
           let decoded = try? JSONDecoder().decode([ChristianDenomination].self, from: savedDenominations) {
            denominations = decoded
        } else {
            denominations = ChristianDenomination.defaultDenominations
        }

        // Load admin settings
        if let savedSettings = UserDefaults.standard.data(forKey: "wepray_admin_settings"),
           let decoded = try? JSONDecoder().decode(AdminSettings.self, from: savedSettings) {
            adminSettings = decoded
        }

        // Load user
        if let savedUser = UserDefaults.standard.data(forKey: "wepray_user"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: savedUser) {
            currentUser = decoded
            isLoggedIn = true
        }
    }

    func saveLanguages() {
        if let encoded = try? JSONEncoder().encode(languages) {
            UserDefaults.standard.set(encoded, forKey: "wepray_languages")
        }
    }

    func saveDenominations() {
        if let encoded = try? JSONEncoder().encode(denominations) {
            UserDefaults.standard.set(encoded, forKey: "wepray_denominations")
        }
    }

    func saveAdminSettings() {
        if let encoded = try? JSONEncoder().encode(adminSettings) {
            UserDefaults.standard.set(encoded, forKey: "wepray_admin_settings")
        }
    }

    func saveUser() {
        if let user = currentUser, let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "wepray_user")
        }
    }

    func addCustomLanguage(_ language: Language) {
        var newLanguage = language
        newLanguage.isCustom = true
        if !languages.contains(where: { $0.code == language.code }) {
            languages.append(newLanguage)
            languages.sort { $0.name < $1.name }
            saveLanguages()
        }
    }

    func addCustomDenomination(_ denomination: ChristianDenomination) {
        var newDenomination = denomination
        newDenomination.isCustom = true
        if !denominations.contains(where: { $0.name.lowercased() == denomination.name.lowercased() }) {
            denominations.append(newDenomination)
            denominations.sort { $0.name < $1.name }
            saveDenominations()
        }
    }

    func login(user: UserProfile) {
        currentUser = user
        isLoggedIn = true
        saveUser()
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "wepray_user")
    }
}
