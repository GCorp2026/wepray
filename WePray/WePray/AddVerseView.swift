import SwiftUI

struct AddVerseView: View {
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var reference = ""
    @State private var verseText = ""
    @State private var translation = "NIV"
    @State private var selectedCategory: VerseCategory = .faith
    @State private var selectedDifficulty: VerseDifficulty = .medium
    @State private var notes = ""
    @State private var showingPresets = false

    private let translations = ["NIV", "ESV", "KJV", "NASB", "NLT", "NKJV", "CSB", "MSG"]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        presetButton
                        referenceSection
                        verseTextSection
                        translationSection
                        categorySection
                        difficultySection
                        notesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveVerse() }
                        .foregroundColor(canSave ? AppColors.accent : AppColors.subtext)
                        .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingPresets) {
                PresetVersesView(viewModel: viewModel, onSelect: { verse in
                    reference = verse.reference
                    verseText = verse.text
                    translation = verse.translation
                    selectedCategory = verse.category
                    selectedDifficulty = verse.difficulty
                })
            }
        }
    }

    private var canSave: Bool {
        !reference.isEmpty && !verseText.isEmpty
    }

    // MARK: - Preset Button

    private var presetButton: some View {
        Button(action: { showingPresets = true }) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                Text("Choose from Popular Verses")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(AppColors.accent)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }

    // MARK: - Reference Section

    private var referenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reference")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("e.g., John 3:16", text: $reference)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }

    // MARK: - Verse Text Section

    private var verseTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verse Text")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextEditor(text: $verseText)
                .frame(minHeight: 120)
                .padding(12)
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
                .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Translation Section

    private var translationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Translation")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(translations, id: \.self) { trans in
                        Button(action: { translation = trans }) {
                            Text(trans)
                                .font(.subheadline)
                                .foregroundColor(translation == trans ? .white : AppColors.accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(translation == trans ? AppColors.accent : AppColors.accent.opacity(0.15))
                                .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(VerseCategory.allCases, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .font(.subheadline)
                            .foregroundColor(selectedCategory == category ? .white : category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? category.color : category.color.opacity(0.15))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Difficulty Section

    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Difficulty")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 12) {
                ForEach(VerseDifficulty.allCases, id: \.self) { difficulty in
                    Button(action: { selectedDifficulty = difficulty }) {
                        Text(difficulty.rawValue)
                            .font(.subheadline)
                            .foregroundColor(selectedDifficulty == difficulty ? .white : difficulty.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedDifficulty == difficulty ? difficulty.color : difficulty.color.opacity(0.15))
                            .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (Optional)")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("Add personal notes...", text: $notes)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }

    // MARK: - Save Action

    private func saveVerse() {
        let newVerse = MemoryVerse(
            reference: reference,
            text: verseText,
            translation: translation,
            category: selectedCategory,
            difficulty: selectedDifficulty,
            notes: notes
        )
        viewModel.addVerse(newVerse)
        dismiss()
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(AppColors.border.opacity(0.3))
            .cornerRadius(12)
            .foregroundColor(AppColors.text)
    }
}

// MARK: - Preset Verses View

struct PresetVersesView: View {
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    let onSelect: (MemoryVerse) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(MemoryVerse.defaultVerses) { verse in
                            Button(action: { selectVerse(verse) }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: verse.category.icon)
                                            .foregroundColor(verse.category.color)
                                        Text(verse.reference)
                                            .font(.headline)
                                            .foregroundColor(AppColors.text)
                                        Spacer()
                                        Text(verse.translation)
                                            .font(.caption)
                                            .foregroundColor(AppColors.subtext)
                                    }

                                    Text(verse.text)
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.subtext)
                                        .lineLimit(2)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Popular Verses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
            }
        }
    }

    private func selectVerse(_ verse: MemoryVerse) {
        onSelect(verse)
        dismiss()
    }
}

#Preview {
    AddVerseView(viewModel: ScriptureMemoryViewModel())
}
