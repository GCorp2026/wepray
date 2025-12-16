//
//  GrowthTrackingView.swift
//  WePray - Prayer Journal Growth Tracking
//

import SwiftUI
import Charts

struct GrowthTrackingView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeframe = 0

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Summary Stats
                        summarySection

                        // Growth Chart
                        chartSection

                        // Mood Distribution
                        moodDistributionSection

                        // Monthly Activity
                        monthlyActivitySection

                        // Achievement Badges
                        achievementsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Growth Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SummaryCard(icon: "book.fill", value: "\(viewModel.stats.totalEntries)", label: "Total Entries", color: .blue)
                SummaryCard(icon: "flame.fill", value: "\(viewModel.stats.currentStreak)", label: "Current Streak", color: .orange)
            }
            HStack(spacing: 16) {
                SummaryCard(icon: "trophy.fill", value: "\(viewModel.stats.longestStreak)", label: "Best Streak", color: .yellow)
                SummaryCard(icon: "star.fill", value: String(format: "%.1f", viewModel.stats.averageRating), label: "Avg Rating", color: .purple)
            }
        }
    }

    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Growth Over Time")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("Week").tag(0)
                    Text("Month").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }

            if #available(iOS 16.0, *) {
                growthChart
            } else {
                legacyChart
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    @available(iOS 16.0, *)
    private var growthChart: some View {
        let data = selectedTimeframe == 0 ? viewModel.getWeeklyGrowthData() : viewModel.getMonthlyGrowthData().map { (Date(), $0.rating) }

        return Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                LineMark(
                    x: .value("Day", index),
                    y: .value("Rating", item.1)
                )
                .foregroundStyle(AppColors.accent)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Day", index),
                    y: .value("Rating", item.1)
                )
                .foregroundStyle(LinearGradient(colors: [AppColors.accent.opacity(0.3), AppColors.accent.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                .interpolationMethod(.catmullRom)
            }
        }
        .frame(height: 200)
        .chartYScale(domain: 0...5)
    }

    private var legacyChart: some View {
        let data = viewModel.getWeeklyGrowthData()
        let maxRating = 5.0

        return VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.accent)
                            .frame(height: CGFloat(item.1 / maxRating) * 150)
                    }
                }
            }
            .frame(height: 160)

            HStack(spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    Text(dayLabel(for: item.0))
                        .font(.caption2)
                        .foregroundColor(AppColors.subtext)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    // MARK: - Mood Distribution
    private var moodDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Distribution")
                .font(.headline)
                .foregroundColor(AppColors.text)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(JournalMood.allCases, id: \.self) { mood in
                    let count = viewModel.stats.entriesByMood[mood.rawValue] ?? 0
                    MoodStatCard(mood: mood, count: count, total: viewModel.stats.totalEntries)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Monthly Activity
    private var monthlyActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Activity")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 8) {
                ForEach(viewModel.getMonthlyGrowthData(), id: \.month) { item in
                    VStack(spacing: 4) {
                        Text(item.month)
                            .font(.caption2)
                            .foregroundColor(AppColors.subtext)
                        ZStack {
                            Circle()
                                .stroke(AppColors.border, lineWidth: 3)
                            Circle()
                                .trim(from: 0, to: item.rating / 5)
                                .stroke(AppColors.accent, lineWidth: 3)
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 40, height: 40)
                        Text(String(format: "%.1f", item.rating))
                            .font(.caption2.bold())
                            .foregroundColor(AppColors.text)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(AppColors.text)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                AchievementBadge(icon: "pencil.circle.fill", title: "First Entry", isUnlocked: viewModel.stats.totalEntries >= 1)
                AchievementBadge(icon: "flame.circle.fill", title: "7 Day Streak", isUnlocked: viewModel.stats.longestStreak >= 7)
                AchievementBadge(icon: "star.circle.fill", title: "30 Entries", isUnlocked: viewModel.stats.totalEntries >= 30)
                AchievementBadge(icon: "crown.fill", title: "30 Day Streak", isUnlocked: viewModel.stats.longestStreak >= 30)
                AchievementBadge(icon: "heart.circle.fill", title: "100 Entries", isUnlocked: viewModel.stats.totalEntries >= 100)
                AchievementBadge(icon: "bolt.circle.fill", title: "Consistent", isUnlocked: viewModel.stats.averageRating >= 4.0)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title.bold())
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Mood Stat Card
struct MoodStatCard: View {
    let mood: JournalMood
    let count: Int
    let total: Int

    var percentage: Double { total > 0 ? Double(count) / Double(total) * 100 : 0 }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(mood.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: mood.icon).foregroundColor(mood.color))

            VStack(alignment: .leading, spacing: 2) {
                Text(mood.rawValue)
                    .font(.subheadline)
                    .foregroundColor(AppColors.text)
                Text("\(count) (\(String(format: "%.0f", percentage))%)")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()
        }
        .padding(8)
        .background(AppColors.background)
        .cornerRadius(8)
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let icon: String
    let title: String
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(isUnlocked ? .yellow : AppColors.border)
            Text(title)
                .font(.caption2)
                .foregroundColor(isUnlocked ? AppColors.text : AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isUnlocked ? Color.yellow.opacity(0.1) : AppColors.background)
        .cornerRadius(12)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}
