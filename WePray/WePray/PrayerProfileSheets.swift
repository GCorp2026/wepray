//
//  PrayerProfileSheets.swift
//  WePray - Prayer Profile Input Sheets
//

import SwiftUI

// MARK: - Add Scripture Sheet
struct AddScriptureSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PrayerProfileViewModel
    @State private var reference = ""
    @State private var text = ""
    @State private var note = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Scripture Reference") {
                    TextField("e.g., John 3:16", text: $reference)
                }
                Section("Scripture Text") {
                    TextEditor(text: $text)
                        .frame(height: 100)
                }
                Section("Personal Note (Optional)") {
                    TextField("Why this verse is meaningful to you", text: $note)
                }
            }
            .navigationTitle("Add Scripture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addScripture(reference: reference, text: text, note: note)
                        dismiss()
                    }
                    .disabled(reference.isEmpty || text.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Testimony Sheet
struct AddTestimonySheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PrayerProfileViewModel
    @State private var title = ""
    @State private var story = ""
    @State private var category: PrayerFocusArea = .spiritual
    @State private var isPublic = true

    var body: some View {
        NavigationView {
            Form {
                Section("Testimony Title") {
                    TextField("e.g., Healing Journey", text: $title)
                }
                Section("Your Story") {
                    TextEditor(text: $story)
                        .frame(height: 150)
                }
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(PrayerFocusArea.allCases) { area in
                            Label(area.rawValue, systemImage: area.icon).tag(area)
                        }
                    }
                }
                Section("Visibility") {
                    Toggle("Share Publicly", isOn: $isPublic)
                }
            }
            .navigationTitle("Add Testimony")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addTestimony(title: title, story: story, category: category, isPublic: isPublic)
                        dismiss()
                    }
                    .disabled(title.isEmpty || story.isEmpty)
                }
            }
        }
    }
}
