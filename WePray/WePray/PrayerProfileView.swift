//
//  PrayerProfileView.swift
//  WePray - Prayer Profile View
//

import SwiftUI

struct PrayerProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = PrayerProfileViewModel()
    @State private var showAddScripture = false
    @State private var showAddTestimony = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Card
                    PrayerStatsCard(stats: viewModel.stats)
                        .padding(.horizontal)

                    // Prayer Journey Badge
                    if let years = viewModel.profile?.prayerJourneyYears {
                        PrayerJourneyBadge(years: years)
                    }

                    // Tab Selector
                    tabSelector

                    // Tab Content
                    Group {
                        if selectedTab == 0 {
                            aboutSection
                        } else if selectedTab == 1 {
                            preferencesSection
                        } else {
                            testimonialsSection
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AppColors.background)
            .navigationTitle("Prayer Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddScripture) {
                AddScriptureSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddTestimony) {
                AddTestimonySheet(viewModel: viewModel)
            }
            .onAppear {
                if let userId = appState.currentUser?.id.uuidString {
                    viewModel.loadProfile(for: userId)
                }
            }
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "About", index: 0)
            tabButton(title: "Preferences", index: 1)
            tabButton(title: "Testimonies", index: 2)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            Text(title)
                .font(.subheadline.weight(selectedTab == index ? .semibold : .regular))
                .foregroundColor(selectedTab == index ? .white : AppColors.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == index ? AppColors.primary : Color.clear)
                .cornerRadius(12)
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 16) {
            // Bio
            VStack(alignment: .leading, spacing: 8) {
                Text("About My Prayer Life")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                TextEditor(text: Binding(
                    get: { viewModel.profile?.bio ?? "" },
                    set: { viewModel.updateBio($0) }
                ))
                .frame(height: 100)
                .padding(8)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }

            // Prayer Goal
            VStack(alignment: .leading, spacing: 8) {
                Text("Prayer Goal")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                TextField("What's your prayer goal?", text: Binding(
                    get: { viewModel.profile?.prayerGoal ?? "" },
                    set: { viewModel.updatePrayerGoal($0) }
                ), axis: .vertical)
                .lineLimit(2...4)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }

            // Prayer Journey Since
            VStack(alignment: .leading, spacing: 8) {
                Text("Prayer Journey Since")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                DatePicker("", selection: Binding(
                    get: { viewModel.profile?.prayerJourneySince ?? Date() },
                    set: { viewModel.updatePrayerJourneySince($0) }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }

            // Favorite Scriptures
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Favorite Scriptures")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Spacer()
                    Button { showAddScripture = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.primary)
                    }
                }

                ForEach(viewModel.profile?.favoriteScriptures ?? []) { scripture in
                    ScriptureCard(scripture: scripture) {
                        viewModel.removeScripture(scripture.id)
                    }
                }

                if viewModel.profile?.favoriteScriptures.isEmpty ?? true {
                    Text("Add your favorite scriptures")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(spacing: 20) {
            // Focus Areas
            VStack(alignment: .leading, spacing: 12) {
                Text("Prayer Focus Areas")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                FlowLayout(spacing: 8) {
                    ForEach(PrayerFocusArea.allCases) { area in
                        FocusAreaChip(
                            area: area,
                            isSelected: viewModel.profile?.focusAreas.contains(area) ?? false
                        ) {
                            viewModel.toggleFocusArea(area)
                        }
                    }
                }
            }

            // Preferred Times
            VStack(alignment: .leading, spacing: 12) {
                Text("Preferred Prayer Times")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                FlowLayout(spacing: 8) {
                    ForEach(PrayerTimePreference.allCases, id: \.self) { time in
                        PrayerTimeChip(
                            time: time,
                            isSelected: viewModel.profile?.preferredTimes.contains(time) ?? false
                        ) {
                            viewModel.togglePreferredTime(time)
                        }
                    }
                }
            }

            // Prayer Styles
            VStack(alignment: .leading, spacing: 12) {
                Text("Prayer Styles")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                ForEach(PrayerStyle.allCases, id: \.self) { style in
                    PrayerStyleCard(
                        style: style,
                        isSelected: viewModel.profile?.prayerStyles.contains(style) ?? false
                    ) {
                        viewModel.togglePrayerStyle(style)
                    }
                }
            }

            // Visibility & Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Prayer Request Visibility")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                VisibilityPicker(selection: Binding(
                    get: { viewModel.profile?.prayerRequestVisibility ?? .connectionsOnly },
                    set: { viewModel.updateVisibility($0) }
                ))

                Toggle(isOn: Binding(
                    get: { viewModel.profile?.openToBeingPrayerPartner ?? true },
                    set: { _ in viewModel.togglePrayerPartnerAvailability() }
                )) {
                    Label("Open to being a Prayer Partner", systemImage: "person.2.fill")
                }
                .tint(AppColors.primary)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Testimonials Section
    private var testimonialsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("My Testimonies")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Button { showAddTestimony = true } label: {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }

            ForEach(viewModel.profile?.testimonies ?? []) { testimony in
                TestimonyCard(testimony: testimony) {
                    viewModel.updateTestimonyVisibility(testimony.id, isPublic: !testimony.isPublic)
                } onDelete: {
                    viewModel.removeTestimony(testimony.id)
                }
            }

            if viewModel.profile?.testimonies.isEmpty ?? true {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(AppColors.subtext)
                    Text("Share your answered prayers")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text("Your testimonies can encourage others in their faith journey")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
        }
    }
}
