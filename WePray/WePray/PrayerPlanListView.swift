//
//  PrayerPlanListView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct PrayerPlanListView: View {
    @StateObject private var viewModel = PrayerPlanViewModel()
    @State private var showingCreateSheet = false
    @State private var showingTemplates = false
    @State private var selectedPlan: PrayerPlan?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Active Plan Card
                        if let activePlan = viewModel.activePlan {
                            ActivePlanCard(plan: activePlan, viewModel: viewModel)
                                .onTapGesture { selectedPlan = activePlan }
                        }

                        // Quick Actions
                        HStack(spacing: 12) {
                            QuickActionButton(title: "New Plan", icon: "plus.circle.fill") {
                                showingCreateSheet = true
                            }
                            QuickActionButton(title: "Templates", icon: "doc.text.fill") {
                                showingTemplates = true
                            }
                        }
                        .padding(.horizontal)

                        // My Plans Section
                        if !viewModel.prayerPlans.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("My Prayer Plans")
                                    .font(.headline)
                                    .foregroundColor(AppColors.text)
                                    .padding(.horizontal)

                                ForEach(viewModel.prayerPlans) { plan in
                                    PlanRowCard(plan: plan, isActive: viewModel.activePlan?.id == plan.id)
                                        .onTapGesture { selectedPlan = plan }
                                        .contextMenu {
                                            Button { viewModel.setActivePlan(plan) } label: {
                                                Label("Set Active", systemImage: "star.fill")
                                            }
                                            Button(role: .destructive) { viewModel.deletePlan(plan) } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        } else {
                            EmptyPlanView()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Prayer Plans")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCreateSheet) {
                PrayerPlanCreationView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingTemplates) {
                TemplatesSheet(viewModel: viewModel, isPresented: $showingTemplates)
            }
            .sheet(item: $selectedPlan) { plan in
                PrayerPlanDetailView(plan: plan, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Active Plan Card
struct ActivePlanCard: View {
    let plan: PrayerPlan
    @ObservedObject var viewModel: PrayerPlanViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Plan")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                    Text(plan.name)
                        .font(.title2.bold())
                        .foregroundColor(AppColors.text)
                }
                Spacer()
                Image(systemName: viewModel.todayCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(viewModel.todayCompleted ? .green : AppColors.subtext)
            }

            ProgressView(value: plan.progress)
                .tint(AppColors.accent)

            HStack {
                Label(viewModel.formatProgress(plan), systemImage: "calendar")
                Spacer()
                Label("\(viewModel.getStreak()) day streak", systemImage: "flame.fill")
            }
            .font(.caption)
            .foregroundColor(AppColors.subtext)

            if !viewModel.todayCompleted {
                Button { viewModel.markTodayComplete() } label: {
                    Text("Mark Today Complete")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Plan Row Card
struct PlanRowCard: View {
    let plan: PrayerPlan
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(themeGradient)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: themeIcon).foregroundColor(.white))

            VStack(alignment: .leading, spacing: 4) {
                Text(plan.name)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Text("\(plan.themes.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(plan.progress * 100))%")
                    .font(.headline)
                    .foregroundColor(AppColors.accent)
                if isActive {
                    Text("Active")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var themeGradient: LinearGradient {
        LinearGradient(colors: [AppColors.primary, AppColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
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

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.cardBackground)
            .foregroundColor(AppColors.text)
            .cornerRadius(12)
        }
    }
}

// MARK: - Empty Plan View
struct EmptyPlanView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.subtext)
            Text("No Prayer Plans Yet")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text("Create a new plan or choose from templates")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Templates Sheet
struct TemplatesSheet: View {
    @ObservedObject var viewModel: PrayerPlanViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(PrayerPlan.templates) { template in
                            TemplateCard(template: template) {
                                viewModel.createFromTemplate(template)
                                isPresented = false
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: PrayerPlan
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(template.name)
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text(template.description)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
            HStack {
                Label("\(template.durationDays) days", systemImage: "calendar")
                Spacer()
                Label("\(template.prayersPerDay)/day", systemImage: "hands.sparkles")
            }
            .font(.caption)
            .foregroundColor(AppColors.subtext)
            Button("Start This Plan", action: onSelect)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppColors.primary)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
