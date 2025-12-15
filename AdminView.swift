//
//  AdminView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var appState: AppState
    @State private var chatAPIService: AIServiceType = .claude
    @State private var voiceAPIService: AIServiceType = .openai
    @State private var prayerTutorAPIService: AIServiceType = .claude
    @State private var showSaveConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                apiConfigurationSection
                featuredPrayersSection
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

    private var apiConfigurationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("Written Chat Prayer Tutor")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)

                Picker("Chat API", selection: $chatAPIService) {
                    ForEach(AIServiceType.allCases, id: \.self) { service in
                        Text(service.displayName).tag(service)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Voice Prayer (Audio)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)

                Picker("Voice API", selection: $voiceAPIService) {
                    ForEach(AIServiceType.allCases, id: \.self) { service in
                        Text(service.displayName).tag(service)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Prayer Tutor Responses")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)

                Picker("Tutor API", selection: $prayerTutorAPIService) {
                    ForEach(AIServiceType.allCases, id: \.self) { service in
                        Text(service.displayName).tag(service)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)
        } header: {
            Text("AI API Configuration")
        } footer: {
            Text("Select which AI service to use for each feature. Claude is recommended for written chat, OpenAI for voice prayers.")
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

    private var languageManagementSection: some View {
        Section {
            ForEach(appState.languages.sorted { $0.name < $1.name }) { language in
                HStack {
                    Text(language.flag)
                    Text(language.name)
                    Spacer()
                    if language.isCustom {
                        Text("Custom")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }

            NavigationLink(destination: AddCustomLanguageView()) {
                Label("Add Custom Language", systemImage: "plus.circle.fill")
                    .foregroundColor(AppColors.primary)
            }
        } header: {
            Text("Languages")
        } footer: {
            Text("Languages are sorted alphabetically. Custom languages are stored permanently.")
        }
    }

    private var denominationManagementSection: some View {
        Section {
            ForEach(appState.denominations.sorted { $0.name < $1.name }) { denomination in
                HStack {
                    Text(denomination.name)
                    Spacer()
                    if denomination.isCustom {
                        Text("Custom")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }

            NavigationLink(destination: AddCustomDenominationView()) {
                Label("Add Custom Denomination", systemImage: "plus.circle.fill")
                    .foregroundColor(AppColors.primary)
            }
        } header: {
            Text("Christian Denominations")
        } footer: {
            Text("Denominations are sorted alphabetically. Duplicates are automatically prevented.")
        }
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
        prayerTutorAPIService = appState.adminSettings.prayerTutorAPIService
    }

    private func saveSettings() {
        appState.adminSettings.chatAPIService = chatAPIService
        appState.adminSettings.voiceAPIService = voiceAPIService
        appState.adminSettings.prayerTutorAPIService = prayerTutorAPIService
        appState.saveAdminSettings()
        showSaveConfirmation = true
    }
}

// MARK: - Add Custom Language View
struct AddCustomLanguageView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var languageCode = ""
    @State private var languageName = ""
    @State private var nativeName = ""
    @State private var flag = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section {
                TextField("Language Code (e.g., de)", text: $languageCode)
                    .autocapitalization(.none)
                TextField("Language Name (e.g., German)", text: $languageName)
                TextField("Native Name (e.g., Deutsch)", text: $nativeName)
                TextField("Flag Emoji", text: $flag)
            } header: {
                Text("Language Details")
            }

            Section {
                Button(action: addLanguage) {
                    HStack {
                        Spacer()
                        Text("Add Language")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(AppColors.primary)
            }
        }
        .navigationTitle("Add Language")
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func addLanguage() {
        guard !languageCode.isEmpty, !languageName.isEmpty else {
            errorMessage = "Please fill in at least the code and name"
            showError = true
            return
        }

        let language = Language(
            code: languageCode.lowercased(),
            name: languageName,
            nativeName: nativeName.isEmpty ? languageName : nativeName,
            flag: flag.isEmpty ? "🌍" : flag,
            isCustom: true
        )

        appState.addCustomLanguage(language)
        dismiss()
    }
}

// MARK: - Add Custom Denomination View
struct AddCustomDenominationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var denominationName = ""
    @State private var denominationDescription = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section {
                TextField("Denomination Name", text: $denominationName)
                TextField("Description (optional)", text: $denominationDescription)
            } header: {
                Text("Denomination Details")
            }

            Section {
                Button(action: addDenomination) {
                    HStack {
                        Spacer()
                        Text("Add Denomination")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(AppColors.primary)
            }
        }
        .navigationTitle("Add Denomination")
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func addDenomination() {
        guard !denominationName.isEmpty else {
            errorMessage = "Please enter a denomination name"
            showError = true
            return
        }

        // Check for duplicates (case-insensitive)
        if appState.denominations.contains(where: { $0.name.lowercased() == denominationName.lowercased() }) {
            errorMessage = "This denomination already exists"
            showError = true
            return
        }

        let denomination = ChristianDenomination(
            name: denominationName,
            description: denominationDescription.isEmpty ? "\(denominationName) tradition" : denominationDescription,
            isCustom: true
        )

        appState.addCustomDenomination(denomination)
        dismiss()
    }
}

#Preview {
    AdminView()
        .environmentObject(AppState())
}
