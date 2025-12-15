//
//  SpeakingPracticeView.swift
//  WePray - Prayer Tutoring App
//
//  Speaking practice UI with GPT-4o evaluation

import SwiftUI

struct SpeakingPracticeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SpeakingPracticeViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        difficultySelector
                        phraseCard(geometry: geometry)
                        recordingSection
                        feedbackSection
                        navigationButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Speaking Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    voiceSettingsMenu
                }
            }
        }
        .onAppear {
            viewModel.configure(appState: appState)
            Task { await viewModel.loadPhrases() }
        }
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 20) {
            StatItem(title: "Practiced", value: "\(viewModel.totalPracticed)", icon: "checkmark.circle")
            StatItem(title: "Avg Score", value: "\(viewModel.averageScore)%", icon: "chart.bar")
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
                    Task { await viewModel.loadPhrases() }
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

    // MARK: - Phrase Card
    private func phraseCard(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            if viewModel.isLoadingPhrases {
                ProgressView("Loading phrases...")
                    .frame(height: 150)
            } else if let phrase = viewModel.currentPhrase {
                Text(phrase.text)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()

                if let translation = phrase.translation {
                    Text(translation)
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                        .italic()
                }

                Button(action: { Task { await viewModel.playPhraseAudio() } }) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Listen")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppColors.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .disabled(viewModel.isProcessing)
            } else {
                Text("No phrases available")
                    .foregroundColor(AppColors.subtext)
            }
        }
        .frame(minHeight: 200)
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Recording Section
    private var recordingSection: some View {
        VStack(spacing: 16) {
            if viewModel.isProcessing {
                HStack {
                    ProgressView()
                    Text("Analyzing your pronunciation...")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                }
            } else if viewModel.isRecording {
                Text("Listening... Tap to stop")
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
            } else {
                Text("Tap to record your pronunciation")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(viewModel.isRecording ? AppColors.error : AppColors.primary)
                        .frame(width: 80, height: 80)

                    Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .disabled(viewModel.isProcessing || viewModel.currentPhrase == nil)

            if !viewModel.transcribedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You said:")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                    Text(viewModel.transcribedText)
                        .font(.body)
                        .padding()
                        .background(AppColors.background)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Feedback Section
    @ViewBuilder
    private var feedbackSection: some View {
        if let feedback = viewModel.feedback {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Score")
                        .font(.headline)
                    Spacer()
                    Text("\(feedback.score)%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor(feedback.score))
                }

                ProgressView(value: Double(feedback.score), total: 100)
                    .tint(scoreColor(feedback.score))

                Text(feedback.feedback)
                    .font(.body)
                    .foregroundColor(AppColors.text)

                if !feedback.improvements.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus on:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        ForEach(feedback.improvements, id: \.self) { word in
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(AppColors.accent)
                                Text(word)
                            }
                            .font(.subheadline)
                        }
                    }
                }

                if !feedback.tips.isEmpty {
                    Text(feedback.tips)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                        .padding(.top, 4)
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
            Button(action: { viewModel.previousPhrase() }) {
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

            Button(action: { viewModel.nextPhrase() }) {
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

    // MARK: - Voice Settings Menu
    private var voiceSettingsMenu: some View {
        Menu {
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
        } label: {
            Image(systemName: "speaker.wave.3")
                .foregroundColor(AppColors.primary)
        }
    }

    // MARK: - Helpers
    private func toggleRecording() {
        if viewModel.isRecording {
            Task { await viewModel.stopRecording() }
        } else {
            viewModel.startRecording()
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return AppColors.success
        case 60..<80: return AppColors.accent
        default: return AppColors.error
        }
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SpeakingPracticeView()
        .environmentObject(AppState())
}
