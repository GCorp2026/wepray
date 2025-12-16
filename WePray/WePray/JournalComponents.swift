//
//  JournalComponents.swift
//  WePray - Prayer Journal UI Components
//

import SwiftUI

// MARK: - Mood Button
struct MoodButton: View {
    let mood: JournalMood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mood.icon)
                    .font(.title3)
                Text(mood.rawValue)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : mood.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? mood.color : mood.color.opacity(0.15))
            .cornerRadius(10)
        }
    }
}

// MARK: - Flow Layout Tags
struct FlowLayoutTags: View {
    let tags: [JournalTag]
    @Binding var selectedTags: Set<JournalTag>

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagChip(tag: tag, isSelected: selectedTags.contains(tag)) {
                    if selectedTags.contains(tag) { selectedTags.remove(tag) }
                    else { selectedTags.insert(tag) }
                }
            }
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: JournalTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag.rawValue)
                .font(.caption)
                .foregroundColor(isSelected ? .white : AppColors.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.accent : AppColors.cardBackground)
                .cornerRadius(16)
        }
    }
}

// MARK: - Verse Picker View
struct VersePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVerse: ScriptureVerse?
    @ObservedObject var scriptureService: ScriptureService
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                List {
                    if !scriptureService.favoriteVerses.isEmpty {
                        Section("Favorites") {
                            ForEach(scriptureService.favoriteVerses) { verse in
                                VerseRow(verse: verse) { selectedVerse = verse; dismiss() }
                            }
                        }
                    }

                    Section("All Verses") {
                        ForEach(scriptureService.searchVerses(searchText)) { verse in
                            VerseRow(verse: verse) { selectedVerse = verse; dismiss() }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search verses...")
            }
            .navigationTitle("Select Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Verse Row
struct VerseRow: View {
    let verse: ScriptureVerse
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verse.reference)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.accent)
                Text(verse.text)
                    .font(.caption)
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
        }
    }
}
