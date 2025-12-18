import SwiftUI

struct ScriptureMemoryView: View {
    @StateObject private var viewModel = ScriptureMemoryViewModel()
    @State private var showingAddVerse = false
    @State private var showingPractice = false
    @State private var selectedPracticeMode: PracticeMode = .flashcard
    @State private var selectedVerse: MemoryVerse?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        progressCard

                        if !viewModel.versesForReview.isEmpty {
                            reviewSection
                        }

                        practiceModeSection
                        categoryFilter
                        versesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Scripture Memory")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search verses...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddVerse = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddVerse) {
                AddVerseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingPractice) {
                practiceSheet
            }
            .sheet(item: $selectedVerse) { verse in
                VerseDetailView(verse: verse, viewModel: viewModel)
            }
        }
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text("\(viewModel.progress.versesMemorized) of \(viewModel.progress.totalVerses) verses mastered")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                }
                Spacer()

                if viewModel.progress.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(viewModel.progress.currentStreak)")
                            .font(.headline)
                            .foregroundColor(AppColors.text)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(12)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColors.border)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack(spacing: 16) {
                MemoryStatBadge(icon: "checkmark.circle.fill", value: "\(viewModel.progress.totalCorrect)", label: "Correct", color: .green)
                MemoryStatBadge(icon: "arrow.clockwise", value: "\(viewModel.progress.totalReviews)", label: "Reviews", color: AppColors.accent)
                MemoryStatBadge(icon: "percent", value: viewModel.progress.formattedAccuracy, label: "Accuracy", color: AppColors.primaryLight)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [AppColors.cardBackground, AppColors.primary.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    private var progressPercentage: CGFloat {
        guard viewModel.progress.totalVerses > 0 else { return 0 }
        return CGFloat(viewModel.progress.versesMemorized) / CGFloat(viewModel.progress.totalVerses)
    }

    // MARK: - Review Section

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(.orange)
                Text("Due for Review")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.versesForReview.count) verses")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.versesForReview.prefix(5)) { verse in
                        ReviewVerseCard(verse: verse) { selectedVerse = verse }
                    }

                    if viewModel.versesForReview.count > 5 {
                        Button(action: { startPractice(mode: .flashcard) }) {
                            VStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title)
                                    .foregroundColor(AppColors.accent)
                                Text("See All")
                                    .font(.caption)
                                    .foregroundColor(AppColors.subtext)
                            }
                            .frame(width: 100, height: 120)
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                }
            }

            Button(action: { startPractice(mode: .flashcard) }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Review Session")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Practice Mode Section

    private var practiceModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice Modes")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 12) {
                ForEach(PracticeMode.allCases, id: \.self) { mode in
                    PracticeModeCard(mode: mode) { startPractice(mode: mode) }
                }
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    MemoryCategoryChip(title: "All", icon: "square.grid.2x2", isSelected: viewModel.selectedCategory == nil, color: AppColors.accent) {
                        viewModel.selectedCategory = nil
                    }

                    ForEach(VerseCategory.allCases, id: \.self) { category in
                        MemoryCategoryChip(title: category.rawValue, icon: category.icon, isSelected: viewModel.selectedCategory == category, color: category.color) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    // MARK: - Verses Section

    private var versesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Verses")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(viewModel.filteredVerses.count) verses")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }

            if viewModel.filteredVerses.isEmpty {
                emptyVersesView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredVerses) { verse in
                        VerseCard(verse: verse, viewModel: viewModel) { selectedVerse = verse }
                    }
                }
            }
        }
    }

    private var emptyVersesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(AppColors.subtext)
            Text("No verses yet")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text("Add your first verse to start memorizing Scripture")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)

            Button(action: { showingAddVerse = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Verse")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Practice Sheet

    @ViewBuilder
    private var practiceSheet: some View {
        switch selectedPracticeMode {
        case .flashcard:
            FlashcardPracticeView(viewModel: viewModel)
        case .typeVerse:
            TypeVersePracticeView(viewModel: viewModel)
        case .fillBlank:
            FillBlanksPracticeView(viewModel: viewModel)
        case .listening:
            ScriptureListeningPracticeView(viewModel: viewModel)
        }
    }

    private func startPractice(mode: PracticeMode) {
        selectedPracticeMode = mode
        viewModel.currentPracticeMode = mode
        showingPractice = true
    }
}

#Preview {
    ScriptureMemoryView()
}
