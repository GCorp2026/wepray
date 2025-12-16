//
//  PrayerChatView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct PrayerChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = PrayerChatViewModel()
    @State private var messageText = ""
    @State private var showLanguagePicker = false
    @State private var showDenominationPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                selectionBar
                messagesScrollView
                inputBar
            }
            .navigationTitle("Prayer Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
            }
        }
        .onAppear {
            viewModel.configure(appState: appState)
        }
    }

    private var selectionBar: some View {
        HStack(spacing: 12) {
            languageDropdown
            denominationDropdown
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppColors.cardBackground)
    }

    private var languageDropdown: some View {
        Menu {
            ForEach(appState.languages.sorted { $0.name < $1.name }) { language in
                Button(action: {
                    appState.currentUser?.selectedLanguage = language
                    appState.saveUser()
                }) {
                    HStack {
                        Text(language.flag)
                        Text(language.name)
                        if appState.currentUser?.selectedLanguage == language {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(appState.currentUser?.selectedLanguage.flag ?? "")
                Text(appState.currentUser?.selectedLanguage.name ?? "Language")
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.background)
            .cornerRadius(8)
        }
        .foregroundColor(AppColors.text)
    }

    private var denominationDropdown: some View {
        Menu {
            ForEach(appState.denominations.sorted { $0.name < $1.name }) { denom in
                Button(action: {
                    appState.currentUser?.selectedDenomination = denom
                    appState.saveUser()
                }) {
                    HStack {
                        Text(denom.name)
                        if appState.currentUser?.selectedDenomination == denom {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "cross.fill")
                    .font(.caption)
                Text(appState.currentUser?.selectedDenomination.name ?? "Denomination")
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.background)
            .cornerRadius(8)
        }
        .foregroundColor(AppColors.text)
    }

    private var messagesScrollView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatMessageBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isLoading {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation {
                    scrollProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
        .background(AppColors.background)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask for prayer guidance...", text: $messageText)
                .padding(12)
                .background(AppColors.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.border, lineWidth: 1)
                )

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(messageText.isEmpty ? AppColors.subtext : AppColors.primary)
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(AppColors.cardBackground)
    }

    private var settingsButton: some View {
        NavigationLink(destination: ChatSettingsView()) {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(AppColors.primary)
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let text = messageText
        messageText = ""
        Task {
            await viewModel.sendMessage(text)
        }
    }
}

// MARK: - Chat Message Bubble
struct ChatMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 60) }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isFromUser ? AppColors.primary : AppColors.cardBackground)
                    .foregroundColor(message.isFromUser ? .white : AppColors.text)
                    .cornerRadius(16)

                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(AppColors.subtext)
            }

            if !message.isFromUser { Spacer(minLength: 60) }
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(AppColors.subtext)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset == index ? -4 : 0)
                }
            }
            .padding(12)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                animationOffset = (animationOffset + 1) % 3
            }
        }
    }
}

// MARK: - Chat Settings View
struct ChatSettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section("Add Custom Language") {
                AddCustomLanguageView()
            }

            Section("Add Custom Denomination") {
                AddCustomDenominationView()
            }
        }
        .navigationTitle("Chat Settings")
    }
}

#Preview {
    PrayerChatView()
        .environmentObject(AppState())
}
