//
//  AdminView.swift
//  WePray - Prayer Friend App
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var appState: AppState
    @State private var chatAPIService: AIServiceType = .claude
    @State private var voiceAPIService: AIServiceType = .openai
    @State private var prayerFriendAPIService: AIServiceType = .claude
    @State private var showSaveConfirmation = false
    @State private var defaultVoice: String = "nova"
    @State private var defaultPlaybackSpeed: Double = 1.0
    @State private var voiceFeaturesEnabled: Bool = true

    var body: some View {
        NavigationView {
            Form {
                userManagementSection
                apiConfigurationSection
                voiceModeSection
                featuredPrayersSection
                featuredArticlesSection
                languageManagementSection
                denominationManagementSection
                saveSection
            }
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadSettings()
            }
            .alert("Settings Saved", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your API configuration has been saved successfully.")
            }
        }
    }

    // MARK: - User Management Section
    private var userManagementSection: some View {
        Section {
            NavigationLink(destination: AdminUserManagementView()) {
                adminNavRow(icon: "person.3.fill", colors: [.blue, .purple], title: "Role Management", subtitle: "Manage users, roles & permissions")
            }
            NavigationLink(destination: UserManagementView()) {
                adminNavRow(icon: "person.badge.shield.checkmark.fill", colors: [.indigo, .blue], title: "User Accounts", subtitle: "View, suspend, verify users")
            }
            NavigationLink(destination: CommissionSettingsView()) {
                adminNavRow(icon: "percent", colors: [.green, .mint], title: "Commission Settings", subtitle: "Configure rates & payouts")
            }
            NavigationLink(destination: RevenueOverviewView()) {
                adminNavRow(icon: "chart.bar.fill", colors: [.orange, .yellow], title: "Revenue Overview", subtitle: "View financial statistics")
            }
        } header: {
            HStack { Image(systemName: "shield.fill").foregroundColor(AppColors.primary); Text("Administration") }
        }
    }

    private func adminNavRow(icon: String, colors: [Color], title: String, subtitle: String) -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                Image(systemName: icon).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.medium)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
    }

    private var apiConfigurationSection: some View {
        Section {
            apiPickerRow("Written Chat Prayer Friend", selection: $chatAPIService)
            apiPickerRow("Voice Prayer (Audio)", selection: $voiceAPIService)
            apiPickerRow("Prayer Friend Responses", selection: $prayerFriendAPIService)
        } header: {
            Text("AI API Configuration")
        } footer: {
            Text("Select which AI service to use for each feature.")
        }
    }

    private func apiPickerRow(_ title: String, selection: Binding<AIServiceType>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline).foregroundColor(AppColors.subtext)
            Picker(title, selection: selection) {
                ForEach(AIServiceType.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }.pickerStyle(.segmented)
        }.padding(.vertical, 4)
    }

    private var voiceModeSection: some View {
        Section {
            Toggle("Enable Voice Features", isOn: $voiceFeaturesEnabled)
            Picker("Default Voice", selection: $defaultVoice) {
                ForEach(UserProfile.availableVoices, id: \.0) { Text($0.1).tag($0.0) }
            }
            Picker("Playback Speed", selection: $defaultPlaybackSpeed) {
                ForEach(UserProfile.playbackSpeeds, id: \.self) { Text("\($0, specifier: "%.2g")x").tag($0) }
            }
        } header: {
            HStack { Image(systemName: "waveform").foregroundColor(AppColors.primary); Text("Advanced Voice Mode") }
        } footer: {
            Text("Configure default voice settings for all users.")
        }
    }

    private var featuredPrayersSection: some View {
        Section {
            NavigationLink(destination: FeaturedPrayersAdminView()) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                        Image(systemName: "rectangle.stack.fill")
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Featured Prayers")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(appState.adminSettings.featuredPrayers.filter { $0.isActive }.count) active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("Landing Page Carousel")
        } footer: {
            Text("Manage the featured prayers carousel on the app landing page.")
        }
    }

    private var featuredArticlesSection: some View {
        Section {
            NavigationLink(destination: FeaturedArticlesAdminView()) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [AppColors.secondary, AppColors.success], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                        Image(systemName: "newspaper.fill")
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Featured Articles")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(appState.adminSettings.featuredArticles.filter { $0.isActive }.count) active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("Articles Carousel")
        } footer: {
            Text("Manage the featured articles carousel on the home page.")
        }
    }

    private var languageManagementSection: some View {
        Section {
            ForEach(appState.languages.sorted { $0.name < $1.name }) { lang in
                HStack {
                    Text("\(lang.flag) \(lang.name)")
                    Spacer()
                    if lang.isCustom { Text("Custom").font(.caption).foregroundColor(AppColors.primary) }
                }
            }
            NavigationLink(destination: AddCustomLanguageView()) {
                Label("Add Custom Language", systemImage: "plus.circle.fill").foregroundColor(AppColors.primary)
            }
        } header: { Text("Languages") }
    }

    private var denominationManagementSection: some View {
        Section {
            ForEach(appState.denominations.sorted { $0.name < $1.name }) { denom in
                HStack {
                    Text(denom.name)
                    Spacer()
                    if denom.isCustom { Text("Custom").font(.caption).foregroundColor(AppColors.primary) }
                }
            }
            NavigationLink(destination: AddCustomDenominationView()) {
                Label("Add Custom Denomination", systemImage: "plus.circle.fill").foregroundColor(AppColors.primary)
            }
        } header: { Text("Christian Denominations") }
    }

    private var saveSection: some View {
        Section {
            Button(action: saveSettings) {
                HStack {
                    Spacer()
                    Text("Save Settings")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .listRowBackground(AppColors.primary)
        }
    }

    private func loadSettings() {
        chatAPIService = appState.adminSettings.chatAPIService
        voiceAPIService = appState.adminSettings.voiceAPIService
        prayerFriendAPIService = appState.adminSettings.prayerFriendAPIService
    }

    private func saveSettings() {
        appState.adminSettings.chatAPIService = chatAPIService
        appState.adminSettings.voiceAPIService = voiceAPIService
        appState.adminSettings.prayerFriendAPIService = prayerFriendAPIService
        appState.saveAdminSettings()
        showSaveConfirmation = true
    }
}

#Preview {
    AdminView()
        .environmentObject(AppState())
}
