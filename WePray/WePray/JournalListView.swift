//
//  JournalListView.swift
//  WePray - Prayer Journal List
//

import SwiftUI

struct JournalListView: View {
    @StateObject private var viewModel = JournalViewModel()
    @StateObject private var scriptureService = ScriptureService.shared
    @State private var showingNewEntry = false
    @State private var showingGrowthStats = false
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Verse of the Day Card
                        verseOfTheDayCard

                        // Quick Stats
                        statsRow

                        // Today's Entry or Create Button
                        todaySection

                        // Journal Entries
                        entriesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingGrowthStats = true } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                JournalEntryView(viewModel: viewModel, verse: scriptureService.verseOfTheDay)
            }
            .sheet(isPresented: $showingGrowthStats) {
                GrowthTrackingView(viewModel: viewModel)
            }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryView(viewModel: viewModel, entry: entry)
            }
        }
    }

    // MARK: - Verse of the Day Card
    private var verseOfTheDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Verse of the Day")
                    .font(.caption.bold())
                    .foregroundColor(AppColors.accent)
                Spacer()
                Button { scriptureService.toggleFavorite(scriptureService.verseOfTheDay) } label: {
                    Image(systemName: scriptureService.isFavorite(scriptureService.verseOfTheDay) ? "heart.fill" : "heart")
                        .foregroundColor(scriptureService.isFavorite(scriptureService.verseOfTheDay) ? .red : AppColors.subtext)
                }
            }

            if let verse = scriptureService.verseOfTheDay {
                Text("\"\(verse.text)\"")
                    .font(.body)
                    .foregroundColor(AppColors.text)
                    .italic()

                Text("- \(verse.reference)")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding()
        .background(LinearGradient(colors: [AppColors.primary.opacity(0.3), AppColors.cardBackground], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            JournalStatCard(value: "\(viewModel.stats.totalEntries)", label: "Entries", icon: "book.fill")
            JournalStatCard(value: "\(viewModel.stats.currentStreak)", label: "Day Streak", icon: "flame.fill")
            JournalStatCard(value: String(format: "%.1f", viewModel.stats.averageRating), label: "Avg Rating", icon: "star.fill")
        }
    }

    // MARK: - Today Section
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)
                .foregroundColor(AppColors.text)

            if viewModel.hasEntryToday() {
                if let entry = viewModel.getEntry(for: Date()) {
                    TodayEntryCard(entry: entry) { selectedEntry = entry }
                }
            } else {
                Button { showingNewEntry = true } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Write Today's Reflection")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Entries Section
    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Entries")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.entries.count) total")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            if viewModel.entries.isEmpty {
                EmptyJournalView()
            } else {
                ForEach(viewModel.filteredEntries.prefix(10)) { entry in
                    JournalEntryRow(entry: entry)
                        .onTapGesture { selectedEntry = entry }
                        .contextMenu {
                            Button(role: .destructive) { viewModel.deleteEntry(entry) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Journal Stat Card
struct JournalStatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.accent)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Today Entry Card
struct TodayEntryCard: View {
    let entry: JournalEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(entry.mood.color.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: entry.mood.icon).foregroundColor(entry.mood.color))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Reflection")
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.text)
                    Text(entry.reflection.prefix(50) + (entry.reflection.count > 50 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= entry.growthRating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(i <= entry.growthRating ? .yellow : AppColors.border)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .center, spacing: 2) {
                Text(dayString)
                    .font(.title2.bold())
                    .foregroundColor(AppColors.text)
                Text(monthString)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: entry.mood.icon)
                        .foregroundColor(entry.mood.color)
                    Text(entry.mood.rawValue)
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.text)
                }
                if let verse = entry.verse {
                    Text(verse.reference)
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(i <= entry.growthRating ? AppColors.accent : AppColors.border)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: entry.date)
    }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: entry.date)
    }
}

// MARK: - Empty Journal View
struct EmptyJournalView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.subtext)
            Text("No Journal Entries Yet")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text("Start your spiritual journey by writing your first reflection")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
