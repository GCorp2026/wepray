//
//  PrayerPlanDetailView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct PrayerPlanDetailView: View {
    let plan: PrayerPlan
    @ObservedObject var viewModel: PrayerPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Progress Section
                        progressSection

                        // Calendar View
                        calendarSection

                        // Themes
                        themesSection

                        // Actions
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle(plan.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Delete Plan", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deletePlan(plan)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this prayer plan?")
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AppColors.primary, AppColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                Image(systemName: themeIcon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text(plan.description)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                StatBadge(value: "\(plan.durationDays)", label: "Days")
                StatBadge(value: "\(plan.prayersPerDay)", label: "Per Day")
                StatBadge(value: plan.frequency.rawValue, label: "Frequency")
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(Int(plan.progress * 100))%")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.accent)
            }

            ProgressView(value: plan.progress)
                .tint(AppColors.accent)
                .scaleEffect(y: 2)

            HStack {
                VStack(alignment: .leading) {
                    Text("\(plan.completedDays.count)")
                        .font(.title3.bold())
                        .foregroundColor(AppColors.text)
                    Text("Days Completed")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(viewModel.getDaysRemaining(for: plan))")
                        .font(.title3.bold())
                        .foregroundColor(AppColors.text)
                    Text("Days Remaining")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Calendar")
                .font(.headline)
                .foregroundColor(AppColors.text)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<plan.durationDays, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day, to: plan.startDate) ?? plan.startDate
                    let isCompleted = plan.completedDays.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    let isToday = Calendar.current.isDateInToday(date)
                    let isPast = date < Date()

                    Circle()
                        .fill(dayColor(isCompleted: isCompleted, isToday: isToday, isPast: isPast))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.caption2)
                                .foregroundColor(isCompleted ? .white : AppColors.subtext)
                        )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func dayColor(isCompleted: Bool, isToday: Bool, isPast: Bool) -> Color {
        if isCompleted { return AppColors.primary }
        if isToday { return AppColors.accent.opacity(0.5) }
        if isPast { return AppColors.error.opacity(0.3) }
        return AppColors.border
    }

    // MARK: - Themes Section
    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prayer Themes")
                .font(.headline)
                .foregroundColor(AppColors.text)

            FlowLayout(spacing: 8) {
                ForEach(plan.themes, id: \.self) { theme in
                    ThemeChip(theme: theme)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if viewModel.activePlan?.id != plan.id {
                Button {
                    viewModel.setActivePlan(plan)
                    dismiss()
                } label: {
                    Label("Set as Active Plan", systemImage: "star.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }

            Button(role: .destructive) { showingDeleteAlert = true } label: {
                Label("Delete Plan", systemImage: "trash")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.error.opacity(0.2))
                    .foregroundColor(AppColors.error)
                    .cornerRadius(12)
            }
        }
    }

    private var themeIcon: String {
        guard let firstTheme = plan.themes.first else { return "heart.fill" }
        switch firstTheme {
        case .gratitude: return "heart.fill"
        case .healing: return "cross.fill"
        case .forgiveness: return "hands.sparkles.fill"
        case .guidance: return "star.fill"
        case .peace: return "leaf.fill"
        case .strength: return "bolt.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .protection: return "shield.fill"
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.border.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Theme Chip
struct ThemeChip: View {
    let theme: PrayerTheme

    var body: some View {
        Text(theme.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.primary.opacity(0.3))
            .foregroundColor(AppColors.accent)
            .cornerRadius(16)
    }
}

// Note: FlowLayout moved to UIHelpers.swift
