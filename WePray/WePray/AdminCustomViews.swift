//
//  AdminCustomViews.swift
//  WePray - Admin Custom Language & Denomination Views
//

import SwiftUI

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
