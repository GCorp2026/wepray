//
//  SettingsView.swift
//  WePray - Prayer Friend App
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var notificationService = NotificationService.shared
    @State private var showLogoutConfirmation = false
    @State private var showAddReminder = false
    @State private var prayerFriendName: String = ""

    var body: some View {
        NavigationView {
            Form {
                userProfileSection
                prayerFriendSection
                languageSettingsSection
                denominationSettingsSection
                voiceSettingsSection
                notificationsSection
                customContentSection
                aboutSection
                logoutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }

    private var userProfileSection: some View {
        Section {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.currentUser?.displayName ?? "User")
                        .font(.headline)
                    Text(appState.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Profile")
        }
    }

    private var prayerFriendSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Prayer Friend Name")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                TextField("Enter name for your prayer friend", text: $prayerFriendName)
                    .textFieldStyle(.roundedBorder)
                    .onAppear {
                        prayerFriendName = appState.currentUser?.prayerFriendName ?? "Prayer Friend"
                    }
                    .onChange(of: prayerFriendName) { _, newValue in
                        appState.currentUser?.prayerFriendName = newValue
                        appState.saveUser()
                    }
                Text("This is the name your AI prayer companion will use")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Prayer Friend")
        } footer: {
            Text("Personalize your prayer experience by giving your prayer friend a name.")
        }
    }

    private var languageSettingsSection: some View {
        Section {
            Menu {
                ForEach(appState.languages.sorted { $0.name < $1.name }) { language in
                    Button(action: {
                        appState.currentUser?.selectedLanguage = language
                        appState.saveUser()
                    }) {
                        HStack {
                            Text(language.flag)
                            Text(language.name)
                            if appState.currentUser?.selectedLanguage == language {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Label("App Language", systemImage: "globe")
                    Spacer()
                    if let lang = appState.currentUser?.selectedLanguage {
                        Text("\(lang.flag) \(lang.name)")
                            .foregroundColor(AppColors.subtext)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }
            .foregroundColor(AppColors.text)
        } header: {
            Text("Language")
        } footer: {
            Text("AI responses will be in your selected language")
        }
    }

    private var denominationSettingsSection: some View {
        Section {
            Menu {
                ForEach(appState.denominations.sorted { $0.name < $1.name }) { denom in
                    Button(action: {
                        appState.currentUser?.selectedDenomination = denom
                        appState.saveUser()
                    }) {
                        HStack {
                            Text(denom.name)
                            if appState.currentUser?.selectedDenomination == denom {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Label("Denomination", systemImage: "cross.fill")
                    Spacer()
                    if let denom = appState.currentUser?.selectedDenomination {
                        Text(denom.name)
                            .foregroundColor(AppColors.subtext)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }
            .foregroundColor(AppColors.text)
        } header: {
            Text("Christian Denomination")
        } footer: {
            Text("Prayers will follow your selected tradition")
        }
    }

    private var voiceSettingsSection: some View {
        Section {
            // Realtime Voice Mode Toggle
            Toggle(isOn: Binding(
                get: { appState.currentUser?.realtimeVoiceEnabled ?? false },
                set: { newValue in
                    appState.currentUser?.realtimeVoiceEnabled = newValue
                    appState.saveUser()
                }
            )) {
                Label("Real-time Voice", systemImage: "bolt.fill")
            }
            .tint(AppColors.primary)

            // Voice Selection
            Menu {
                ForEach(UserProfile.availableVoices, id: \.0) { voice in
                    Button(action: {
                        appState.currentUser?.preferredVoice = voice.0
                        appState.saveUser()
                    }) {
                        HStack {
                            Text(voice.1)
                            if appState.currentUser?.preferredVoice == voice.0 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Label("Voice", systemImage: "waveform")
                    Spacer()
                    Text(UserProfile.availableVoices.first { $0.0 == appState.currentUser?.preferredVoice }?.1 ?? "Nova")
                        .foregroundColor(AppColors.subtext)
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(AppColors.subtext)
                }
            }
            .foregroundColor(AppColors.text)

            // Playback Speed
            Menu {
                ForEach(UserProfile.playbackSpeeds, id: \.self) { speed in
                    Button(action: {
                        appState.currentUser?.playbackSpeed = speed
                        appState.saveUser()
                    }) {
                        HStack {
                            Text("\(speed, specifier: "%.2g")x")
                            if appState.currentUser?.playbackSpeed == speed {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Label("Playback Speed", systemImage: "speedometer")
                    Spacer()
                    Text("\(appState.currentUser?.playbackSpeed ?? 1.0, specifier: "%.2g")x")
                        .foregroundColor(AppColors.subtext)
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(AppColors.subtext)
                }
            }
            .foregroundColor(AppColors.text)
        } header: {
            Text("Voice Settings")
        } footer: {
            Text("Real-time mode uses OpenAI Realtime API for ~300ms latency")
        }
    }

    private var notificationsSection: some View {
        Section {
            notificationToggle($notificationService.settings.dailyPrayerEnabled, "Daily Prayer", "sun.max.fill")
            if notificationService.settings.dailyPrayerEnabled {
                DatePicker("Time", selection: $notificationService.settings.dailyPrayerTime, displayedComponents: .hourAndMinute)
                    .onChange(of: notificationService.settings.dailyPrayerTime) { _, _ in notificationService.saveSettings() }
            }
            notificationToggle($notificationService.settings.groupNotificationsEnabled, "Groups", "person.3.fill")
            notificationToggle($notificationService.settings.socialNotificationsEnabled, "Social", "heart.fill")
            notificationToggle($notificationService.settings.soundEnabled, "Sound", "speaker.wave.2.fill")
        } header: { Text("Notifications") }
    }

    private func notificationToggle(_ binding: Binding<Bool>, _ label: String, _ icon: String) -> some View {
        Toggle(isOn: binding) { Label(label, systemImage: icon) }
            .tint(AppColors.primary)
            .onChange(of: binding.wrappedValue) { _, _ in notificationService.saveSettings() }
    }

    private var customContentSection: some View {
        Section {
            NavigationLink(destination: AddCustomLanguageView()) {
                Label("Add Custom Language", systemImage: "plus.circle")
            }

            NavigationLink(destination: AddCustomDenominationView()) {
                Label("Add Custom Denomination", systemImage: "plus.circle")
            }
        } header: {
            Text("Customize")
        } footer: {
            Text("Add your own languages and denominations")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(AppColors.subtext)
            }

            Link(destination: URL(string: "https://wepray.app/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: URL(string: "https://wepray.app/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        } header: {
            Text("About")
        }
    }

    private var logoutSection: some View {
        Section {
            Button(action: { showLogoutConfirmation = true }) {
                HStack {
                    Spacer()
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(AppColors.error)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
