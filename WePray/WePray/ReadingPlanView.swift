//
//  ReadingPlanView.swift
//  WePray - Bible Reading Plans View
//

import SwiftUI

struct ReadingPlanView: View {
    @ObservedObject var viewModel: DevotionalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: ReadingPlan?
    @State private var showingPlanDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Active Plan Section
                        if let activePlan = viewModel.activePlan {
                            activePlanSection(activePlan)
                        }

                        // Available Plans
                        availablePlansSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Reading Plans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPlanDetail) {
                if let plan = selectedPlan {
                    PlanDetailSheet(viewModel: viewModel, plan: plan)
                }
            }
        }
    }

    // MARK: - Active Plan Section
    private func activePlanSection(_ plan: ReadingPlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "book.circle.fill")
                    .foregroundColor(plan.category.color)
                Text("Your Active Plan")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(plan.title)
                        .font(.title3.bold())
                        .foregroundColor(AppColors.text)
                    Spacer()
                    Text("Day \(plan.currentDay)")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(plan.category.color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                ProgressView(value: plan.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: plan.category.color))

                HStack {
                    Label("\(Int(plan.progressPercentage * 100))% complete", systemImage: "chart.bar.fill")
                    Spacer()
                    Label("\(plan.daysRemaining) days left", systemImage: "calendar")
                }
                .font(.caption)
                .foregroundColor(AppColors.subtext)

                Divider()

                // Today's Reading
                if let reading = viewModel.getTodaysReading(for: plan) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Reading")
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)

                        HStack {
                            VStack(alignment: .leading) {
                                Text(reading.title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.text)
                                ForEach(reading.passages, id: \.reference) { passage in
                                    Text(passage.reference)
                                        .font(.caption)
                                        .foregroundColor(plan.category.color)
                                }
                            }
                            Spacer()
                            Button {
                                viewModel.completeReading(plan, day: reading.day)
                            } label: {
                                Image(systemName: reading.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(reading.isCompleted ? .green : AppColors.subtext)
                            }
                        }
                    }
                }

                HStack {
                    Button {
                        selectedPlan = plan
                        showingPlanDetail = true
                    } label: {
                        Text("View All Days")
                            .font(.subheadline.bold())
                            .foregroundColor(AppColors.accent)
                    }
                    Spacer()
                    Button {
                        viewModel.abandonPlan(plan)
                    } label: {
                        Text("Abandon")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }

    // MARK: - Available Plans Section
    private var availablePlansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Plans")
                .font(.headline)
                .foregroundColor(AppColors.text)

            LazyVStack(spacing: 12) {
                ForEach(viewModel.readingPlans.filter { !$0.isActive }) { plan in
                    ReadingPlanCard(plan: plan) {
                        selectedPlan = plan
                        showingPlanDetail = true
                    }
                }
            }
        }
    }
}

// MARK: - Reading Plan Card
struct ReadingPlanCard: View {
    let plan: ReadingPlan
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Circle()
                    .fill(plan.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: plan.category.icon).foregroundColor(plan.category.color))

                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text(plan.description)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                        .lineLimit(2)
                    HStack {
                        Label("\(plan.duration) days", systemImage: "calendar")
                        Label(plan.category.rawValue, systemImage: plan.category.icon)
                    }
                    .font(.caption2)
                    .foregroundColor(AppColors.subtext)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.subtext)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Plan Detail Sheet
struct PlanDetailSheet: View {
    @ObservedObject var viewModel: DevotionalViewModel
    let plan: ReadingPlan
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Plan Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(plan.title)
                                .font(.title.bold())
                                .foregroundColor(AppColors.text)
                            Text(plan.description)
                                .font(.body)
                                .foregroundColor(AppColors.subtext)
                            HStack {
                                Label("\(plan.duration) days", systemImage: "calendar")
                                Label(plan.category.rawValue, systemImage: plan.category.icon)
                            }
                            .font(.caption)
                            .foregroundColor(plan.category.color)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(plan.category.color.opacity(0.1))
                        .cornerRadius(16)

                        // Start Button (if not active)
                        if !plan.isActive {
                            Button {
                                viewModel.startPlan(plan)
                                dismiss()
                            } label: {
                                Text("Start This Plan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(plan.category.color)
                                    .cornerRadius(12)
                            }
                        }

                        // Readings List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Readings")
                                .font(.headline)
                                .foregroundColor(AppColors.text)

                            ForEach(plan.readings) { reading in
                                ReadingDayRow(reading: reading, plan: plan, viewModel: viewModel)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Reading Day Row
struct ReadingDayRow: View {
    let reading: DailyReading
    let plan: ReadingPlan
    @ObservedObject var viewModel: DevotionalViewModel

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(reading.isCompleted ? Color.green : (reading.day == plan.currentDay ? plan.category.color : AppColors.border))
                .frame(width: 32, height: 32)
                .overlay(
                    Group {
                        if reading.isCompleted {
                            Image(systemName: "checkmark").foregroundColor(.white)
                        } else {
                            Text("\(reading.day)").font(.caption.bold()).foregroundColor(reading.day == plan.currentDay ? .white : AppColors.subtext)
                        }
                    }
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(reading.title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.text)
                ForEach(reading.passages, id: \.reference) { passage in
                    Text(passage.reference)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Spacer()

            if plan.isActive && reading.day == plan.currentDay && !reading.isCompleted {
                Button {
                    viewModel.completeReading(plan, day: reading.day)
                } label: {
                    Text("Mark Done")
                        .font(.caption.bold())
                        .foregroundColor(plan.category.color)
                }
            }
        }
        .padding()
        .background(reading.day == plan.currentDay ? plan.category.color.opacity(0.1) : AppColors.cardBackground)
        .cornerRadius(12)
    }
}
