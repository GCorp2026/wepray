import SwiftUI

struct FillBlanksPracticeView: View {
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var userAnswers: [String] = []
    @State private var showingResults = false
    @State private var sessionCorrect = 0
    @State private var sessionTotal = 0
    @State private var revealedAnswer = false

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
            .navigationTitle("Fill in the Blanks")
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
                blanksSection(verse: verse)
                actionButtons(verse: verse)
            }
            .padding()
        }
        .onAppear {
            setupBlanks(for: verse)
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
        VStack(spacing: 8) {
            Image(systemName: verse.category.icon)
                .font(.title2)
                .foregroundColor(verse.category.color)

            Text(verse.reference)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text(verse.translation)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Blanks Section

    private func blanksSection(verse: MemoryVerse) -> some View {
        let blankData = createBlanks(from: verse.text)

        return VStack(alignment: .leading, spacing: 16) {
            Text("Fill in the missing words:")
                .font(.headline)
                .foregroundColor(AppColors.text)

            FlowLayout(spacing: 8) {
                ForEach(Array(blankData.enumerated()), id: \.offset) { index, item in
                    if item.isBlank {
                        blankField(index: item.blankIndex ?? 0, correctWord: item.word)
                    } else {
                        Text(item.word)
                            .foregroundColor(AppColors.text)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }

    private func blankField(index: Int, correctWord: String) -> some View {
        let answer = index < userAnswers.count ? userAnswers[index] : ""
        let isCorrect = answer.lowercased().trimmingCharacters(in: .whitespaces) == correctWord.lowercased()

        return VStack(spacing: 4) {
            TextField("", text: binding(for: index))
                .frame(width: max(CGFloat(correctWord.count * 10), 60))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    revealedAnswer
                        ? (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        : AppColors.border.opacity(0.5)
                )
                .cornerRadius(8)
                .foregroundColor(AppColors.text)
                .multilineTextAlignment(.center)
                .disabled(revealedAnswer)

            if revealedAnswer && !isCorrect {
                Text(correctWord)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < userAnswers.count ? userAnswers[index] : "" },
            set: { newValue in
                while userAnswers.count <= index {
                    userAnswers.append("")
                }
                userAnswers[index] = newValue
            }
        )
    }

    // MARK: - Action Buttons

    private func actionButtons(verse: MemoryVerse) -> some View {
        VStack(spacing: 12) {
            if !revealedAnswer {
                Button(action: { checkAnswers(verse: verse) }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Check Answers")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
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

            Text("\(sessionCorrect)/\(sessionTotal) blanks correct")
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

    private func setupBlanks(for verse: MemoryVerse) {
        let blankCount = createBlanks(from: verse.text).filter { $0.isBlank }.count
        userAnswers = Array(repeating: "", count: blankCount)
        revealedAnswer = false
    }

    private func createBlanks(from text: String) -> [BlankItem] {
        let words = text.components(separatedBy: " ")
        var blankIndices = Set<Int>()

        let blankCount = max(words.count / 4, 2)
        while blankIndices.count < blankCount && blankIndices.count < words.count {
            blankIndices.insert(Int.random(in: 0..<words.count))
        }

        var blankIndex = 0
        return words.enumerated().map { index, word in
            if blankIndices.contains(index) {
                let item = BlankItem(word: word, isBlank: true, blankIndex: blankIndex)
                blankIndex += 1
                return item
            }
            return BlankItem(word: word, isBlank: false, blankIndex: nil)
        }
    }

    private func checkAnswers(verse: MemoryVerse) {
        revealedAnswer = true
        let blankData = createBlanks(from: verse.text).filter { $0.isBlank }

        var correctCount = 0
        for (index, item) in blankData.enumerated() {
            let answer = index < userAnswers.count ? userAnswers[index] : ""
            if answer.lowercased().trimmingCharacters(in: .whitespaces) == item.word.lowercased() {
                correctCount += 1
            }
        }

        sessionCorrect += correctCount
        sessionTotal += blankData.count

        let allCorrect = correctCount == blankData.count
        viewModel.recordReview(verse, correct: allCorrect)
    }

    private func moveToNext() {
        if currentIndex + 1 < currentVerses.count {
            currentIndex += 1
            if let verse = currentVerse {
                setupBlanks(for: verse)
            }
        } else {
            showingResults = true
        }
    }
}

#Preview {
    FillBlanksPracticeView(viewModel: ScriptureMemoryViewModel())
}
