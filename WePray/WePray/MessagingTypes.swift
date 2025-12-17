//
//  MessagingTypes.swift
//  WePray - Private Messaging Types
//

import SwiftUI

// MARK: - Message Type
enum MessageType: String, CaseIterable, Codable {
    case text = "text"
    case prayer = "prayer"
    case image = "image"

    var icon: String {
        switch self {
        case .text: return "message.fill"
        case .prayer: return "hands.sparkles.fill"
        case .image: return "photo.fill"
        }
    }
}

// MARK: - Conversation Participant
struct ConversationParticipant: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let userId: String
    let userName: String
    let userInitials: String
    let userRole: UserRole

    static func == (lhs: ConversationParticipant, rhs: ConversationParticipant) -> Bool {
        lhs.userId == rhs.userId
    }
}

// MARK: - Message
struct Message: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let conversationId: UUID
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: Date
    var isRead: Bool
    let messageType: MessageType

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    static let sampleMessages: [Message] = [
        Message(conversationId: UUID(), senderId: "user1", senderName: "Sarah Mitchell", content: "Hi! I saw your prayer request. I'm praying for you!", timestamp: Date(timeIntervalSinceNow: -3600), isRead: true, messageType: .text),
        Message(conversationId: UUID(), senderId: "user2", senderName: "You", content: "Thank you so much! That means a lot.", timestamp: Date(timeIntervalSinceNow: -3000), isRead: true, messageType: .text),
        Message(conversationId: UUID(), senderId: "user1", senderName: "Sarah Mitchell", content: "Lord, we lift up this situation to You. Grant peace, wisdom, and strength. In Jesus' name, Amen.", timestamp: Date(timeIntervalSinceNow: -2400), isRead: true, messageType: .prayer),
        Message(conversationId: UUID(), senderId: "user2", senderName: "You", content: "Amen! 🙏 Thank you for that beautiful prayer.", timestamp: Date(timeIntervalSinceNow: -1800), isRead: true, messageType: .text)
    ]
}

// MARK: - Conversation
struct Conversation: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var participants: [ConversationParticipant]
    var lastMessage: Message?
    var lastMessageAt: Date
    var unreadCount: Int
    let createdAt: Date

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func otherParticipant(currentUserId: String) -> ConversationParticipant? {
        participants.first { $0.userId != currentUserId }
    }

    static let sampleConversations: [Conversation] = [
        Conversation(
            participants: [
                ConversationParticipant(userId: "user1", userName: "Sarah Mitchell", userInitials: "SM", userRole: .premium),
                ConversationParticipant(userId: "currentUser", userName: "You", userInitials: "YO", userRole: .user)
            ],
            lastMessage: Message(conversationId: UUID(), senderId: "user1", senderName: "Sarah Mitchell", content: "Praying for you today!", timestamp: Date(timeIntervalSinceNow: -1800), isRead: false, messageType: .prayer),
            lastMessageAt: Date(timeIntervalSinceNow: -1800),
            unreadCount: 1,
            createdAt: Date(timeIntervalSinceNow: -86400 * 7)
        ),
        Conversation(
            participants: [
                ConversationParticipant(userId: "user2", userName: "Pastor James", userInitials: "PJ", userRole: .admin),
                ConversationParticipant(userId: "currentUser", userName: "You", userInitials: "YO", userRole: .user)
            ],
            lastMessage: Message(conversationId: UUID(), senderId: "currentUser", senderName: "You", content: "Thank you for the advice!", timestamp: Date(timeIntervalSinceNow: -86400), isRead: true, messageType: .text),
            lastMessageAt: Date(timeIntervalSinceNow: -86400),
            unreadCount: 0,
            createdAt: Date(timeIntervalSinceNow: -86400 * 14)
        ),
        Conversation(
            participants: [
                ConversationParticipant(userId: "user3", userName: "David Chen", userInitials: "DC", userRole: .user),
                ConversationParticipant(userId: "currentUser", userName: "You", userInitials: "YO", userRole: .user)
            ],
            lastMessage: Message(conversationId: UUID(), senderId: "user3", senderName: "David Chen", content: "See you at Bible study!", timestamp: Date(timeIntervalSinceNow: -86400 * 2), isRead: true, messageType: .text),
            lastMessageAt: Date(timeIntervalSinceNow: -86400 * 2),
            unreadCount: 0,
            createdAt: Date(timeIntervalSinceNow: -86400 * 30)
        ),
        Conversation(
            participants: [
                ConversationParticipant(userId: "user4", userName: "Grace Lee", userInitials: "GL", userRole: .premium),
                ConversationParticipant(userId: "currentUser", userName: "You", userInitials: "YO", userRole: .user)
            ],
            lastMessage: Message(conversationId: UUID(), senderId: "user4", senderName: "Grace Lee", content: "Would you like to join our prayer circle?", timestamp: Date(timeIntervalSinceNow: -3600 * 5), isRead: false, messageType: .text),
            lastMessageAt: Date(timeIntervalSinceNow: -3600 * 5),
            unreadCount: 2,
            createdAt: Date(timeIntervalSinceNow: -86400 * 3)
        )
    ]
}

// MARK: - Conversation Filter
enum ConversationFilter: String, CaseIterable {
    case all = "All"
    case unread = "Unread"

    var icon: String {
        switch self {
        case .all: return "tray.fill"
        case .unread: return "envelope.badge.fill"
        }
    }
}

// MARK: - Messaging Stats
struct MessagingStats {
    var totalConversations: Int
    var unreadCount: Int

    static let empty = MessagingStats(totalConversations: 0, unreadCount: 0)
}
