//
//  JournalEntryView.swift
//  WePray - Prayer Journal Entry Form
//

import SwiftUI

struct JournalEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @StateObject private var scriptureService = ScriptureService.shared
    @Environment(\.dismiss) private var dismiss

    var entry: JournalEntry?
    var verse: ScriptureVerse?

    @State private var reflection = ""
    @State private var prayer = ""
    @State private var gratitude = ""
    @State private var growthRating = 3
    @State private var selectedMood: JournalMood = .peaceful
    @State private var selectedTags: Set<JournalTag> = []
    @State private var selectedVerse: ScriptureVerse?
    @State private var showingVersePicker = false
    @State private var currentPrompt: ReflectionPrompt

    private var isEditing: Bool { entry != nil }

    init(viewModel: JournalViewModel, entry: JournalEntry? = nil, verse: ScriptureVerse? = nil) {
        self.viewModel = viewModel
        self.entry = entry
        self.verse = verse
        _currentPrompt = State(initialValue: ReflectionPrompt.randomPrompt())
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Scripture Section
                        scriptureSection

                        // Reflection Prompt
                        promptSection

                        // Mood Selection
                        moodSection

                        // Reflection Input
                        textSection(title: "Reflection", text: $reflection, placeholder: "What is God teaching you?")

                        // Prayer Input
                        textSection(title: "Prayer", text: $prayer, placeholder: "Write your prayer...")

                        // Gratitude Input
                        textSection(title: "Gratitude", text: $gratitude, placeholder: "What are you thankful for?")

                        // Tags Selection
                        tagsSection

                        // Growth Rating
                        ratingSection

                        // Save Button
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingVersePicker) {
                VersePickerView(selectedVerse: $selectedVerse, scriptureService: scriptureService)
            }
            .onAppear { loadEntry() }
        }
    }

    // MARK: - Scripture Section
    private var scriptureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scripture")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Button { showingVersePicker = true } label: {
                    Text(selectedVerse != nil ? "Change" : "Select Verse")
                        .font(.subheadline)
                        .foregroundColor(AppColors.accent)
                }
            }

            if let verse = selectedVerse {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\"\(verse.text)\"")
                        .font(.body)
                        .foregroundColor(AppColors.text)
                        .italic()
                    Text("- \(verse.reference)")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            } else {
                Button { showingVersePicker = true } label: {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Tap to select a verse")
                    }
                    .foregroundColor(AppColors.subtext)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.cardBackground.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, style: StrokeStyle(lineWidth: 1, dash: [5])))
                }
            }
        }
    }

    // MARK: - Prompt Section
    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reflection Prompt")
                    .font(.caption.bold())
                    .foregroundColor(AppColors.accent)
                Spacer()
                Button { currentPrompt = ReflectionPrompt.randomPrompt() } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(AppColors.accent)
                }
            }
            Text(currentPrompt.prompt)
                .font(.subheadline)
                .foregroundColor(AppColors.text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.15))
                .cornerRadius(8)
        }
    }

    // MARK: - Mood Section
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.headline)
                .foregroundColor(AppColors.text)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(JournalMood.allCases, id: \.self) { mood in
                    MoodButton(mood: mood, isSelected: selectedMood == mood) { selectedMood = mood }
                }
            }
        }
    }

    // MARK: - Text Section
    private func textSection(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextEditor(text: text)
                .frame(minHeight: 100)
                .padding(8)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    Group {
                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .foregroundColor(AppColors.subtext)
                                .padding(12)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }

    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(AppColors.text)

            FlowLayoutTags(tags: JournalTag.allCases, selectedTags: $selectedTags)
        }
    }

    // MARK: - Rating Section
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spiritual Growth Rating")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    Button { growthRating = rating } label: {
                        Image(systemName: rating <= growthRating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(rating <= growthRating ? .yellow : AppColors.border)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            saveEntry()
            dismiss()
        } label: {
            Text(isEditing ? "Update Entry" : "Save Entry")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? AppColors.primary : AppColors.border)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!canSave)
    }

    private var canSave: Bool { !reflection.isEmpty || !prayer.isEmpty || !gratitude.isEmpty }

    // MARK: - Entry Management
    private func loadEntry() {
        if let entry = entry {
            reflection = entry.reflection
            prayer = entry.prayer
            gratitude = entry.gratitude
            growthRating = entry.growthRating
            selectedMood = entry.mood
            selectedTags = Set(entry.tags)
            selectedVerse = entry.verse
        } else {
            selectedVerse = verse
        }
    }

    private func saveEntry() {
        if var existing = entry {
            existing.reflection = reflection
            existing.prayer = prayer
            existing.gratitude = gratitude
            existing.growthRating = growthRating
            existing.mood = selectedMood
            existing.tags = Array(selectedTags)
            existing.verse = selectedVerse
            viewModel.updateEntry(existing)
        } else {
            viewModel.createEntry(
                verse: selectedVerse,
                reflection: reflection,
                prayer: prayer,
                gratitude: gratitude,
                rating: growthRating,
                mood: selectedMood,
                tags: Array(selectedTags)
            )
        }
    }
}
