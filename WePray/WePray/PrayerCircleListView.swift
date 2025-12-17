import SwiftUI

struct PrayerCircleListView: View {
    @StateObject private var viewModel = PrayerCircleViewModel()
    @State private var showingCreateCircle = false
    @State private var selectedCircle: PrayerCircle?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if !viewModel.circlesWithUpcomingMeetings.isEmpty {
                            upcomingMeetingsSection
                        }

                        myCirclesSection

                        categoryFilter

                        discoverSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Circles")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search circles...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateCircle = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingCreateCircle) {
                CreatePrayerCircleView(viewModel: viewModel)
            }
            .sheet(item: $selectedCircle) { circle in
                PrayerCircleDetailView(circle: circle, viewModel: viewModel)
            }
        }
    }

    // MARK: - Upcoming Meetings Section

    private var upcomingMeetingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppColors.accent)
                Text("Upcoming Meetings")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.circlesWithUpcomingMeetings) { circle in
                        if let meeting = circle.nextMeeting {
                            UpcomingMeetingCard(circle: circle, meeting: meeting) {
                                selectedCircle = circle
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - My Circles Section

    private var myCirclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Circles")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.joinedCircles.count) joined")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

            if viewModel.joinedCircles.isEmpty {
                emptyMyCirclesView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.joinedCircles) { circle in
                            MyCircleCard(circle: circle) {
                                selectedCircle = circle
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyMyCirclesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 36))
                .foregroundColor(AppColors.subtext)
            Text("No circles joined yet")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
            Text("Join a circle below or create your own")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CircleCategoryChip(title: "All", icon: "square.grid.2x2", isSelected: viewModel.selectedCategory == nil, color: AppColors.accent) {
                        viewModel.selectedCategory = nil
                    }

                    ForEach(CircleCategory.allCases, id: \.self) { category in
                        CircleCategoryChip(title: category.rawValue, icon: category.icon, isSelected: viewModel.selectedCategory == category, color: category.color) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    // MARK: - Discover Section

    private var discoverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Discover Circles")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.filteredCircles.count) available")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredCircles) { circle in
                    DiscoverCircleCard(circle: circle, viewModel: viewModel) {
                        selectedCircle = circle
                    }
                }
            }
        }
    }
}

#Preview {
    PrayerCircleListView()
}
