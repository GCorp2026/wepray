//
//  MeditationPlayerView.swift
//  WePray - Guided Meditation Player
//

import SwiftUI

struct MeditationPlayerView: View {
    @ObservedObject var viewModel: MeditationViewModel
    let session: MeditationSession
    @Environment(\.dismiss) private var dismiss
    @State private var showingScript = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [session.category.color.opacity(0.3), AppColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                headerSection

                Spacer()

                // Main Player Content
                playerContent

                Spacer()

                // Controls
                controlsSection

                // Music Indicator
                musicIndicator
            }
            .padding()
        }
        .onAppear {
            if viewModel.playerState == .idle {
                viewModel.startSession(session)
            }
        }
        .onDisappear {
            if viewModel.playerState != .completed {
                viewModel.stopSession()
            }
        }
        .sheet(isPresented: $showingScript) {
            ScriptView(session: session)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()

            VStack {
                Text(session.category.rawValue)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                Text(session.title)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }

            Spacer()

            Button { showingScript = true } label: {
                Image(systemName: "doc.text")
                    .font(.title2)
                    .foregroundColor(AppColors.subtext)
            }
        }
    }

    // MARK: - Player Content
    private var playerContent: some View {
        VStack(spacing: 24) {
            // Animated Icon
            ZStack {
                // Pulsing circles
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(session.category.color.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                        .frame(width: CGFloat(150 + index * 40), height: CGFloat(150 + index * 40))
                        .scaleEffect(viewModel.playerState == .playing ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                            value: viewModel.playerState
                        )
                }

                // Center icon
                Circle()
                    .fill(session.category.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: session.iconName)
                            .font(.system(size: 50))
                            .foregroundColor(session.category.color)
                    )
            }

            // Timer Display
            VStack(spacing: 8) {
                Text(viewModel.formattedElapsedTime)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundColor(AppColors.text)

                Text("of \(session.formattedDuration)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)

                // Progress Bar
                ProgressView(value: viewModel.elapsedTime, total: Double(session.duration * 60))
                    .progressViewStyle(LinearProgressViewStyle(tint: session.category.color))
                    .frame(width: 200)
            }

            // State Indicator
            Text(stateText)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .cornerRadius(20)
        }
    }

    private var stateText: String {
        switch viewModel.playerState {
        case .idle: return "Ready to begin"
        case .loading: return "Preparing..."
        case .playing: return "In session"
        case .paused: return "Paused"
        case .completed: return "Completed!"
        }
    }

    // MARK: - Controls Section
    private var controlsSection: some View {
        HStack(spacing: 40) {
            // Stop Button
            Button {
                viewModel.stopSession()
                dismiss()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.subtext)
                    .frame(width: 50, height: 50)
                    .background(AppColors.cardBackground)
                    .clipShape(Circle())
            }

            // Play/Pause Button
            Button {
                if viewModel.playerState == .playing {
                    viewModel.pauseSession()
                } else if viewModel.playerState == .paused {
                    viewModel.resumeSession()
                } else if viewModel.playerState == .completed {
                    dismiss()
                }
            } label: {
                Image(systemName: playButtonIcon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(session.category.color)
                    .clipShape(Circle())
                    .shadow(color: session.category.color.opacity(0.4), radius: 10)
            }

            // Complete Button
            Button {
                viewModel.completeSession()
            } label: {
                Image(systemName: "checkmark")
                    .font(.title2)
                    .foregroundColor(AppColors.accent)
                    .frame(width: 50, height: 50)
                    .background(AppColors.cardBackground)
                    .clipShape(Circle())
            }
            .disabled(viewModel.playerState == .completed)
        }
    }

    private var playButtonIcon: String {
        switch viewModel.playerState {
        case .playing: return "pause.fill"
        case .paused: return "play.fill"
        case .completed: return "checkmark"
        default: return "play.fill"
        }
    }

    // MARK: - Music Indicator
    private var musicIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: session.backgroundMusic.icon)
                .foregroundColor(AppColors.subtext)
            Text(session.backgroundMusic.rawValue)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColors.cardBackground.opacity(0.5))
        .cornerRadius(20)
    }
}

// MARK: - Script View
struct ScriptView: View {
    let session: MeditationSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: session.iconName)
                                .foregroundColor(session.category.color)
                            Text(session.title)
                                .font(.headline)
                        }

                        Divider()

                        Text(session.scriptText)
                            .font(.body)
                            .foregroundColor(AppColors.text)
                            .lineSpacing(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Script")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
