//
//  VoicePrayerView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI
import AVFoundation

struct VoicePrayerView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = VoicePrayerViewModel()
    @State private var isRecording = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    selectionBar
                    conversationArea(geometry: geometry)
                    recordingControls
                }
            }
            .navigationTitle("Voice Prayer")
            .navigationBarTitleDisplayMode(.inline)
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

    private func conversationArea(geometry: GeometryProxy) -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        VoiceMessageBubble(
                            message: message,
                            onPlayAudio: { viewModel.playAudio(for: message) }
                        )
                        .id(message.id)
                    }

                    if viewModel.isProcessing {
                        ProcessingIndicator()
                            .id("processing")
                    }
                }
                .padding()
            }
            .frame(height: geometry.size.height * 0.6)
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation {
                    scrollProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
        .background(AppColors.background)
    }

    private var recordingControls: some View {
        VStack(spacing: 16) {
            if viewModel.isProcessing {
                Text("Processing your prayer request...")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            } else if isRecording {
                Text("Listening... Tap to stop")
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
            } else {
                Text("Tap to speak your prayer request")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(isRecording ? AppColors.error : AppColors.primary)
                        .frame(width: 80, height: 80)

                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .disabled(viewModel.isProcessing)

            Text("Voice prayers are delivered in your selected language")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
    }

    private func toggleRecording() {
        if isRecording {
            isRecording = false
            Task {
                await viewModel.stopRecording()
            }
        } else {
            isRecording = true
            viewModel.startRecording()
        }
    }
}

// MARK: - Voice Message Bubble
struct VoiceMessageBubble: View {
    let message: ChatMessage
    let onPlayAudio: () -> Void

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 60) }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if !message.isFromUser {
                        Button(action: onPlayAudio) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(AppColors.primary)
                        }
                    }

                    Text(message.content)
                        .padding(12)
                        .background(message.isFromUser ? AppColors.primary : AppColors.cardBackground)
                        .foregroundColor(message.isFromUser ? .white : AppColors.text)
                        .cornerRadius(16)

                    if message.isFromUser {
                        Image(systemName: "mic.fill")
                            .foregroundColor(AppColors.subtext)
                            .font(.caption)
                    }
                }

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

// MARK: - Processing Indicator
struct ProcessingIndicator: View {
    @State private var rotation: Double = 0

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "waveform")
                    .foregroundColor(AppColors.primary)
                    .rotationEffect(.degrees(rotation))
                Text("Preparing your prayer...")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }
            .padding(12)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    VoicePrayerView()
        .environmentObject(AppState())
}
