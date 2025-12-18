//
//  PrayerPlanCreationView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct PrayerPlanCreationView: View {
    @ObservedObject var viewModel: PrayerPlanViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var selectedThemes: Set<PrayerTheme> = []
    @State private var frequency: PrayerFrequency = .daily
    @State private var durationDays = 7
    @State private var prayersPerDay = 2
    @State private var isShared = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private let durationOptions = [7, 14, 21, 30, 40, 60, 90]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Name & Description
                        basicInfoSection

                        // Themes Selection
                        themesSection

                        // Frequency & Duration
                        scheduleSection

                        // Prayers Per Day
                        intensitySection

                        // Sharing Toggle
                        sharingSection

                        // Create Button
                        createButton
                    }
                    .padding()
                }
            }
            .navigationTitle("New Prayer Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Plan Details")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("Plan Name", text: $name)
                .textFieldStyle(CustomTextFieldStyle())

            TextField("Description (optional)", text: $description, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(CustomTextFieldStyle())
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Themes Section
    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prayer Themes")
                .font(.headline)
                .foregroundColor(AppColors.text)

            Text("Select one or more themes for your plan")
                .font(.caption)
                .foregroundColor(AppColors.subtext)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PrayerTheme.allCases, id: \.self) { theme in
                    ThemeSelectionButton(
                        theme: theme,
                        isSelected: selectedThemes.contains(theme)
                    ) {
                        if selectedThemes.contains(theme) {
                            selectedThemes.remove(theme)
                        } else {
                            selectedThemes.insert(theme)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Schedule Section
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schedule")
                .font(.headline)
                .foregroundColor(AppColors.text)

            // Frequency Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Frequency")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)

                Picker("Frequency", selection: $frequency) {
                    ForEach(PrayerFrequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Duration Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration: \(durationDays) days")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(durationOptions, id: \.self) { days in
                            DurationChip(days: days, isSelected: durationDays == days) {
                                durationDays = days
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Intensity Section
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Commitment")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack {
                Text("Prayers per day:")
                    .foregroundColor(AppColors.subtext)
                Spacer()
                Stepper("\(prayersPerDay)", value: $prayersPerDay, in: 1...10)
                    .foregroundColor(AppColors.text)
            }

            // Commitment Level Indicator
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { level in
                    Rectangle()
                        .fill(level <= commitmentLevel ? AppColors.primary : AppColors.border)
                        .frame(height: 8)
                        .cornerRadius(4)
                }
            }

            Text(commitmentDescription)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private var commitmentLevel: Int {
        switch prayersPerDay {
        case 1...2: return 1
        case 3...4: return 2
        case 5...6: return 3
        case 7...8: return 4
        default: return 5
        }
    }

    private var commitmentDescription: String {
        switch commitmentLevel {
        case 1: return "Light - Perfect for beginners"
        case 2: return "Moderate - Building consistency"
        case 3: return "Active - Deepening your practice"
        case 4: return "Intensive - Strong commitment"
        default: return "Advanced - Maximum devotion"
        }
    }

    // MARK: - Sharing Section
    private var sharingSection: some View {
        Toggle(isOn: $isShared) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Share with Groups")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Text("Let your prayer groups see your progress")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .tint(AppColors.primary)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Create Button
    private var createButton: some View {
        Button(action: createPlan) {
            Text("Create Prayer Plan")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canCreate ? AppColors.primary : AppColors.border)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!canCreate)
    }

    private var canCreate: Bool {
        !name.isEmpty && !selectedThemes.isEmpty
    }

    private func createPlan() {
        guard canCreate else {
            errorMessage = "Please enter a name and select at least one theme."
            showingError = true
            return
        }

        viewModel.createPlan(
            name: name,
            description: description,
            themes: Array(selectedThemes),
            frequency: frequency,
            durationDays: durationDays,
            prayersPerDay: prayersPerDay,
            isShared: isShared
        )
        dismiss()
    }
}

// Note: CustomTextFieldStyle moved to UIHelpers.swift

// MARK: - Theme Selection Button
struct ThemeSelectionButton: View {
    let theme: PrayerTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForTheme)
                Text(theme.rawValue)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primary : AppColors.border.opacity(0.3))
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(10)
        }
    }

    private var iconForTheme: String {
        switch theme {
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

// MARK: - Duration Chip
struct DurationChip: View {
    let days: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(days) days")
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primary : AppColors.border.opacity(0.3))
                .foregroundColor(isSelected ? .white : AppColors.text)
                .cornerRadius(20)
        }
    }
}
