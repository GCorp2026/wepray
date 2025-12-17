import SwiftUI

struct FlashcardPracticeView: View {
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var sessionCorrect = 0
    @State private var sessionTotal = 0
    @State private var showingResults = false
    @State private var offset: CGSize = .zero

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
            .navigationTitle("Flashcards")
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
        VStack(spacing: 24) {
            progressIndicator

            flashcard(verse: verse)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { gesture in
                            handleSwipe(gesture.translation.width)
                        }
                )

            instructionText

            actionButtons
        }
        .padding()
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

    // MARK: - Flashcard

    private func flashcard(verse: MemoryVerse) -> some View {
        ZStack {
            if isFlipped {
                cardBack(verse: verse)
            } else {
                cardFront(verse: verse)
            }
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .offset(x: offset.width)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .animation(.spring(), value: offset)
        .onTapGesture {
            withAnimation(.spring()) {
                isFlipped.toggle()
            }
        }
    }

    private func cardFront(verse: MemoryVerse) -> some View {
        VStack(spacing: 16) {
            Image(systemName: verse.category.icon)
                .font(.largeTitle)
                .foregroundColor(verse.category.color)

            Text(verse.reference)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text(verse.translation)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            Spacer()

            Text("Tap to reveal")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppColors.primary.opacity(0.3), radius: 10)
    }

    private func cardBack(verse: MemoryVerse) -> some View {
        VStack(spacing: 16) {
            Text(verse.reference)
                .font(.headline)
                .foregroundColor(AppColors.subtext)

            ScrollView {
                Text(verse.text)
                    .font(.title3)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: verse.masteryLevel.icon)
                Text(verse.masteryLevel.title)
            }
            .font(.caption)
            .foregroundColor(verse.masteryLevel.color)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppColors.primary.opacity(0.3), radius: 10)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }

    // MARK: - Instruction Text

    private var instructionText: some View {
        Text(isFlipped ? "Did you remember it?" : "Try to recall the verse")
            .font(.subheadline)
            .foregroundColor(AppColors.subtext)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { markIncorrect() }) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                    Text("Forgot")
                        .font(.caption)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.15))
                .cornerRadius(12)
            }

            Button(action: { markCorrect() }) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                    Text("Got it!")
                        .font(.caption)
                }
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .opacity(isFlipped ? 1 : 0.5)
        .disabled(!isFlipped)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.green)
            Text("No verses to review!")
                .font(.title2)
                .foregroundColor(AppColors.text)
            Text("Add more verses or wait for your next review session")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
            Button("Close") { dismiss() }
                .foregroundColor(AppColors.accent)
                .padding()
        }
        .padding()
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

            VStack(spacing: 8) {
                Text("\(sessionCorrect)/\(sessionTotal) correct")
                    .font(.title2)
                    .foregroundColor(AppColors.text)
                Text("\(Int(Double(sessionCorrect) / Double(max(sessionTotal, 1)) * 100))% accuracy")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

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

    // MARK: - Actions

    private func handleSwipe(_ width: CGFloat) {
        if width > 100 {
            markCorrect()
        } else if width < -100 {
            markIncorrect()
        }
        offset = .zero
    }

    private func markCorrect() {
        guard let verse = currentVerse else { return }
        viewModel.recordReview(verse, correct: true)
        sessionCorrect += 1
        sessionTotal += 1
        moveToNext()
    }

    private func markIncorrect() {
        guard let verse = currentVerse else { return }
        viewModel.recordReview(verse, correct: false)
        sessionTotal += 1
        moveToNext()
    }

    private func moveToNext() {
        isFlipped = false
        if currentIndex + 1 < currentVerses.count {
            currentIndex += 1
        } else {
            showingResults = true
        }
    }
}

#Preview {
    FlashcardPracticeView(viewModel: ScriptureMemoryViewModel())
}
