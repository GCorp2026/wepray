import SwiftUI

struct TypeVersePracticeView: View {
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var userInput = ""
    @State private var showingAnswer = false
    @State private var sessionCorrect = 0
    @State private var sessionTotal = 0
    @State private var showingResults = false
    @FocusState private var isInputFocused: Bool

    private var currentVerses: [MemoryVerse] {
        viewModel.versesForReview.isEmpty ? viewModel.verses : viewModel.versesForReview
    }

    private var currentVerse: MemoryVerse? {
        guard currentIndex < currentVerses.count else { return nil }
        return currentVerses[currentIndex]
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if showingResults {
                    resultsView
                } else if let verse = currentVerse {
                    practiceContent(verse: verse)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Type Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
            }
        }
    }

    // MARK: - Practice Content

    private func practiceContent(verse: MemoryVerse) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                progressIndicator
                referenceCard(verse: verse)
                inputSection
                if showingAnswer {
                    answerSection(verse: verse)
                }
                actionButtons
            }
            .padding()
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: 8) {
            Text("\(currentIndex + 1) of \(currentVerses.count)")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColors.border)
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(AppColors.accent)
                        .frame(width: geometry.size.width * CGFloat(currentIndex + 1) / CGFloat(currentVerses.count), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - Reference Card

    private func referenceCard(verse: MemoryVerse) -> some View {
        VStack(spacing: 12) {
            Image(systemName: verse.category.icon)
                .font(.title)
                .foregroundColor(verse.category.color)

            Text(verse.reference)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text(verse.translation)
                .font(.caption)
                .foregroundColor(AppColors.subtext)

            Text("Type the verse from memory")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Answer")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextEditor(text: $userInput)
                .frame(minHeight: 120)
                .padding(12)
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
                .scrollContentBackground(.hidden)
                .focused($isInputFocused)
                .disabled(showingAnswer)
        }
    }

    // MARK: - Answer Section

    private func answerSection(verse: MemoryVerse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect(verse: verse) ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect(verse: verse) ? .green : .red)
                Text(isCorrect(verse: verse) ? "Great job!" : "Keep practicing!")
                    .font(.headline)
                    .foregroundColor(isCorrect(verse: verse) ? .green : .red)
            }

            Text("Correct Answer:")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            Text(verse.text)
                .font(.body)
                .foregroundColor(AppColors.text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(12)

            if !isCorrect(verse: verse) {
                Text("Similarity: \(similarityPercentage(verse: verse))%")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !showingAnswer {
                Button(action: checkAnswer) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Check Answer")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userInput.isEmpty ? AppColors.border : AppColors.primary)
                    .cornerRadius(12)
                }
                .disabled(userInput.isEmpty)

                Button(action: showAnswer) {
                    Text("Show Answer")
                        .font(.subheadline)
                        .foregroundColor(AppColors.accent)
                }
            } else {
                Button(action: moveToNext) {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text(currentIndex + 1 < currentVerses.count ? "Next Verse" : "Finish")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.green)
            Text("No verses to practice!")
                .font(.title2)
                .foregroundColor(AppColors.text)
            Button("Close") { dismiss() }
                .foregroundColor(AppColors.accent)
                .padding()
        }
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(spacing: 24) {
            Image(systemName: sessionCorrect == sessionTotal ? "star.fill" : "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(sessionCorrect == sessionTotal ? .yellow : .green)

            Text("Session Complete!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text("\(sessionCorrect)/\(sessionTotal) correct")
                .font(.title2)
                .foregroundColor(AppColors.text)

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    // MARK: - Helper Methods

    private func checkAnswer() {
        guard let verse = currentVerse else { return }
        isInputFocused = false
        showingAnswer = true
        sessionTotal += 1

        let correct = isCorrect(verse: verse)
        if correct { sessionCorrect += 1 }
        viewModel.recordReview(verse, correct: correct)
    }

    private func showAnswer() {
        guard let verse = currentVerse else { return }
        isInputFocused = false
        showingAnswer = true
        sessionTotal += 1
        viewModel.recordReview(verse, correct: false)
    }

    private func moveToNext() {
        userInput = ""
        showingAnswer = false

        if currentIndex + 1 < currentVerses.count {
            currentIndex += 1
        } else {
            showingResults = true
        }
    }

    private func isCorrect(verse: MemoryVerse) -> Bool {
        similarityPercentage(verse: verse) >= 80
    }

    private func similarityPercentage(verse: MemoryVerse) -> Int {
        let normalizedInput = userInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedVerse = verse.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if normalizedInput == normalizedVerse { return 100 }

        let inputWords = Set(normalizedInput.components(separatedBy: .whitespaces))
        let verseWords = Set(normalizedVerse.components(separatedBy: .whitespaces))

        guard !verseWords.isEmpty else { return 0 }

        let matchingWords = inputWords.intersection(verseWords).count
        return Int(Double(matchingWords) / Double(verseWords.count) * 100)
    }
}

#Preview {
    TypeVersePracticeView(viewModel: ScriptureMemoryViewModel())
}
