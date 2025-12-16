//
//  ListeningPracticeViewModel.swift
//  WePray - Prayer Tutoring App
//
//  Listening practice logic with GPT-4o and OpenAI TTS

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class ListeningPracticeViewModel: ObservableObject {
    @Published var currentPrayer: ListeningPrayer?
    @Published var prayers: [ListeningPrayer] = []
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var isGeneratingAudio = false
    @Published var selectedAnswer: Int?
    @Published var showResult = false
    @Published var playbackSpeed: Float = 1.0
    @Published var selectedVoice: OpenAIVoice = .nova
    @Published var selectedDifficulty: PracticeDifficulty = .beginner
    @Published var listeningHistory: [ListeningResult] = []
    @Published var errorMessage: String?

    private var appState: AppState?
    private var audioPlayer: AVAudioPlayer?
    private let openAI = OpenAIService.shared

    let speedOptions: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5]

    func configure(appState: AppState) {
        self.appState = appState
        loadHistory()
    }

    // MARK: - Generate Listening Exercises
    func loadPrayers() async {
        guard let appState = appState else { return }

        isLoading = true
        errorMessage = nil

        let language = appState.currentUser?.selectedLanguage ?? Language.defaultLanguages[2]
        let denomination = appState.currentUser?.selectedDenomination ?? ChristianDenomination.defaultDenominations[5]

        do {
            prayers = try await generateListeningExercises(
                denomination: denomination,
                language: language,
                difficulty: selectedDifficulty
            )
            currentPrayer = prayers.first
        } catch {
            errorMessage = "Failed to load exercises. Using defaults."
            prayers = getDefaultPrayers(language: language)
            currentPrayer = prayers.first
        }

        isLoading = false
    }

    private func generateListeningExercises(
        denomination: ChristianDenomination,
        language: Language,
        difficulty: PracticeDifficulty
    ) async throws -> [ListeningPrayer] {
        let systemPrompt = """
        Generate 3 listening comprehension exercises for \(denomination.name) prayer practice in \(language.name).
        Difficulty: \(difficulty.rawValue)

        For each exercise provide:
        - A short prayer text (2-4 sentences)
        - A comprehension question about the prayer
        - 4 multiple choice answers (one correct)
        - Index of correct answer (0-3)

        Respond in JSON:
        [
            {
                "prayerText": "<prayer>",
                "question": "<question>",
                "answers": ["<a1>", "<a2>", "<a3>", "<a4>"],
                "correctIndex": <0-3>
            }
        ]
        """

        let response = try await openAI.chatCompletion(
            systemPrompt: systemPrompt,
            userMessage: "Generate listening exercises now.",
            temperature: 0.8
        )

        if let data = response.data(using: .utf8),
           let exercises = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return exercises.compactMap { dict -> ListeningPrayer? in
                guard let text = dict["prayerText"] as? String,
                      let question = dict["question"] as? String,
                      let answers = dict["answers"] as? [String],
                      let correct = dict["correctIndex"] as? Int else {
                    return nil
                }
                return ListeningPrayer(
                    prayerText: text,
                    question: question,
                    answers: answers,
                    correctAnswerIndex: correct,
                    difficulty: difficulty
                )
            }
        }

        return []
    }

    // MARK: - Audio Playback
    func playCurrentPrayer() async {
        guard let prayer = currentPrayer else { return }

        if isPlaying {
            stopPlayback()
            return
        }

        isGeneratingAudio = true
        errorMessage = nil

        do {
            let audioData = try await openAI.textToSpeech(
                text: prayer.prayerText,
                voice: selectedVoice,
                speed: Double(playbackSpeed)
            )

            if let fileURL = openAI.saveAudioToFile(audioData, filename: "listening_\(prayer.id).mp3") {
                playAudioFile(at: fileURL)
            }
        } catch {
            errorMessage = "Failed to generate audio."
            speakWithSystemTTS(prayer.prayerText)
        }

        isGeneratingAudio = false
    }

    private func playAudioFile(at url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.enableRate = true
            audioPlayer?.rate = playbackSpeed
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Playback failed: \(error)")
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }

    private func speakWithSystemTTS(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * playbackSpeed
        synthesizer.speak(utterance)
        isPlaying = true
    }

    // MARK: - Answer Checking
    func selectAnswer(_ index: Int) {
        selectedAnswer = index
    }

    func checkAnswer() {
        guard let prayer = currentPrayer, let selected = selectedAnswer else { return }

        showResult = true
        let isCorrect = selected == prayer.correctAnswerIndex

        saveResult(prayer: prayer, isCorrect: isCorrect)
    }

    var isAnswerCorrect: Bool {
        guard let prayer = currentPrayer, let selected = selectedAnswer else { return false }
        return selected == prayer.correctAnswerIndex
    }

    // MARK: - Navigation
    func nextPrayer() {
        guard let current = currentPrayer,
              let currentIndex = prayers.firstIndex(where: { $0.id == current.id }),
              currentIndex < prayers.count - 1 else {
            return
        }

        currentPrayer = prayers[currentIndex + 1]
        resetState()
    }

    func previousPrayer() {
        guard let current = currentPrayer,
              let currentIndex = prayers.firstIndex(where: { $0.id == current.id }),
              currentIndex > 0 else {
            return
        }

        currentPrayer = prayers[currentIndex - 1]
        resetState()
    }

    private func resetState() {
        selectedAnswer = nil
        showResult = false
        stopPlayback()
    }

    // MARK: - History
    private func saveResult(prayer: ListeningPrayer, isCorrect: Bool) {
        let result = ListeningResult(
            prayerText: prayer.prayerText,
            isCorrect: isCorrect,
            difficulty: selectedDifficulty,
            timestamp: Date()
        )
        listeningHistory.append(result)

        if let data = try? JSONEncoder().encode(listeningHistory) {
            UserDefaults.standard.set(data, forKey: "listeningPracticeHistory")
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "listeningPracticeHistory"),
           let history = try? JSONDecoder().decode([ListeningResult].self, from: data) {
            listeningHistory = history
        }
    }

    var correctCount: Int {
        listeningHistory.filter { $0.isCorrect }.count
    }

    var totalAttempts: Int {
        listeningHistory.count
    }

    var accuracy: Int {
        guard totalAttempts > 0 else { return 0 }
        return (correctCount * 100) / totalAttempts
    }

    // MARK: - Default Prayers
    private func getDefaultPrayers(language: Language) -> [ListeningPrayer] {
        [
            ListeningPrayer(
                prayerText: "Heavenly Father, thank you for this beautiful day. Guide my steps and fill my heart with your peace.",
                question: "What is the prayer asking for?",
                answers: ["Wealth and success", "Guidance and peace", "Good health", "Forgiveness"],
                correctAnswerIndex: 1,
                difficulty: .beginner
            ),
            ListeningPrayer(
                prayerText: "Lord, I lift up my family to you today. Protect them from harm and surround them with your love.",
                question: "Who is the prayer for?",
                answers: ["Friends", "Family", "Neighbors", "Strangers"],
                correctAnswerIndex: 1,
                difficulty: .beginner
            )
        ]
    }
}

// MARK: - Models
struct ListeningPrayer: Identifiable {
    let id = UUID()
    let prayerText: String
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
    let difficulty: PracticeDifficulty
}

struct ListeningResult: Identifiable, Codable {
    var id = UUID()
    let prayerText: String
    let isCorrect: Bool
    let difficulty: PracticeDifficulty
    let timestamp: Date
}
