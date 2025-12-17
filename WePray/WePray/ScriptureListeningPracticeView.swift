import SwiftUI
import AVFoundation

struct ScriptureListeningPracticeView: View {
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var showingVerse = false
    @State private var sessionCorrect = 0
    @State private var sessionTotal = 0
    @State private var showingResults = false
    @StateObject private var speechSynthesizer = SpeechSynthesizerManager()

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
            .navigationTitle("Listening Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        speechSynthesizer.stop()
                        dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
    }

    // MARK: - Practice Content

    private func practiceContent(verse: MemoryVerse) -> some View {
        VStack(spacing: 24) {
            progressIndicator
            listeningCard(verse: verse)
            controlButtons(verse: verse)

            if showingVerse {
                verseReveal(verse: verse)
            }

            Spacer()

            responseButtons(verse: verse)
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

    // MARK: - Listening Card

    private func listeningCard(verse: MemoryVerse) -> some View {
        VStack(spacing: 20) {
            Image(systemName: verse.category.icon)
                .font(.system(size: 48))
                .foregroundColor(verse.category.color)

            Text(verse.reference)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)

            Text(verse.translation)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            Text("Listen and try to recall the verse")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
                .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }

    // MARK: - Control Buttons

    private func controlButtons(verse: MemoryVerse) -> some View {
        HStack(spacing: 20) {
            Button(action: { playVerse(verse) }) {
                VStack(spacing: 8) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(AppColors.accent)

                    Text(isPlaying ? "Pause" : "Play")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Button(action: { showingVerse.toggle() }) {
                VStack(spacing: 8) {
                    Image(systemName: showingVerse ? "eye.slash.circle.fill" : "eye.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(showingVerse ? .orange : AppColors.primary)

                    Text(showingVerse ? "Hide" : "Reveal")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }
        }
    }

    // MARK: - Verse Reveal

    private func verseReveal(verse: MemoryVerse) -> some View {
        Text(verse.text)
            .font(.body)
            .foregroundColor(AppColors.text)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.primary.opacity(0.1))
            .cornerRadius(12)
            .transition(.opacity.combined(with: .scale))
    }

    // MARK: - Response Buttons

    private func responseButtons(verse: MemoryVerse) -> some View {
        VStack(spacing: 12) {
            Text("Did you remember it?")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            HStack(spacing: 16) {
                Button(action: { markIncorrect(verse) }) {
                    VStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                        Text("Needs Work")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(12)
                }

                Button(action: { markCorrect(verse) }) {
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

    // MARK: - Actions

    private func playVerse(_ verse: MemoryVerse) {
        if isPlaying {
            speechSynthesizer.stop()
            isPlaying = false
        } else {
            isPlaying = true
            speechSynthesizer.speak(verse.text) {
                isPlaying = false
            }
        }
    }

    private func markCorrect(_ verse: MemoryVerse) {
        speechSynthesizer.stop()
        viewModel.recordReview(verse, correct: true)
        sessionCorrect += 1
        sessionTotal += 1
        moveToNext()
    }

    private func markIncorrect(_ verse: MemoryVerse) {
        speechSynthesizer.stop()
        viewModel.recordReview(verse, correct: false)
        sessionTotal += 1
        moveToNext()
    }

    private func moveToNext() {
        showingVerse = false
        isPlaying = false

        if currentIndex + 1 < currentVerses.count {
            currentIndex += 1
        } else {
            showingResults = true
        }
    }
}

// MARK: - Speech Synthesizer Manager

class SpeechSynthesizerManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var completion: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, completion: @escaping () -> Void) {
        self.completion = completion
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.completion?()
        }
    }
}

#Preview {
    ScriptureListeningPracticeView(viewModel: ScriptureMemoryViewModel())
}
