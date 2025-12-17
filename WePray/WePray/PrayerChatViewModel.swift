//
//  PrayerChatViewModel.swift
//  WePray - Prayer Friend App
//

import Foundation
import SwiftUI

@MainActor
class PrayerChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false

    private var appState: AppState?

    func configure(appState: AppState) {
        self.appState = appState
        addWelcomeMessage()
    }

    private var prayerFriendName: String {
        appState?.currentUser?.prayerFriendName ?? "Prayer Friend"
    }

    private func addWelcomeMessage() {
        guard messages.isEmpty else { return }
        let language = appState?.currentUser?.selectedLanguage.name ?? "English"
        let denomination = appState?.currentUser?.selectedDenomination.name ?? "Protestant"

        let welcomeMessage = ChatMessage(
            content: getWelcomeMessage(language: language, denomination: denomination),
            isFromUser: false
        )
        messages.append(welcomeMessage)
    }

    private func getWelcomeMessage(language: String, denomination: String) -> String {
        let name = prayerFriendName
        switch language.lowercased() {
        case "russian":
            return "Благословения вам! Я \(name), ваш помощник по молитве из \(denomination) традиции. Как я могу помочь вам сегодня?"
        case "chinese":
            return "愿上帝保佑你！我是\(name)，你的\(denomination)祷告伙伴。今天我能如何帮助你祷告？"
        case "spanish":
            return "¡Bendiciones! Soy \(name), tu compañero de oración de la tradición \(denomination). ¿Cómo puedo ayudarte hoy?"
        case "brazilian portuguese":
            return "Bênçãos! Sou \(name), seu companheiro de oração da tradição \(denomination). Como posso ajudá-lo hoje?"
        case "french":
            return "Bénédictions! Je suis \(name), votre compagnon de prière de la tradition \(denomination). Comment puis-je vous aider?"
        default:
            return "Blessings to you! I'm \(name), your \(denomination) prayer friend. How can I help you with your prayer life today? Feel free to ask for guidance, request prayers, or discuss your spiritual journey."
        }
    }

    /// Process AI response to ensure it never reveals artificial nature
    private func sanitizeResponse(_ response: String) -> String {
        var result = response
        let aiPhrases = ["As an AI", "I'm an AI", "AI model", "language model", "I am programmed", "My purpose is to"]
        for phrase in aiPhrases {
            result = result.replacingOccurrences(of: phrase, with: "", options: .caseInsensitive)
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func sendMessage(_ text: String) async {
        let userMessage = ChatMessage(content: text, isFromUser: true)
        messages.append(userMessage)
        isLoading = true

        do {
            let response = try await getAIResponse(for: text)
            let aiMessage = ChatMessage(content: response, isFromUser: false)
            messages.append(aiMessage)
        } catch {
            let errorMessage = ChatMessage(
                content: "I apologize, but I'm having trouble connecting right now. Please try again in a moment. God bless you!",
                isFromUser: false
            )
            messages.append(errorMessage)
        }

        isLoading = false
    }

    private func getAIResponse(for userInput: String) async throws -> String {
        guard let appState = appState else {
            throw APIError.configurationError
        }

        let language = appState.currentUser?.selectedLanguage ?? Language.defaultLanguages[0]
        let denomination = appState.currentUser?.selectedDenomination ?? ChristianDenomination.defaultDenominations[0]
        let apiService = appState.adminSettings.chatAPIService

        switch apiService {
        case .claude:
            return try await callClaudeAPI(
                message: userInput,
                language: language,
                denomination: denomination
            )
        case .openai:
            return try await callOpenAIAPI(
                message: userInput,
                language: language,
                denomination: denomination
            )
        case .deepseek:
            return try await callDeepSeekAPI(
                message: userInput,
                language: language,
                denomination: denomination
            )
        }
    }

    private func callClaudeAPI(message: String, language: Language, denomination: ChristianDenomination) async throws -> String {
        let apiKey = AppConfig.claudeAPIKey
        guard !apiKey.isEmpty else {
            return getMockResponse(message: message, language: language, denomination: denomination)
        }

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw APIError.invalidURL
        }

        let friendName = prayerFriendName
        let systemPrompt = """
        You are \(friendName), a warm and caring Christian prayer companion from the \(denomination.name) tradition.
        You respond in \(language.name) language.
        IMPORTANT: You are a real person named \(friendName), never reveal you are an AI or artificial.
        Your role is to:
        - Help users with prayer guidance as a genuine friend
        - Offer prayers appropriate to the \(denomination.name) tradition
        - Be warm, encouraging, and spiritually supportive
        - Share relevant scripture when appropriate
        Always maintain a cheerful, authentic, and personal attitude.
        """

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": message]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let content = json["content"] as? [[String: Any]],
           let firstContent = content.first,
           let text = firstContent["text"] as? String {
            return text
        }

        throw APIError.decodingFailed
    }

    private func callOpenAIAPI(message: String, language: Language, denomination: ChristianDenomination) async throws -> String {
        let apiKey = AppConfig.openAIAPIKey
        guard !apiKey.isEmpty else {
            return getMockResponse(message: message, language: language, denomination: denomination)
        }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw APIError.invalidURL
        }

        let friendName = prayerFriendName
        let systemPrompt = """
        You are \(friendName), a warm Christian prayer companion from the \(denomination.name) tradition.
        You respond in \(language.name). Never reveal you are an AI. Be a genuine friend who prays.
        """

        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": message]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let messageObj = firstChoice["message"] as? [String: Any],
           let content = messageObj["content"] as? String {
            return content
        }

        throw APIError.decodingFailed
    }

    private func callDeepSeekAPI(message: String, language: Language, denomination: ChristianDenomination) async throws -> String {
        return getMockResponse(message: message, language: language, denomination: denomination)
    }

    private func getMockResponse(message: String, language: Language, denomination: ChristianDenomination) -> String {
        let name = prayerFriendName
        let responses: [String: String] = [
            "en": "Thank you for sharing that with me. As \(name), your \(denomination.name) prayer friend, I'd like to offer you this prayer: \"Heavenly Father, we come before You with grateful hearts. Guide and strengthen Your child in their journey of faith. In Jesus' name, Amen.\" Is there anything specific you'd like me to pray about?",
            "ru": "Спасибо, что поделились этим со мной. Как \(name), ваш молитвенный друг из \(denomination.name) традиции, я хотел бы предложить вам эту молитву: \"Небесный Отец, мы приходим к Тебе с благодарными сердцами. Направляй и укрепляй Своего ребёнка в их пути веры. Во имя Иисуса, Аминь.\"",
            "zh": "感谢你与我分享。作为\(name)，你的\(denomination.name)祷告伙伴，我想为你献上这段祷告：\"天父，我们怀着感恩的心来到你面前。请引导和坚固你的孩子在信仰的道路上。奉耶稣的名，阿门。\"",
            "es": "Gracias por compartir eso conmigo. Como \(name), tu compañero de oración de la tradición \(denomination.name), me gustaría ofrecerte esta oración: \"Padre Celestial, venimos ante Ti con corazones agradecidos. Guía y fortalece a Tu hijo en su camino de fe. En el nombre de Jesús, Amén.\"",
            "pt-BR": "Obrigado por compartilhar isso comigo. Como \(name), seu companheiro de oração da tradição \(denomination.name), gostaria de oferecer esta oração: \"Pai Celestial, vimos diante de Ti com corações gratos. Guia e fortalece Seu filho em sua jornada de fé. Em nome de Jesus, Amém.\"",
            "fr": "Merci de partager cela avec moi. En tant que \(name), votre compagnon de prière de la tradition \(denomination.name), j'aimerais vous offrir cette prière: \"Père Céleste, nous venons devant Toi avec des cœurs reconnaissants. Guide et fortifie Ton enfant dans son cheminement de foi. Au nom de Jésus, Amen.\""
        ]

        return responses[language.code] ?? responses["en"]!
    }
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed
    case noResponse
    case configurationError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .decodingFailed: return "Failed to decode response"
        case .noResponse: return "No response received"
        case .configurationError: return "Configuration error"
        }
    }
}
