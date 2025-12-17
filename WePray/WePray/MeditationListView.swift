//
//  MeditationListView.swift
//  WePray - Guided Meditation Session List
//

import SwiftUI

struct MeditationListView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @State private var selectedSession: MeditationSession?
    @State private var showingPlayer = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Progress Card
                        progressCard

                        // Category Filter
                        categoryFilter

                        // Featured/Recent Section
                        if !viewModel.recentSessions.isEmpty {
                            recentSection
                        }

                        // All Sessions
                        sessionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Meditate")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search meditations...")
            .sheet(isPresented: $showingPlayer) {
                if let session = selectedSession {
                    MeditationPlayerView(viewModel: viewModel, session: session)
                }
            }
        }
    }

    // MARK: - Progress Card
    private var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Goal")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                    Text("\(viewModel.progress.weeklyProgress)/\(viewModel.progress.weeklyGoal) min")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.text)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text(viewModel.progress.streakStatus)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.border)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [AppColors.accent, AppColors.primary], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * viewModel.progressPercentage, height: 12)
                }
            }
            .frame(height: 12)

            HStack(spacing: 20) {
                MeditationStatBadge(value: "\(viewModel.progress.sessionsCompleted)", label: "Sessions", icon: "checkmark.circle.fill")
                MeditationStatBadge(value: "\(viewModel.progress.totalMinutes)", label: "Minutes", icon: "clock.fill")
                MeditationStatBadge(value: "\(viewModel.progress.longestStreak)", label: "Best Streak", icon: "trophy.fill")
            }
        }
        .padding()
        .background(LinearGradient(colors: [AppColors.primary.opacity(0.2), AppColors.cardBackground], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                MeditationCategoryChip(category: nil, isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(MeditationCategory.allCases, id: \.self) { category in
                    MeditationCategoryChip(category: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Recent Section
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Continue")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentSessions) { session in
                        RecentSessionCard(session: session) {
                            selectedSession = session
                            showingPlayer = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sessions Section
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Sessions")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.filteredSessions.count) sessions")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredSessions) { session in
                    MeditationSessionCard(session: session, isFavorite: session.isFavorite) {
                        selectedSession = session
                        showingPlayer = true
                    } onFavorite: {
                        viewModel.toggleFavorite(session)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Badge
struct MeditationStatBadge: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppColors.accent)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Category Chip
struct MeditationCategoryChip: View {
    let category: MeditationCategory?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let cat = category {
                    Image(systemName: cat.icon)
                        .font(.caption)
                    Text(cat.rawValue)
                } else {
                    Image(systemName: "square.grid.2x2")
                        .font(.caption)
                    Text("All")
                }
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : AppColors.text)
            .background(isSelected ? (category?.color ?? AppColors.accent) : AppColors.cardBackground)
            .cornerRadius(16)
        }
    }
}

// MARK: - Recent Session Card
struct RecentSessionCard: View {
    let session: MeditationSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: session.iconName)
                    .font(.title2)
                    .foregroundColor(session.category.color)

                Text(session.title)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)

                Text(session.formattedDuration)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
            .padding()
            .frame(width: 140)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Session Card
struct MeditationSessionCard: View {
    let session: MeditationSession
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Circle()
                    .fill(session.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: session.iconName).foregroundColor(session.category.color))

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text(session.description)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        Label(session.formattedDuration, systemImage: "clock")
                        Label(session.difficulty.rawValue, systemImage: "chart.bar")
                    }
                    .font(.caption2)
                    .foregroundColor(AppColors.subtext)
                }

                Spacer()

                VStack(spacing: 8) {
                    Button { onFavorite() } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : AppColors.subtext)
                    }
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.accent)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
