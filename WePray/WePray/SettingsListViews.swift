//
//  SettingsListViews.swift
//  WePray - Settings List Views
//

import SwiftUI

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
