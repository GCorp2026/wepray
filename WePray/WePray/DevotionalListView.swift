//
//  DevotionalListView.swift
//  WePray - Daily Devotionals List View
//

import SwiftUI

struct DevotionalListView: View {
    @StateObject private var viewModel = DevotionalViewModel()
    @State private var selectedDevotional: DailyDevotional?
    @State private var showingDetail = false
    @State private var showingPlans = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Today's Devotional Card
                        todaysDevotionalCard

                        // Reading Plan Progress
                        if let activePlan = viewModel.activePlan {
                            activePlanCard(activePlan)
                        }

                        // Stats Row
                        statsRow

                        // Category Filter
                        categoryFilter

                        // Devotionals List
                        devotionalsList
                    }
                    .padding()
                }
            }
            .navigationTitle("Devotionals")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search devotionals...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingPlans = true } label: {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingDetail) {
                if let devotional = selectedDevotional {
                    DevotionalDetailView(viewModel: viewModel, devotional: devotional)
                }
            }
            .sheet(isPresented: $showingPlans) {
                ReadingPlanView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Today's Devotional Card
    private var todaysDevotionalCard: some View {
        Group {
            if let devotional = viewModel.todaysDevotional {
                Button {
                    selectedDevotional = devotional
                    showingDetail = true
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sun.horizon.fill")
                                .foregroundColor(.orange)
                            Text("Today's Devotional")
                                .font(.caption)
                                .foregroundColor(AppColors.subtext)
                            Spacer()
                            if devotional.isRead {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }

                        Text(devotional.title)
                            .font(.title3.bold())
                            .foregroundColor(AppColors.text)

                        Text(devotional.scripture.reference)
                            .font(.subheadline)
                            .foregroundColor(devotional.category.color)

                        Text(devotional.reflection.prefix(100) + "...")
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)
                            .lineLimit(2)

                        HStack {
                            Label(devotional.category.rawValue, systemImage: devotional.category.icon)
                                .font(.caption2)
                                .foregroundColor(devotional.category.color)
                            Spacer()
                            Text("Read now")
                                .font(.caption.bold())
                                .foregroundColor(AppColors.accent)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [devotional.category.color.opacity(0.2), AppColors.cardBackground],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                noDevotionalCard
            }
        }
    }

    private var noDevotionalCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundColor(AppColors.subtext)
            Text("No devotional for today")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text("Check back tomorrow for new content")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Active Plan Card
    private func activePlanCard(_ plan: ReadingPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: plan.category.icon)
                    .foregroundColor(plan.category.color)
                Text("Reading Plan")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                Spacer()
                Text("Day \(plan.currentDay)/\(plan.duration)")
                    .font(.caption.bold())
                    .foregroundColor(AppColors.accent)
            }

            Text(plan.title)
                .font(.headline)
                .foregroundColor(AppColors.text)

            ProgressView(value: plan.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: plan.category.color))

            if let reading = viewModel.getTodaysReading(for: plan) {
                HStack {
                    Text(reading.title)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                    Spacer()
                    Button {
                        viewModel.completeReading(plan, day: reading.day)
                    } label: {
                        Text(reading.isCompleted ? "Completed" : "Mark Done")
                            .font(.caption.bold())
                            .foregroundColor(reading.isCompleted ? .green : AppColors.accent)
                    }
                    .disabled(reading.isCompleted)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 16) {
            DevotionalStatBadge(value: "\(viewModel.progress.totalRead)", label: "Read", icon: "book.fill")
            DevotionalStatBadge(value: "\(viewModel.progress.currentStreak)", label: "Streak", icon: "flame.fill")
            DevotionalStatBadge(value: "\(viewModel.progress.notesWritten)", label: "Notes", icon: "note.text")
            DevotionalStatBadge(value: "\(viewModel.favoriteDevotionals.count)", label: "Saved", icon: "heart.fill")
        }
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                DevotionalCategoryChip(category: nil, isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(DevotionalCategory.allCases, id: \.self) { category in
                    DevotionalCategoryChip(category: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Devotionals List
    private var devotionalsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Devotionals")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.filteredDevotionals.count) devotionals")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredDevotionals) { devotional in
                    DevotionalRowCard(devotional: devotional) {
                        selectedDevotional = devotional
                        showingDetail = true
                    } onFavorite: {
                        viewModel.toggleFavorite(devotional)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Badge
struct DevotionalStatBadge: View {
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
struct DevotionalCategoryChip: View {
    let category: DevotionalCategory?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let cat = category {
                    Image(systemName: cat.icon).font(.caption)
                    Text(cat.rawValue)
                } else {
                    Image(systemName: "square.grid.2x2").font(.caption)
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

// MARK: - Devotional Row Card
struct DevotionalRowCard: View {
    let devotional: DailyDevotional
    let onTap: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Circle()
                    .fill(devotional.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: devotional.category.icon).foregroundColor(devotional.category.color))

                VStack(alignment: .leading, spacing: 4) {
                    Text(devotional.title)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text(devotional.scripture.reference)
                        .font(.caption)
                        .foregroundColor(devotional.category.color)
                    Text(devotional.formattedDate)
                        .font(.caption2)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                VStack(spacing: 8) {
                    Button { onFavorite() } label: {
                        Image(systemName: devotional.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(devotional.isFavorite ? .red : AppColors.subtext)
                    }
                    if devotional.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
