//
//  MeditationViewModel.swift
//  WePray - Guided Meditation Session Management
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

// MARK: - Meditation View Model
@MainActor
class MeditationViewModel: ObservableObject {
    @Published var sessions: [MeditationSession] = []
    @Published var progress: MeditationProgress = MeditationProgress()
    @Published var playerState: PlayerState = .idle
    @Published var currentSession: MeditationSession?
    @Published var elapsedTime: TimeInterval = 0
    @Published var selectedCategory: MeditationCategory?
    @Published var searchText = ""

    private let sessionsKey = "meditation_sessions"
    private let progressKey = "meditation_progress"
    private var timer: Timer?
    private var speechSynthesizer = AVSpeechSynthesizer()

    init() {
        loadData()
    }

    // MARK: - Filtered Sessions
    var filteredSessions: [MeditationSession] {
        var result = sessions

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }

        return result
    }

    var favoriteSessions: [MeditationSession] {
        sessions.filter { $0.isFavorite }
    }

    var recentSessions: [MeditationSession] {
        sessions.filter { $0.lastCompleted != nil }
            .sorted { ($0.lastCompleted ?? .distantPast) > ($1.lastCompleted ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Session Management
    func toggleFavorite(_ session: MeditationSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].isFavorite.toggle()
            saveData()
        }
    }

    func startSession(_ session: MeditationSession) {
        currentSession = session
        elapsedTime = 0
        playerState = .playing
        startTimer()
        speakScript(session.scriptText)
    }

    func pauseSession() {
        playerState = .paused
        timer?.invalidate()
        speechSynthesizer.pauseSpeaking(at: .immediate)
    }

    func resumeSession() {
        playerState = .playing
        startTimer()
        speechSynthesizer.continueSpeaking()
    }

    func stopSession() {
        timer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
        playerState = .idle
        currentSession = nil
        elapsedTime = 0
    }

    func completeSession() {
        guard let session = currentSession else { return }

        timer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
        playerState = .completed

        // Update session stats
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].completionCount += 1
            sessions[index].lastCompleted = Date()
        }

        // Update progress
        progress.totalMinutes += session.duration
        progress.sessionsCompleted += 1
        progress.weeklyProgress += session.duration
        updateStreak()
        saveData()
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let session = self.currentSession else { return }
                self.elapsedTime += 1

                if self.elapsedTime >= Double(session.duration * 60) {
                    self.completeSession()
                }
            }
        }
    }

    // MARK: - Text-to-Speech
    private func speakScript(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45 // Slower for meditation
        utterance.pitchMultiplier = 0.9
        utterance.preUtteranceDelay = 1.0
        utterance.postUtteranceDelay = 0.5
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Progress Tracking
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = progress.lastSessionDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)

            if Calendar.current.isDate(lastDay, inSameDayAs: today) {
                // Already completed today
                return
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      Calendar.current.isDate(lastDay, inSameDayAs: yesterday) {
                progress.currentStreak += 1
            } else {
                progress.currentStreak = 1
            }
        } else {
            progress.currentStreak = 1
        }

        progress.lastSessionDate = today
        if progress.currentStreak > progress.longestStreak {
            progress.longestStreak = progress.currentStreak
        }
    }

    func resetWeeklyProgress() {
        let calendar = Calendar.current
        if let lastDate = progress.lastSessionDate {
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            if lastDate < weekStart {
                progress.weeklyProgress = 0
            }
        }
    }

    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([MeditationSession].self, from: data) {
            sessions = decoded
        } else {
            sessions = MeditationSession.defaultSessions
        }

        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(MeditationProgress.self, from: data) {
            progress = decoded
        }

        resetWeeklyProgress()
    }

    // MARK: - Helpers
    var progressPercentage: Double {
        guard progress.weeklyGoal > 0 else { return 0 }
        return min(Double(progress.weeklyProgress) / Double(progress.weeklyGoal), 1.0)
    }

    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func formattedRemainingTime(for session: MeditationSession) -> String {
        let totalSeconds = session.duration * 60
        let remaining = max(0, totalSeconds - Int(elapsedTime))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
