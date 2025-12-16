//
//  ListeningPracticeView.swift
//  WePray - Prayer Tutoring App
//
//  Listening practice UI with OpenAI TTS

import SwiftUI

struct ListeningPracticeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ListeningPracticeViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        difficultySelector
                        audioPlayerCard
                        questionCard
                        answerOptions
                        resultSection
                        navigationButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Listening Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsMenu
                }
            }
        }
        .onAppear {
            viewModel.configure(appState: appState)
            Task { await viewModel.loadPrayers() }
        }
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 20) {
            StatItem(title: "Correct", value: "\(viewModel.correctCount)", icon: "checkmark.circle.fill")
            StatItem(title: "Total", value: "\(viewModel.totalAttempts)", icon: "number.circle")
            StatItem(title: "Accuracy", value: "\(viewModel.accuracy)%", icon: "percent")
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Difficulty Selector
    private var difficultySelector: some View {
        HStack(spacing: 12) {
            ForEach(PracticeDifficulty.allCases, id: \.self) { difficulty in
                Button(action: {
                    viewModel.selectedDifficulty = difficulty
                    Task { await viewModel.loadPrayers() }
                }) {
                    Text(difficulty.displayName)
                        .font(.subheadline)
                        .fontWeight(viewModel.selectedDifficulty == difficulty ? .semibold : .regular)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedDifficulty == difficulty ? AppColors.primary : AppColors.background)
                        .foregroundColor(viewModel.selectedDifficulty == difficulty ? .white : AppColors.text)
                        .cornerRadius(20)
                }
            }
        }
    }

    // MARK: - Audio Player Card
    private var audioPlayerCard: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView("Loading exercises...")
            } else if viewModel.currentPrayer != nil {
                Text("Listen to the prayer")
                    .font(.headline)

                Button(action: { Task { await viewModel.playCurrentPrayer() } }) {
                    HStack(spacing: 12) {
                        if viewModel.isGeneratingAudio {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                                .font(.title2)
                        }
                        Text(viewModel.isPlaying ? "Stop" : "Play Prayer")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isGeneratingAudio)

                speedSelector
            } else {
                Text("No exercises available")
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Speed Selector
    private var speedSelector: some View {
        HStack {
            Text("Speed:")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            ForEach(viewModel.speedOptions, id: \.self) { speed in
                Button(action: { viewModel.playbackSpeed = speed }) {
                    Text("\(speed, specifier: "%.2f")x")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.playbackSpeed == speed ? AppColors.secondary : AppColors.background)
                        .foregroundColor(viewModel.playbackSpeed == speed ? .white : AppColors.text)
                        .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Question Card
    @ViewBuilder
    private var questionCard: some View {
        if let prayer = viewModel.currentPrayer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Question")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)

                Text(prayer.question)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }

    // MARK: - Answer Options
    @ViewBuilder
    private var answerOptions: some View {
        if let prayer = viewModel.currentPrayer {
            VStack(spacing: 12) {
                ForEach(Array(prayer.answers.enumerated()), id: \.offset) { index, answer in
                    AnswerButton(
                        text: answer,
                        index: index,
                        isSelected: viewModel.selectedAnswer == index,
                        isCorrect: viewModel.showResult && index == prayer.correctAnswerIndex,
                        isWrong: viewModel.showResult && viewModel.selectedAnswer == index && index != prayer.correctAnswerIndex,
                        showResult: viewModel.showResult
                    ) {
                        if !viewModel.showResult {
                            viewModel.selectAnswer(index)
                        }
                    }
                }

                if viewModel.selectedAnswer != nil && !viewModel.showResult {
                    Button(action: { viewModel.checkAnswer() }) {
                        Text("Check Answer")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Result Section
    @ViewBuilder
    private var resultSection: some View {
        if viewModel.showResult {
            VStack(spacing: 12) {
                Image(systemName: viewModel.isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(viewModel.isAnswerCorrect ? AppColors.success : AppColors.error)

                Text(viewModel.isAnswerCorrect ? "Correct!" : "Not quite right")
                    .font(.title2)
                    .fontWeight(.bold)

                if !viewModel.isAnswerCorrect, let prayer = viewModel.currentPrayer {
                    Text("The correct answer was: \(prayer.answers[prayer.correctAnswerIndex])")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                        .multilineTextAlignment(.center)
                }

                Button(action: { Task { await viewModel.playCurrentPrayer() } }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Listen Again")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppColors.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: { viewModel.previousPrayer() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColors.background)
                .foregroundColor(AppColors.text)
                .cornerRadius(10)
            }

            Button(action: { viewModel.nextPrayer() }) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Settings Menu
    private var settingsMenu: some View {
        Menu {
            Menu("Voice") {
                ForEach(OpenAIVoice.allCases, id: \.self) { voice in
                    Button(action: { viewModel.selectedVoice = voice }) {
                        HStack {
                            Text(voice.displayName)
                            if viewModel.selectedVoice == voice {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "gearshape")
                .foregroundColor(AppColors.primary)
        }
    }
}

// MARK: - Answer Button Component
struct AnswerButton: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showResult: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(["A", "B", "C", "D"][index]).")
                    .fontWeight(.bold)
                Text(text)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                    } else if isWrong {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.error)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .disabled(showResult)
    }

    private var backgroundColor: Color {
        if isCorrect { return AppColors.success.opacity(0.2) }
        if isWrong { return AppColors.error.opacity(0.2) }
        if isSelected { return AppColors.primary.opacity(0.1) }
        return AppColors.cardBackground
    }

    private var foregroundColor: Color {
        if isCorrect { return AppColors.success }
        if isWrong { return AppColors.error }
        return AppColors.text
    }

    private var borderColor: Color {
        if isSelected && !showResult { return AppColors.primary }
        return .clear
    }
}

#Preview {
    ListeningPracticeView()
        .environmentObject(AppState())
}
