//
//  MessagingViewModel.swift
//  WePray - Messaging ViewModel
//

import SwiftUI

class MessagingViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentMessages: [Message] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var selectedFilter: ConversationFilter = .all
    @Published var stats: MessagingStats = .empty

    private let conversationsKey = "WePrayConversations"
    private let messagesKey = "WePrayMessages"
    private var currentUserId: String = ""
    private var allMessages: [Message] = []

    init() {
        loadConversations()
        loadMessages()
        updateStats()
    }

    // MARK: - Load Conversations
    func loadConversations() {
        if let data = UserDefaults.standard.data(forKey: conversationsKey),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        } else {
            conversations = Conversation.sampleConversations
            saveConversations()
        }
        updateStats()
    }

    // MARK: - Save Conversations
    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: conversationsKey)
        }
    }

    // MARK: - Load Messages
    func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: messagesKey),
           let decoded = try? JSONDecoder().decode([Message].self, from: data) {
            allMessages = decoded
        } else {
            allMessages = Message.sampleMessages
            saveMessages()
        }
    }

    // MARK: - Save Messages
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(allMessages) {
            UserDefaults.standard.set(encoded, forKey: messagesKey)
        }
    }

    // MARK: - Update Stats
    private func updateStats() {
        stats = MessagingStats(
            totalConversations: conversations.count,
            unreadCount: conversations.reduce(0) { $0 + $1.unreadCount }
        )
    }

    // MARK: - Start Conversation
    func startConversation(with userId: String, userName: String, userInitials: String,
                           userRole: UserRole, currentUser: UserProfile) -> Conversation {
        // Check if conversation exists
        if let existing = conversations.first(where: {
            $0.participants.contains { $0.userId == userId }
        }) {
            return existing
        }

        // Create new conversation
        let participants = [
            ConversationParticipant(
                userId: userId,
                userName: userName,
                userInitials: userInitials,
                userRole: userRole
            ),
            ConversationParticipant(
                userId: currentUser.id.uuidString,
                userName: currentUser.displayName,
                userInitials: String(currentUser.displayName.prefix(2)).uppercased(),
                userRole: currentUser.role
            )
        ]

        let newConversation = Conversation(
            participants: participants,
            lastMessage: nil,
            lastMessageAt: Date(),
            unreadCount: 0,
            createdAt: Date()
        )

        conversations.insert(newConversation, at: 0)
        saveConversations()
        updateStats()

        return newConversation
    }

    // MARK: - Send Message
    func sendMessage(conversationId: UUID, content: String, senderId: String, senderName: String, type: MessageType = .text) {
        let message = Message(
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            content: content,
            timestamp: Date(),
            isRead: true,
            messageType: type
        )

        allMessages.append(message)
        currentMessages.append(message)

        // Update conversation
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].lastMessage = message
            conversations[index].lastMessageAt = Date()
            // Move to top
            let conv = conversations.remove(at: index)
            conversations.insert(conv, at: 0)
        }

        saveMessages()
        saveConversations()
    }

    // MARK: - Load Messages for Conversation
    func loadMessages(for conversationId: UUID) {
        currentMessages = allMessages
            .filter { $0.conversationId == conversationId }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Mark as Read
    func markAsRead(conversationId: UUID) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].unreadCount = 0
            saveConversations()
            updateStats()
        }

        // Mark messages as read
        for i in 0..<allMessages.count {
            if allMessages[i].conversationId == conversationId {
                allMessages[i].isRead = true
            }
        }
        saveMessages()
    }

    // MARK: - Delete Conversation
    func deleteConversation(conversationId: UUID) {
        conversations.removeAll { $0.id == conversationId }
        allMessages.removeAll { $0.conversationId == conversationId }
        saveConversations()
        saveMessages()
        updateStats()
    }

    // MARK: - Filtered Conversations
    var filteredConversations: [Conversation] {
        var result = conversations

        // Apply filter
        if selectedFilter == .unread {
            result = result.filter { $0.unreadCount > 0 }
        }

        // Apply search
        if !searchQuery.isEmpty {
            result = result.filter { conv in
                conv.participants.contains {
                    $0.userName.localizedCaseInsensitiveContains(searchQuery)
                }
            }
        }

        return result.sorted { $0.lastMessageAt > $1.lastMessageAt }
    }

    // MARK: - Unread Count
    var totalUnreadCount: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    // MARK: - Set Current User
    func setCurrentUser(id: String) {
        currentUserId = id
    }

    // MARK: - Refresh
    func refresh() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadConversations()
            self?.loadMessages()
            self?.isLoading = false
        }
    }

    // MARK: - Clear Messages
    func clearCurrentMessages() {
        currentMessages = []
    }
}
