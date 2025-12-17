//
//  PrayerRequestListView.swift
//  WePray - Prayer Request Community List
//

import SwiftUI

struct PrayerRequestListView: View {
    @StateObject private var viewModel = PrayerRequestViewModel()
    @State private var showingNewRequest = false
    @State private var showingStats = false
    @State private var selectedRequest: PrayerRequest?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Prayer Warrior Stats Card
                        statsCard

                        // Filter & Sort Bar
                        filterBar

                        // Category Filter
                        categoryScroll

                        // Prayer Requests
                        requestsList
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Requests")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingStats = true } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingNewRequest = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search requests...")
            .sheet(isPresented: $showingNewRequest) {
                NewPrayerRequestView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStats) {
                PrayerWarriorStatsView(stats: viewModel.stats)
            }
            .sheet(item: $selectedRequest) { request in
                PrayerRequestDetailView(viewModel: viewModel, request: request)
            }
        }
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: viewModel.stats.prayerWarriorLevel.icon)
                    .font(.title2)
                    .foregroundColor(viewModel.stats.prayerWarriorLevel.color)
                Text(viewModel.stats.prayerWarriorLevel.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(AppColors.text)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            PrayerStatItem(value: "\(viewModel.stats.totalPrayersOffered)", label: "Prayers", icon: "hands.sparkles.fill")
            PrayerStatItem(value: "\(viewModel.stats.currentStreak)", label: "Streak", icon: "flame.fill")
            PrayerStatItem(value: "\(viewModel.stats.answeredPrayers)", label: "Answered", icon: "checkmark.circle.fill")
        }
        .padding()
        .background(LinearGradient(colors: [AppColors.primary.opacity(0.2), AppColors.cardBackground], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack {
            Menu {
                ForEach(PrayerRequestFilter.allCases, id: \.self) { filter in
                    Button { viewModel.selectedFilter = filter } label: {
                        HStack {
                            Text(filter.rawValue)
                            if viewModel.selectedFilter == filter { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(viewModel.selectedFilter.rawValue)
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .cornerRadius(8)
            }

            Spacer()

            Menu {
                ForEach(PrayerRequestSort.allCases, id: \.self) { sort in
                    Button { viewModel.selectedSort = sort } label: {
                        HStack {
                            Text(sort.rawValue)
                            if viewModel.selectedSort == sort { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(viewModel.selectedSort.rawValue)
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.cardBackground)
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Category Scroll
    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(category: nil, isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(PrayerRequestCategory.allCases, id: \.self) { category in
                    CategoryChip(category: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Requests List
    private var requestsList: some View {
        LazyVStack(spacing: 12) {
            if viewModel.filteredRequests.isEmpty {
                EmptyRequestsView()
            } else {
                ForEach(viewModel.filteredRequests) { request in
                    PrayerRequestCard(request: request, hasPrayed: viewModel.hasPrayedFor(request)) {
                        viewModel.prayForRequest(request)
                    } onTap: {
                        selectedRequest = request
                    }
                }
            }
        }
    }
}

// MARK: - Stat Item
struct PrayerStatItem: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: PrayerRequestCategory?
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

// MARK: - Prayer Request Card
struct PrayerRequestCard: View {
    let request: PrayerRequest
    let hasPrayed: Bool
    let onPray: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(request.category.color.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(Image(systemName: request.category.icon).font(.caption).foregroundColor(request.category.color))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(request.displayName)
                                .font(.subheadline.bold())
                                .foregroundColor(AppColors.text)
                            if !request.isAnonymous {
                                RoleBadgeView(role: request.authorRole, size: .small)
                            }
                        }
                        Text(request.formattedDate)
                            .font(.caption2)
                            .foregroundColor(AppColors.subtext)
                    }

                    Spacer()

                    if request.isAnswered {
                        Label("Answered", systemImage: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: request.urgency.icon)
                            Text(request.urgency.rawValue)
                        }
                        .font(.caption2)
                        .foregroundColor(request.urgency.color)
                    }
                }

                Text(request.title)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)

                Text(request.description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .lineLimit(2)

                HStack {
                    Label("\(request.prayerCount)", systemImage: "hands.sparkles")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)

                    Label("\(request.commentCount)", systemImage: "bubble.left")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)

                    Spacer()

                    Button { onPray() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: hasPrayed ? "checkmark.circle.fill" : "hands.sparkles")
                            Text(hasPrayed ? "Prayed" : "Pray")
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(hasPrayed ? Color.green : AppColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
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

// MARK: - Empty Requests View
struct EmptyRequestsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hands.sparkles")
                .font(.system(size: 48))
                .foregroundColor(AppColors.subtext)
            Text("No Prayer Requests")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text("Be the first to share a prayer request with the community")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
