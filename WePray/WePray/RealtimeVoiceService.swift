//
//  RealtimeVoiceService.swift
//  WePray - Real-time voice streaming using OpenAI Realtime API (~300ms latency)

import Foundation
import AVFoundation

@MainActor
class RealtimeVoiceService: ObservableObject {
    @Published var isConnected = false
    @Published var isListening = false
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var currentTranscription = ""
    @Published var responseText = ""
    @Published var conversationHistory: [RealtimeMessage] = []

    private var denomination = "Protestant", language = "English", voice = "nova"
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayerNode?
    private var webSocketTask: URLSessionWebSocketTask?
    private var isReceivingAudio = false
    private let sampleRate: Double = 24000
    private let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 24000, channels: 1, interleaved: true)!

    init() {
        setupAudioSession()
    }

    // MARK: - Configuration
    func configure(denomination: String, language: String, voice: String = "nova") {
        self.denomination = denomination
        self.language = language
        self.voice = voice
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            errorMessage = "Audio session setup failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Connection
    func connect() async throws {
        guard !AppConfig.openAIAPIKey.isEmpty else {
            throw RealtimeServiceError.invalidAPIKey
        }

        let urlString = "wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview"
        guard let url = URL(string: urlString) else {
            throw RealtimeServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(AppConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("realtime=v1", forHTTPHeaderField: "OpenAI-Beta")

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()

        isConnected = true

        // Configure session with prayer context
        try await configureSession()

        // Start receiving messages
        receiveMessages()
    }

    private func configureSession() async throws {
        let sessionConfig: [String: Any] = [
            "type": "session.update",
            "session": [
                "modalities": ["text", "audio"],
                "instructions": buildPrayerInstructions(),
                "voice": voice,
                "input_audio_format": "pcm16",
                "output_audio_format": "pcm16",
                "input_audio_transcription": ["model": "whisper-1"],
                "turn_detection": [
                    "type": "server_vad",
                    "threshold": 0.5,
                    "prefix_padding_ms": 300,
                    "silence_duration_ms": 500
                ]
            ]
        ]

        let data = try JSONSerialization.data(withJSONObject: sessionConfig)
        try await webSocketTask?.send(.data(data))
    }

    private func buildPrayerInstructions() -> String {
        """
        You are a prayer leader from the \(denomination) tradition.
        Respond to prayer requests in \(language) language.
        Generate heartfelt, spoken prayers that:
        - Address the user's request with compassion
        - Follow \(denomination) prayer traditions
        - Are warm and spiritually comforting
        - Are suitable for being spoken aloud
        Keep responses to 2-4 sentences for natural conversation flow.
        """
    }

    // MARK: - Audio Streaming
    func startListening() {
        guard isConnected else {
            errorMessage = "Not connected to Realtime API"
            return
        }

        isListening = true
        errorMessage = nil
        currentTranscription = ""

        startAudioCapture()
    }

    func stopListening() {
        isListening = false
        stopAudioCapture()

        // Send commit to finalize audio input
        Task {
            try? await sendEvent(["type": "input_audio_buffer.commit"])
        }
    }

    private func startAudioCapture() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        // Install tap to capture audio
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer, from: inputFormat)
        }

        do {
            try audioEngine.start()
        } catch {
            errorMessage = "Failed to start audio capture: \(error.localizedDescription)"
        }
    }

    private func stopAudioCapture() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, from format: AVAudioFormat) {
        guard isListening else { return }

        // Convert to PCM16 at 24kHz if needed
        guard let convertedBuffer = convertToRealtimeFormat(buffer, from: format) else { return }

        // Send audio chunk
        Task { @MainActor in
            await sendAudioChunk(convertedBuffer)
        }
    }

    private func convertToRealtimeFormat(_ buffer: AVAudioPCMBuffer, from sourceFormat: AVAudioFormat) -> Data? {
        // Create converter if source format differs
        guard let converter = AVAudioConverter(from: sourceFormat, to: audioFormat) else { return nil }

        let frameCount = AVAudioFrameCount(Double(buffer.frameLength) * sampleRate / sourceFormat.sampleRate)
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return nil }

        var error: NSError?
        converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        guard error == nil, let int16Data = convertedBuffer.int16ChannelData else { return nil }

        return Data(bytes: int16Data[0], count: Int(convertedBuffer.frameLength) * 2)
    }

    private func sendAudioChunk(_ audioData: Data) async {
        let base64Audio = audioData.base64EncodedString()
        try? await sendEvent([
            "type": "input_audio_buffer.append",
            "audio": base64Audio
        ])
    }

    // MARK: - Message Handling
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let message):
                    self?.handleMessage(message)
                    self?.receiveMessages() // Continue receiving
                case .failure(let error):
                    self?.errorMessage = "WebSocket error: \(error.localizedDescription)"
                    self?.isConnected = false
                }
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            parseEvent(data)
        case .string(let text):
            if let data = text.data(using: .utf8) {
                parseEvent(data)
            }
        @unknown default:
            break
        }
    }

    private func parseEvent(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }

        switch type {
        case "response.audio_transcript.delta":
            if let delta = json["delta"] as? String {
                responseText += delta
            }
        case "response.audio.delta":
            if let audio = json["delta"] as? String,
               let audioData = Data(base64Encoded: audio) {
                playAudioChunk(audioData)
            }
        case "response.done":
            isProcessing = false
            if !responseText.isEmpty {
                conversationHistory.append(RealtimeMessage(content: responseText, isFromUser: false))
                responseText = ""
            }
        case "input_audio_buffer.speech_started":
            isProcessing = true
        case "conversation.item.input_audio_transcription.completed":
            if let transcript = json["transcript"] as? String {
                currentTranscription = transcript
                conversationHistory.append(RealtimeMessage(content: transcript, isFromUser: true))
            }
        case "error":
            if let errorData = json["error"] as? [String: Any],
               let errorMsg = errorData["message"] as? String {
                errorMessage = errorMsg
            }
        default:
            break
        }
    }

    private func playAudioChunk(_ audioData: Data) {
        // Convert PCM16 data to AVAudioPCMBuffer and play
        let frameCount = AVAudioFrameCount(audioData.count / 2)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        audioData.withUnsafeBytes { rawBuffer in
            if let baseAddress = rawBuffer.baseAddress {
                memcpy(buffer.int16ChannelData![0], baseAddress, audioData.count)
            }
        }

        if audioPlayer == nil {
            setupAudioPlayer()
        }

        audioPlayer?.scheduleBuffer(buffer)
        if !isReceivingAudio {
            audioPlayer?.play()
            isReceivingAudio = true
        }
    }

    private func setupAudioPlayer() {
        let engine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()

        engine.attach(audioPlayer!)
        engine.connect(audioPlayer!, to: engine.mainMixerNode, format: audioFormat)

        try? engine.start()
    }

    // MARK: - Utilities
    private func sendEvent(_ event: [String: Any]) async throws {
        let data = try JSONSerialization.data(withJSONObject: event)
        try await webSocketTask?.send(.data(data))
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        isListening = false
        stopAudioCapture()
    }

    func clearHistory() {
        conversationHistory.removeAll()
        currentTranscription = ""
        responseText = ""
    }
}

// MARK: - Supporting Types
struct RealtimeMessage: Identifiable {
    let id = UUID(); let content: String; let isFromUser: Bool; let timestamp = Date()
}

enum RealtimeServiceError: Error, LocalizedError {
    case invalidAPIKey, invalidURL, connectionFailed, notConnected
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: return "OpenAI API key is missing"
        case .invalidURL: return "Invalid WebSocket URL"
        case .connectionFailed: return "Failed to connect"
        case .notConnected: return "Not connected"
        }
    }
}
