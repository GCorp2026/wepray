//
//  NewPrayerRequestView.swift
//  WePray - Submit New Prayer Request
//

import SwiftUI

struct NewPrayerRequestView: View {
    @ObservedObject var viewModel: PrayerRequestViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: PrayerRequestCategory = .other
    @State private var selectedUrgency: PrayerUrgency = .medium
    @State private var isAnonymous = false
    @State private var expiresIn: Int? = 30

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Anonymous Toggle
                        anonymousSection

                        // Title Input
                        titleSection

                        // Description Input
                        descriptionSection

                        // Category Selection
                        categorySection

                        // Urgency Selection
                        urgencySection

                        // Expiration Selection
                        expirationSection

                        // Submit Button
                        submitButton
                    }
                    .padding()
                }
            }
            .navigationTitle("New Prayer Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Anonymous Section
    private var anonymousSection: some View {
        Toggle(isOn: $isAnonymous) {
            HStack {
                Image(systemName: isAnonymous ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(AppColors.accent)
                VStack(alignment: .leading) {
                    Text("Post Anonymously")
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.text)
                    Text("Your name won't be shown")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prayer Request Title")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)

            TextField("Brief summary of your request", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)

            TextEditor(text: $description)
                .frame(minHeight: 120)
                .padding(8)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    Group {
                        if description.isEmpty {
                            Text("Share more about your prayer request...")
                                .foregroundColor(AppColors.subtext)
                                .padding(12)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }

    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(PrayerRequestCategory.allCases, id: \.self) { category in
                    CategoryButton(category: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Urgency Section
    private var urgencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Urgency Level")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)

            HStack(spacing: 8) {
                ForEach(PrayerUrgency.allCases, id: \.self) { urgency in
                    UrgencyButton(urgency: urgency, isSelected: selectedUrgency == urgency) {
                        selectedUrgency = urgency
                    }
                }
            }
        }
    }

    // MARK: - Expiration Section
    private var expirationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Request Duration")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)

            HStack(spacing: 8) {
                ExpirationChip(days: 7, isSelected: expiresIn == 7) { expiresIn = 7 }
                ExpirationChip(days: 14, isSelected: expiresIn == 14) { expiresIn = 14 }
                ExpirationChip(days: 30, isSelected: expiresIn == 30) { expiresIn = 30 }
                ExpirationChip(days: nil, isSelected: expiresIn == nil) { expiresIn = nil }
            }
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            viewModel.createRequest(
                title: title,
                description: description,
                category: selectedCategory,
                urgency: selectedUrgency,
                isAnonymous: isAnonymous,
                authorId: appState.currentUser?.id ?? "guest",
                authorName: appState.currentUser?.name ?? "Guest User",
                expiresIn: expiresIn
            )
            dismiss()
        } label: {
            HStack {
                Image(systemName: "paperplane.fill")
                Text("Submit Prayer Request")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? AppColors.accent : AppColors.border)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!canSubmit)
    }

    private var canSubmit: Bool { !title.isEmpty && !description.isEmpty }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: PrayerRequestCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title3)
                Text(category.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : category.color)
            .background(isSelected ? category.color : category.color.opacity(0.15))
            .cornerRadius(10)
        }
    }
}

// MARK: - Urgency Button
struct UrgencyButton: View {
    let urgency: PrayerUrgency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: urgency.icon)
                    .font(.title3)
                Text(urgency.rawValue)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : urgency.color)
            .background(isSelected ? urgency.color : urgency.color.opacity(0.15))
            .cornerRadius(10)
        }
    }
}

// MARK: - Expiration Chip
struct ExpirationChip: View {
    let days: Int?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(days != nil ? "\(days!)d" : "∞")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(isSelected ? .white : AppColors.text)
                .background(isSelected ? AppColors.accent : AppColors.cardBackground)
                .cornerRadius(8)
        }
    }
}
