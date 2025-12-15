//
//  SpeakingPracticeViewModel.swift
//  WePray - Prayer Tutoring App
//
//  Speaking practice logic with GPT-4o evaluation

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class SpeakingPracticeViewModel: ObservableObject {
    @Published var currentPhrase: PrayerPhrase?
    @Published var phrases: [PrayerPhrase] = []
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var isLoadingPhrases = false
    @Published var feedback: PronunciationFeedback?
    @Published var transcribedText: String = ""
    @Published var selectedDifficulty: PracticeDifficulty = .beginner
    @Published var practiceHistory: [PracticeResult] = []
    @Published var errorMessage: String?
    @Published var selectedVoice: OpenAIVoice = .nova

    private var appState: AppState?
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let openAI = OpenAIService.shared

    func configure(appState: AppState) {
        self.appState = appState
        loadPracticeHistory()
    }

    // MARK: - Load Prayer Phrases
    func loadPhrases() async {
        guard let appState = appState else { return }

        isLoadingPhrases = true
        errorMessage = nil

        let language = appState.currentUser?.selectedLanguage ?? Language.defaultLanguages[2]
        let denomination = appState.currentUser?.selectedDenomination ?? ChristianDenomination.defaultDenominations[5]

        do {
            phrases = try await openAI.generatePrayerPhrases(
                denomination: denomination,
                language: language,
                difficulty: selectedDifficulty
            )

            if phrases.isEmpty {
                phrases = getDefaultPhrases(language: language, difficulty: selectedDifficulty)
            }

            currentPhrase = phrases.first
        } catch {
            errorMessage = "Failed to load phrases. Using defaults."
            phrases = getDefaultPhrases(language: language, difficulty: selectedDifficulty)
            currentPhrase = phrases.first
        }

        isLoadingPhrases = false
    }

    // MARK: - Play Phrase Audio
    func playPhraseAudio() async {
        guard let phrase = currentPhrase else { return }

        isProcessing = true
        errorMessage = nil

        do {
            let audioData = try await openAI.textToSpeech(
                text: phrase.text,
                voice: selectedVoice,
                speed: selectedDifficulty == .beginner ? 0.8 : 1.0
            )

            if let fileURL = openAI.saveAudioToFile(audioData, filename: "phrase_audio.mp3") {
                playAudioFile(at: fileURL)
            }
        } catch {
            errorMessage = "Failed to generate audio. Please try again."
            speakWithSystemTTS(phrase.text)
        }

        isProcessing = false
    }

    // MARK: - Recording
    func startRecording() {
        setupAudioSession()

        let audioFilename = getDocumentsDirectory().appendingPathComponent("speaking_practice.m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            feedback = nil
            transcribedText = ""
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopRecording() async {
        audioRecorder?.stop()
        isRecording = false
        isProcessing = true

        guard let phrase = currentPhrase else {
            isProcessing = false
            return
        }

        let audioURL = getDocumentsDirectory().appendingPathComponent("speaking_practice.m4a")
        let languageCode = getWhisperLanguageCode()

        do {
            transcribedText = try await openAI.transcribeAudio(fileURL: audioURL, language: languageCode)

            let language = appState?.currentUser?.selectedLanguage ?? Language.defaultLanguages[2]
            feedback = try await openAI.evaluatePronunciation(
                originalText: phrase.text,
                spokenText: transcribedText,
                language: language
            )

            savePracticeResult(phrase: phrase, score: feedback?.score ?? 0)
        } catch {
            errorMessage = "Transcription failed. Please try again."
            transcribedText = "Could not transcribe audio"
            feedback = PronunciationFeedback(
                score: 0,
                accuracy: "unknown",
                feedback: "Please try recording again.",
                improvements: [],
                tips: "Speak clearly into the microphone."
            )
        }

        isProcessing = false
    }

    // MARK: - Navigation
    func nextPhrase() {
        guard let current = currentPhrase,
              let currentIndex = phrases.firstIndex(where: { $0.id == current.id }),
              currentIndex < phrases.count - 1 else {
            return
        }

        currentPhrase = phrases[currentIndex + 1]
        feedback = nil
        transcribedText = ""
    }

    func previousPhrase() {
        guard let current = currentPhrase,
              let currentIndex = phrases.firstIndex(where: { $0.id == current.id }),
              currentIndex > 0 else {
            return
        }

        currentPhrase = phrases[currentIndex - 1]
        feedback = nil
        transcribedText = ""
    }

    // MARK: - Practice History
    private func savePracticeResult(phrase: PrayerPhrase, score: Int) {
        let result = PracticeResult(
            phraseText: phrase.text,
            score: score,
            difficulty: selectedDifficulty,
            timestamp: Date()
        )
        practiceHistory.append(result)

        if let data = try? JSONEncoder().encode(practiceHistory) {
            UserDefaults.standard.set(data, forKey: "speakingPracticeHistory")
        }
    }

    private func loadPracticeHistory() {
        if let data = UserDefaults.standard.data(forKey: "speakingPracticeHistory"),
           let history = try? JSONDecoder().decode([PracticeResult].self, from: data) {
            practiceHistory = history
        }
    }

    var averageScore: Int {
        guard !practiceHistory.isEmpty else { return 0 }
        let total = practiceHistory.reduce(0) { $0 + $1.score }
        return total / practiceHistory.count
    }

    var totalPracticed: Int {
        practiceHistory.count
    }

    // MARK: - Helpers
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    private func playAudioFile(at url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Audio playback failed: \(error)")
        }
    }

    private func speakWithSystemTTS(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        synthesizer.speak(utterance)
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func getWhisperLanguageCode() -> String {
        guard let language = appState?.currentUser?.selectedLanguage else { return "en" }
        switch language.code {
        case "ru": return "ru"
        case "zh": return "zh"
        case "es": return "es"
        case "pt-BR": return "pt"
        case "fr": return "fr"
        default: return "en"
        }
    }

    private func getDefaultPhrases(language: Language, difficulty: PracticeDifficulty) -> [PrayerPhrase] {
        let phrases: [[String: String]]
        switch language.code {
        case "en":
            phrases = [
                ["text": "Lord, hear my prayer", "translation": nil],
                ["text": "Thank you for this day", "translation": nil],
                ["text": "Guide my steps today", "translation": nil],
                ["text": "Bless my family", "translation": nil],
                ["text": "Grant me peace", "translation": nil]
            ]
        case "es":
            phrases = [
                ["text": "Senor, escucha mi oracion", "translation": "Lord, hear my prayer"],
                ["text": "Gracias por este dia", "translation": "Thank you for this day"],
                ["text": "Guia mis pasos hoy", "translation": "Guide my steps today"]
            ]
        default:
            phrases = [
                ["text": "Lord, hear my prayer", "translation": nil],
                ["text": "Thank you for this day", "translation": nil]
            ]
        }

        return phrases.map { dict in
            PrayerPhrase(
                text: dict["text"] ?? "",
                translation: dict["translation"],
                difficulty: difficulty
            )
        }
    }
}

// MARK: - Practice Result Model
struct PracticeResult: Identifiable, Codable {
    var id = UUID()
    let phraseText: String
    let score: Int
    let difficulty: PracticeDifficulty
    let timestamp: Date
}
