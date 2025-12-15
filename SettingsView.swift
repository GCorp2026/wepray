//
//  SettingsView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                userProfileSection
                languageSettingsSection
                denominationSettingsSection
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

// MARK: - Language List View
struct LanguageListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.languages.sorted { $0.name < $1.name }) { language in
                HStack {
                    Text(language.flag)
                    Text(language.name)
                    Spacer()
                    if language.isCustom {
                        Text("Custom")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    }
                    if appState.currentUser?.selectedLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    appState.currentUser?.selectedLanguage = language
                    appState.saveUser()
                }
            }
        }
        .navigationTitle("Select Language")
    }
}

// MARK: - Denomination List View
struct DenominationListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.denominations.sorted { $0.name < $1.name }) { denom in
                HStack {
                    Text(denom.name)
                    Spacer()
                    if denom.isCustom {
                        Text("Custom")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    }
                    if appState.currentUser?.selectedDenomination == denom {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    appState.currentUser?.selectedDenomination = denom
                    appState.saveUser()
                }
            }
        }
        .navigationTitle("Select Denomination")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
