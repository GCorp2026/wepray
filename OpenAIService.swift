//
//  OpenAIService.swift
//  WePray - Prayer Tutoring App
//
//  Centralized OpenAI API service for GPT-4o, Whisper, and TTS

import Foundation
import AVFoundation

// MARK: - OpenAI Voice Options
enum OpenAIVoice: String, CaseIterable, Codable {
    case alloy = "alloy"
    case echo = "echo"
    case fable = "fable"
    case onyx = "onyx"
    case nova = "nova"
    case shimmer = "shimmer"

    var displayName: String {
        switch self {
        case .alloy: return "Alloy (Neutral)"
        case .echo: return "Echo (Male)"
        case .fable: return "Fable (Expressive)"
        case .onyx: return "Onyx (Deep Male)"
        case .nova: return "Nova (Female)"
        case .shimmer: return "Shimmer (Warm Female)"
        }
    }
}

// MARK: - OpenAI Service Errors
enum OpenAIServiceError: Error, LocalizedError {
    case invalidAPIKey
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case transcriptionFailed
    case ttsFailed
    case chatCompletionFailed
    case audioDataInvalid

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: return "OpenAI API key is missing or invalid"
        case .invalidURL: return "Invalid API URL"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response from OpenAI"
        case .transcriptionFailed: return "Audio transcription failed"
        case .ttsFailed: return "Text-to-speech generation failed"
        case .chatCompletionFailed: return "Chat completion failed"
        case .audioDataInvalid: return "Audio data is invalid"
        }
    }
}

// MARK: - OpenAI Service
class OpenAIService {
    static let shared = OpenAIService()

    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String { AppConfig.openAIAPIKey }

    private init() {}

    // MARK: - GPT-4o Chat Completion
    func chatCompletion(
        systemPrompt: String,
        userMessage: String,
        temperature: Double = 0.7,
        maxTokens: Int = 1024
    ) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIServiceError.invalidAPIKey }

        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw OpenAIServiceError.invalidURL
        }

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": temperature,
            "max_tokens": maxTokens
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw OpenAIServiceError.chatCompletionFailed
            }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }

            throw OpenAIServiceError.invalidResponse
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }

    // MARK: - Whisper Transcription
    func transcribeAudio(fileURL: URL, language: String? = nil) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIServiceError.invalidAPIKey }

        guard let url = URL(string: "\(baseURL)/audio/transcriptions") else {
            throw OpenAIServiceError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        var body = Data()

        // Add model field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        // Add language if specified
        if let lang = language {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(lang)\r\n".data(using: .utf8)!)
        }

        // Add audio file
        let audioData = try Data(contentsOf: fileURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw OpenAIServiceError.transcriptionFailed
            }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let text = json["text"] as? String {
                return text
            }

            throw OpenAIServiceError.invalidResponse
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }

    // MARK: - Text-to-Speech
    func textToSpeech(
        text: String,
        voice: OpenAIVoice = .nova,
        speed: Double = 1.0
    ) async throws -> Data {
        guard !apiKey.isEmpty else { throw OpenAIServiceError.invalidAPIKey }

        guard let url = URL(string: "\(baseURL)/audio/speech") else {
            throw OpenAIServiceError.invalidURL
        }

        let requestBody: [String: Any] = [
            "model": "tts-1-hd",
            "input": text,
            "voice": voice.rawValue,
            "speed": speed
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw OpenAIServiceError.ttsFailed
            }

            guard !data.isEmpty else {
                throw OpenAIServiceError.audioDataInvalid
            }

            return data
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }

    // MARK: - Save Audio to File
    func saveAudioToFile(_ audioData: Data, filename: String = "tts_output.mp3") -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)

        do {
            try audioData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save audio: \(error)")
            return nil
        }
    }

    // MARK: - Speaking Practice Evaluation
    func evaluatePronunciation(
        originalText: String,
        spokenText: String,
        language: Language
    ) async throws -> PronunciationFeedback {
        let systemPrompt = """
        You are a prayer pronunciation coach. Evaluate the user's spoken prayer against the original text.
        Provide feedback in \(language.name) language.

        Rate accuracy from 0-100 and provide:
        1. Overall score
        2. Specific words that need improvement
        3. Encouragement and tips

        Respond in JSON format:
        {
            "score": <number>,
            "accuracy": "<high/medium/low>",
            "feedback": "<encouraging feedback>",
            "improvements": ["<word1>", "<word2>"],
            "tips": "<pronunciation tips>"
        }
        """

        let userMessage = """
        Original prayer text: "\(originalText)"
        User spoke: "\(spokenText)"
        """

        let response = try await chatCompletion(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            temperature: 0.3
        )

        // Parse JSON response
        if let data = response.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return PronunciationFeedback(
                score: json["score"] as? Int ?? 70,
                accuracy: json["accuracy"] as? String ?? "medium",
                feedback: json["feedback"] as? String ?? "Good effort!",
                improvements: json["improvements"] as? [String] ?? [],
                tips: json["tips"] as? String ?? ""
            )
        }

        return PronunciationFeedback(
            score: 70,
            accuracy: "medium",
            feedback: "Your pronunciation is improving!",
            improvements: [],
            tips: "Keep practicing daily for best results."
        )
    }

    // MARK: - Generate Prayer Phrases
    func generatePrayerPhrases(
        denomination: ChristianDenomination,
        language: Language,
        difficulty: PracticeDifficulty
    ) async throws -> [PrayerPhrase] {
        let systemPrompt = """
        Generate 5 prayer phrases for \(denomination.name) tradition in \(language.name).
        Difficulty level: \(difficulty.rawValue)

        For beginner: short, simple phrases (3-8 words)
        For intermediate: medium phrases (8-15 words)
        For advanced: complex prayers (15-25 words)

        Respond in JSON array format:
        [
            {"text": "<prayer phrase>", "translation": "<English translation if not English>"},
            ...
        ]
        """

        let response = try await chatCompletion(
            systemPrompt: systemPrompt,
            userMessage: "Generate prayer phrases now.",
            temperature: 0.8
        )

        if let data = response.data(using: .utf8),
           let phrases = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            return phrases.compactMap { dict in
                guard let text = dict["text"] else { return nil }
                return PrayerPhrase(
                    text: text,
                    translation: dict["translation"],
                    difficulty: difficulty
                )
            }
        }

        return []
    }
}

// MARK: - Supporting Types
struct PronunciationFeedback {
    let score: Int
    let accuracy: String
    let feedback: String
    let improvements: [String]
    let tips: String
}

struct PrayerPhrase: Identifiable {
    let id = UUID()
    let text: String
    let translation: String?
    let difficulty: PracticeDifficulty
}

enum PracticeDifficulty: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var displayName: String {
        rawValue.capitalized
    }
}
