//
//  PrayerChatViewModel.swift
//  WePray - Prayer Tutoring App
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
        switch language.lowercased() {
        case "russian":
            return "Благословения вам! Я ваш помощник по молитве из \(denomination) традиции. Как я могу помочь вам сегодня в молитве?"
        case "chinese":
            return "愿上帝保佑你！我是你的\(denomination)祷告导师。今天我能如何帮助你祷告？"
        case "spanish":
            return "Bendiciones! Soy tu tutor de oracion de la tradicion \(denomination). Como puedo ayudarte hoy con tu oracion?"
        case "brazilian portuguese":
            return "Bencaos! Sou seu tutor de oracao da tradicao \(denomination). Como posso ajuda-lo hoje com sua oracao?"
        case "french":
            return "Benedictions! Je suis votre tuteur de priere de la tradition \(denomination). Comment puis-je vous aider aujourd'hui dans votre priere?"
        default:
            return "Blessings to you! I'm your \(denomination) prayer tutor. How can I help you with your prayer life today? Feel free to ask for guidance, request prayers, or discuss your spiritual journey."
        }
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

        let systemPrompt = """
        You are a cheerful and helpful Christian prayer tutor from the \(denomination.name) tradition.
        You respond in \(language.name) language.
        Your role is to:
        - Help users with prayer guidance
        - Offer prayers appropriate to the \(denomination.name) tradition
        - Be warm, encouraging, and spiritually supportive
        - Share relevant scripture when appropriate
        Always maintain a cheerful and helpful attitude.
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

        let systemPrompt = """
        You are a cheerful and helpful Christian prayer tutor from the \(denomination.name) tradition.
        You respond in \(language.name) language.
        Help users with prayer guidance and offer appropriate prayers.
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
        let responses: [String: String] = [
            "en": "Thank you for sharing that with me. As your \(denomination.name) prayer tutor, I'd like to offer you this prayer: \"Heavenly Father, we come before You with grateful hearts. Guide and strengthen Your child in their journey of faith. In Jesus' name, Amen.\" Is there anything specific you'd like me to pray about?",
            "ru": "Спасибо, что поделились этим со мной. Как ваш наставник по молитве из \(denomination.name) традиции, я хотел бы предложить вам эту молитву: \"Небесный Отец, мы приходим к Тебе с благодарными сердцами. Направляй и укрепляй Своего ребёнка в их пути веры. Во имя Иисуса, Аминь.\"",
            "zh": "感谢你与我分享。作为你的\(denomination.name)祷告导师，我想为你献上这段祷告：\"天父，我们怀着感恩的心来到你面前。请引导和坚固你的孩子在信仰的道路上。奉耶稣的名，阿门。\"",
            "es": "Gracias por compartir eso conmigo. Como tu tutor de oracion de la tradicion \(denomination.name), me gustaria ofrecerte esta oracion: \"Padre Celestial, venimos ante Ti con corazones agradecidos. Guia y fortalece a Tu hijo en su camino de fe. En el nombre de Jesus, Amen.\"",
            "pt-BR": "Obrigado por compartilhar isso comigo. Como seu tutor de oracao da tradicao \(denomination.name), gostaria de oferecer esta oracao: \"Pai Celestial, vimos diante de Ti com coracoes gratos. Guia e fortalece Seu filho em sua jornada de fe. Em nome de Jesus, Amem.\"",
            "fr": "Merci de partager cela avec moi. En tant que votre tuteur de priere de la tradition \(denomination.name), j'aimerais vous offrir cette priere: \"Pere Celeste, nous venons devant Toi avec des coeurs reconnaissants. Guide et fortifie Ton enfant dans son cheminement de foi. Au nom de Jesus, Amen.\""
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
