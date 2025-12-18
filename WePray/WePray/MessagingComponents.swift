//
//  MessagingComponents.swift
//  WePray - Messaging UI Components
//

import SwiftUI

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation
    let currentUserId: String

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let other = conversation.otherParticipant(currentUserId: currentUserId) {
                ZStack {
                    Circle()
                        .fill(other.userRole.badgeColorValue)
                        .frame(width: 50, height: 50)

                    Text(other.userInitials)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .fill(conversation.unreadCount > 0 ? AppColors.accent : Color.clear)
                        .frame(width: 14, height: 14)
                        .offset(x: 18, y: -18)
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let other = conversation.otherParticipant(currentUserId: currentUserId) {
                        Text(other.userName)
                            .font(.headline)
                            .foregroundColor(AppColors.text)

                        RoleBadgeView(role: other.userRole, style: .compact)
                    }

                    Spacer()

                    Text(conversation.lastMessageAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                if let lastMessage = conversation.lastMessage {
                    HStack(spacing: 4) {
                        if lastMessage.messageType == .prayer {
                            Image(systemName: "hands.sparkles.fill")
                                .font(.caption)
                                .foregroundColor(AppColors.primary)
                        }

                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(conversation.unreadCount > 0 ? AppColors.text : AppColors.subtext)
                            .fontWeight(conversation.unreadCount > 0 ? .medium : .regular)
                            .lineLimit(1)
                    }
                }
            }

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accent)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if message.messageType == .prayer {
                    HStack(spacing: 4) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.caption)
                        Text("Prayer")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(isFromCurrentUser ? .white.opacity(0.8) : AppColors.primary)
                }

                Text(message.content)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : AppColors.text)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(isFromCurrentUser ? .white.opacity(0.7) : AppColors.subtext)
            }
            .padding(12)
            .background(
                isFromCurrentUser
                    ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [AppColors.cardBackground, AppColors.cardBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16, corners: isFromCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Message Input Bar
struct MessageInputBar: View {
    @Binding var messageText: String
    @Binding var isPrayer: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                // Prayer Toggle
                Button {
                    isPrayer.toggle()
                } label: {
                    Image(systemName: isPrayer ? "hands.sparkles.fill" : "hands.sparkles")
                        .font(.title3)
                        .foregroundColor(isPrayer ? AppColors.primary : AppColors.subtext)
                }

                // Text Field
                TextField(isPrayer ? "Share a prayer..." : "Type a message...", text: $messageText)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppColors.cardBackground)
                    .cornerRadius(20)

                // Send Button
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            messageText.isEmpty
                                ? Color.gray
                                : AppColors.primary
                        )
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(AppColors.background)
        }
    }
}

// MARK: - Empty Conversations View
struct EmptyConversationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext.opacity(0.5))

            Text("No Messages Yet")
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            Text("Start a conversation by connecting\nwith other believers!")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Conversation Filter Chips
struct ConversationFilterChips: View {
    @Binding var selectedFilter: ConversationFilter
    let unreadCount: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(ConversationFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: filter.icon)
                            .font(.caption)
                        Text(filter.rawValue)
                            .font(.subheadline)
                        if filter == .unread && unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        selectedFilter == filter
                            ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [AppColors.cardBackground, AppColors.cardBackground], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(selectedFilter == filter ? .white : AppColors.text)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedFilter == filter ? Color.clear : AppColors.border, lineWidth: 1)
                    )
                }
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
