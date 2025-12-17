//
//  MessagingView.swift
//  WePray - Private Messaging View
//

import SwiftUI

struct MessagingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MessagingViewModel()
    @State private var selectedConversation: Conversation?

    private var currentUserId: String {
        appState.currentUser?.id.uuidString ?? ""
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter Chips
                    ConversationFilterChips(
                        selectedFilter: $viewModel.selectedFilter,
                        unreadCount: viewModel.totalUnreadCount
                    )
                    .padding(.vertical, 12)

                    // Conversation List
                    if viewModel.filteredConversations.isEmpty {
                        EmptyConversationsView()
                            .frame(maxHeight: .infinity)
                    } else {
                        conversationList
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, prompt: "Search conversations")
            .sheet(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation, viewModel: viewModel)
                    .environmentObject(appState)
            }
        }
        .onAppear {
            viewModel.setCurrentUser(id: currentUserId)
        }
    }

    // MARK: - Conversation List
    private var conversationList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredConversations) { conversation in
                    ConversationRow(
                        conversation: conversation,
                        currentUserId: currentUserId
                    )
                    .onTapGesture {
                        selectedConversation = conversation
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteConversation(conversationId: conversation.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.refresh()
        }
    }
}

// MARK: - Chat View
struct ChatView: View {
    let conversation: Conversation
    @ObservedObject var viewModel: MessagingViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var messageText = ""
    @State private var isPrayer = false

    private var currentUserId: String {
        appState.currentUser?.id.uuidString ?? ""
    }

    private var otherParticipant: ConversationParticipant? {
        conversation.otherParticipant(currentUserId: currentUserId)
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.currentMessages) { message in
                                    MessageBubble(
                                        message: message,
                                        isFromCurrentUser: message.senderId == currentUserId
                                    )
                                    .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.currentMessages.count) { _, _ in
                            if let lastMessage = viewModel.currentMessages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    // Input Bar
                    MessageInputBar(
                        messageText: $messageText,
                        isPrayer: $isPrayer,
                        onSend: sendMessage
                    )
                }
            }
            .navigationTitle(otherParticipant?.userName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.text)
                    }
                }

                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        if let other = otherParticipant {
                            Circle()
                                .fill(other.userRole.badgeColor)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(other.userInitials)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: 0) {
                                Text(other.userName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.text)

                                Text(other.userRole.displayName)
                                    .font(.caption2)
                                    .foregroundColor(AppColors.subtext)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadMessages(for: conversation.id)
            viewModel.markAsRead(conversationId: conversation.id)
        }
        .onDisappear {
            viewModel.clearCurrentMessages()
        }
    }

    // MARK: - Send Message
    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        viewModel.sendMessage(
            conversationId: conversation.id,
            content: messageText,
            senderId: currentUserId,
            senderName: appState.currentUser?.displayName ?? "You",
            type: isPrayer ? .prayer : .text
        )

        messageText = ""
        isPrayer = false
    }
}

#Preview {
    MessagingView()
        .environmentObject(AppState())
}
