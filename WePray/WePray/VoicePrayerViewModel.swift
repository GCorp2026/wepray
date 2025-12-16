//
//  VoicePrayerViewModel.swift
//  WePray - Prayer Tutoring App
//
//  Voice prayer logic with GPT-4o and OpenAI TTS

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class VoicePrayerViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var isRecording = false
    @Published var selectedVoice: OpenAIVoice = .nova
    @Published var useOpenAITTS = true
    @Published var errorMessage: String?
    @Published var useRealtimeMode = false
    @Published var isRealtimeConnected = false

    private var appState: AppState?
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let openAI = OpenAIService.shared
    private let realtimeService = RealtimeVoiceService()

    func configure(appState: AppState) {
        self.appState = appState
        addWelcomeMessage()
        setupAudioSession()
        configureRealtimeService()
    }

    private func configureRealtimeService() {
        guard let appState = appState else { return }
        let denomination = appState.currentUser?.selectedDenomination.name ?? "Protestant"
        let language = appState.currentUser?.selectedLanguage.name ?? "English"
        let voice = appState.currentUser?.preferredVoice ?? "nova"
        useRealtimeMode = appState.currentUser?.realtimeVoiceEnabled ?? false
        realtimeService.configure(denomination: denomination, language: language, voice: voice)
    }

    // MARK: - Realtime Mode
    func connectRealtime() async {
        do {
            try await realtimeService.connect()
            isRealtimeConnected = true
            errorMessage = nil
        } catch {
            errorMessage = "Realtime connection failed: \(error.localizedDescription)"
            isRealtimeConnected = false
        }
    }

    func disconnectRealtime() {
        realtimeService.disconnect()
        isRealtimeConnected = false
    }

    func toggleRealtimeMode(_ enabled: Bool) async {
        useRealtimeMode = enabled
        if enabled {
            await connectRealtime()
        } else {
            disconnectRealtime()
        }
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    private func addWelcomeMessage() {
        guard messages.isEmpty else { return }
        let language = appState?.currentUser?.selectedLanguage.name ?? "English"
        let denomination = appState?.currentUser?.selectedDenomination.name ?? "Protestant"

        let welcomeText = getWelcomeMessage(language: language, denomination: denomination)
        let welcomeMessage = ChatMessage(content: welcomeText, isFromUser: false)
        messages.append(welcomeMessage)
    }

    private func getWelcomeMessage(language: String, denomination: String) -> String {
        switch language.lowercased() {
        case "russian":
            return "Благословения! Нажмите кнопку микрофона, чтобы начать голосовую молитву в традиции \(denomination)."
        case "chinese":
            return "愿上帝保佑你！点击麦克风按钮开始\(denomination)传统的语音祷告。"
        case "spanish":
            return "Bendiciones! Toca el boton del microfono para comenzar tu oracion de voz en la tradicion \(denomination)."
        case "brazilian portuguese":
            return "Bencaos! Toque no botao do microfone para iniciar sua oracao por voz na tradicao \(denomination)."
        case "french":
            return "Benedictions! Appuyez sur le bouton du microphone pour commencer votre priere vocale dans la tradition \(denomination)."
        default:
            return "Blessings! Tap the microphone button to start your voice prayer in the \(denomination) tradition. I'll respond with an appropriate prayer in your language."
        }
    }

    func startRecording() {
        // Use realtime mode if enabled and connected
        if useRealtimeMode && isRealtimeConnected {
            realtimeService.startListening()
            isRecording = true
            errorMessage = nil
            return
        }

        // Fallback to standard recording
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

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
            errorMessage = nil
        } catch {
            errorMessage = "Failed to start recording"
            print("Recording failed: \(error)")
        }
    }

    func stopRecording() async {
        // Use realtime mode if enabled and connected
        if useRealtimeMode && isRealtimeConnected {
            realtimeService.stopListening()
            isRecording = false
            // Realtime mode handles transcription and response automatically
            // Sync messages from realtime service
            syncRealtimeMessages()
            return
        }

        // Standard recording flow
        audioRecorder?.stop()
        isRecording = false
        isProcessing = true
        errorMessage = nil

        let audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let languageCode = getWhisperLanguageCode()

        // Transcribe with Whisper
        var transcribedText: String
        do {
            transcribedText = try await openAI.transcribeAudio(fileURL: audioURL, language: languageCode)
        } catch {
            transcribedText = "Please pray for my family's health and well-being."
            errorMessage = "Transcription unavailable, using default request."
        }

        let userMessage = ChatMessage(content: transcribedText, isFromUser: true)
        messages.append(userMessage)

        // Get GPT-4o response
        let response = await getVoicePrayerResponse(for: transcribedText)
        let aiMessage = ChatMessage(content: response, isFromUser: false)
        messages.append(aiMessage)

        // Speak with OpenAI TTS or fallback
        await speakResponse(response)

        isProcessing = false
    }

    private func getVoicePrayerResponse(for userInput: String) async -> String {
        guard let appState = appState else {
            return getMockPrayer()
        }

        let language = appState.currentUser?.selectedLanguage ?? Language.defaultLanguages[2]
        let denomination = appState.currentUser?.selectedDenomination ?? ChristianDenomination.defaultDenominations[5]

        let systemPrompt = """
        You are a prayer leader from the \(denomination.name) tradition.
        Generate a heartfelt, spoken prayer in \(language.name) language that:
        - Addresses the user's request
        - Follows \(denomination.name) prayer traditions
        - Is suitable for being read aloud
        - Is warm and spiritually comforting
        Keep the prayer to 3-5 sentences.
        """

        do {
            return try await openAI.chatCompletion(
                systemPrompt: systemPrompt,
                userMessage: "Please provide a prayer for: \(userInput)",
                temperature: 0.7,
                maxTokens: 500
            )
        } catch {
            return getMockPrayer()
        }
    }

    private func speakResponse(_ text: String) async {
        if useOpenAITTS {
            do {
                let audioData = try await openAI.textToSpeech(
                    text: text,
                    voice: selectedVoice,
                    speed: 1.0
                )

                if let fileURL = openAI.saveAudioToFile(audioData, filename: "prayer_response.mp3") {
                    playAudioFile(at: fileURL)
                }
                return
            } catch {
                print("OpenAI TTS failed, falling back to system TTS")
            }
        }

        speakWithSystemTTS(text)
    }

    func playAudio(for message: ChatMessage) {
        Task {
            await speakResponse(message.content)
        }
    }

    private func playAudioFile(at url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Audio playback failed: \(error)")
        }
    }

    private func speakWithSystemTTS(_ text: String) {
        let language = appState?.currentUser?.selectedLanguage ?? Language.defaultLanguages[2]

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: getVoiceLanguageCode(language))

        speechSynthesizer.speak(utterance)
    }

    private func getVoiceLanguageCode(_ language: Language) -> String {
        switch language.code {
        case "ru": return "ru-RU"
        case "zh": return "zh-CN"
        case "es": return "es-ES"
        case "pt-BR": return "pt-BR"
        case "fr": return "fr-FR"
        default: return "en-US"
        }
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

    private func getMockPrayer() -> String {
        let language = appState?.currentUser?.selectedLanguage ?? Language.defaultLanguages[2]
        let prayers: [String: String] = [
            "en": "Heavenly Father, we lift up this prayer request to You. We ask for Your blessing, healing, and guidance. May Your peace that surpasses all understanding guard their hearts and minds. In the name of Jesus Christ, we pray. Amen.",
            "ru": "Небесный Отец, мы возносим эту молитву к Тебе. Просим Твоего благословения, исцеления и руководства. Да хранит Твой мир, превосходящий всякое разумение, их сердца и умы. Во имя Иисуса Христа молимся. Аминь.",
            "zh": "天父，我们向你献上这个祷告请求。我们祈求你的祝福、医治和引导。愿你超越一切理解的平安保守他们的心怀意念。奉耶稣基督的名祷告。阿门。",
            "es": "Padre Celestial, elevamos esta peticion de oracion a Ti. Te pedimos Tu bendicion, sanacion y guia. Que Tu paz que sobrepasa todo entendimiento guarde sus corazones y mentes. En el nombre de Jesucristo oramos. Amen.",
            "pt-BR": "Pai Celestial, elevamos este pedido de oracao a Ti. Pedimos Tua bencao, cura e orientacao. Que Tua paz que excede todo entendimento guarde seus coracoes e mentes. Em nome de Jesus Cristo, oramos. Amem.",
            "fr": "Pere Celeste, nous elevons cette demande de priere vers Toi. Nous demandons Ta benediction, Ta guerison et Ta direction. Que Ta paix qui surpasse toute intelligence garde leurs coeurs et leurs pensees. Au nom de Jesus-Christ, nous prions. Amen."
        ]

        return prayers[language.code] ?? prayers["en"]!
    }

    private func syncRealtimeMessages() {
        // Sync new messages from realtime service to view model
        for msg in realtimeService.conversationHistory {
            let exists = messages.contains { $0.content == msg.content }
            if !exists {
                messages.append(ChatMessage(content: msg.content, isFromUser: msg.isFromUser))
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
