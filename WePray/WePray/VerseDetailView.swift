import SwiftUI

struct VerseDetailView: View {
    let verse: MemoryVerse
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        verseTextSection
                        statsSection
                        notesSection
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Verse Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
            }
            .onAppear {
                notes = verse.notes
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: verse.category.icon)
                    .foregroundColor(verse.category.color)
                Text(verse.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(verse.category.color)
            }

            Text(verse.reference)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text(verse.translation)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
        }
    }

    // MARK: - Verse Text Section

    private var verseTextSection: some View {
        Text(verse.text)
            .font(.title3)
            .foregroundColor(AppColors.text)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 16) {
                VerseStatItem(title: "Reviews", value: "\(verse.reviewCount)", icon: "arrow.clockwise")
                VerseStatItem(title: "Accuracy", value: verse.formattedAccuracy, icon: "percent")
                VerseStatItem(title: "Mastery", value: verse.masteryLevel.title, icon: verse.masteryLevel.icon)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(8)
                .foregroundColor(AppColors.text)
                .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        HStack(spacing: 12) {
            Button(action: deleteVerse) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.15))
                .cornerRadius(12)
            }

            Button(action: saveNotes) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Notes")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Actions

    private func deleteVerse() {
        viewModel.removeVerse(verse)
        dismiss()
    }

    private func saveNotes() {
        viewModel.updateNotes(verse, notes: notes)
        dismiss()
    }
}

#Preview {
    VerseDetailView(
        verse: MemoryVerse.defaultVerses[0],
        viewModel: ScriptureMemoryViewModel()
    )
}
