//
//  ClubComponents.swift
//  WePray - Club UI Components
//

import SwiftUI

// MARK: - Club Card
struct ClubCard: View {
    let club: Club
    let isMember: Bool
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(club.gradient)
                    .frame(height: 80)

                VStack(spacing: 4) {
                    Image(systemName: club.iconName)
                        .font(.title)
                        .foregroundColor(.white)

                    if !club.isPublic {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("Private")
                                .font(.caption2)
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            Text(club.name)
                .font(.headline)
                .foregroundColor(AppColors.text)
                .lineLimit(1)

            Text(club.description)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
                .lineLimit(2)

            HStack {
                Label("\(club.memberCount)", systemImage: "person.2.fill")
                    .font(.caption2)
                    .foregroundColor(AppColors.subtext)

                Spacer()

                Button(action: onJoin) {
                    Text(isMember ? "Joined" : "Join")
                        .font(.caption.bold())
                        .foregroundColor(isMember ? AppColors.subtext : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isMember ? AppColors.border : AppColors.primary)
                        .cornerRadius(8)
                }
                .disabled(isMember)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - My Club Card (Horizontal)
struct MyClubCard: View {
    let club: Club

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(club.gradient)
                    .frame(width: 50, height: 50)
                Image(systemName: club.iconName)
                    .foregroundColor(.white)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(club.name)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)
                Text("\(club.memberCount) members")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Club Filter Chips
struct ClubFilterChips: View {
    @Binding var selectedFilter: ClubFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ClubFilter.allCases, id: \.self) { filter in
                    ClubFilterChip(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Club Filter Chip
struct ClubFilterChip: View {
    let filter: ClubFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [AppColors.cardBackground, AppColors.cardBackground], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Category Chips
struct ClubCategoryChips: View {
    @Binding var selectedCategory: ClubCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All option
                Button {
                    selectedCategory = nil
                } label: {
                    Text("All")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedCategory == nil ? AppColors.primary : AppColors.cardBackground)
                        .foregroundColor(selectedCategory == nil ? .white : AppColors.text)
                        .cornerRadius(16)
                }

                ForEach(ClubCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedCategory == category ? category.color : AppColors.cardBackground)
                        .foregroundColor(selectedCategory == category ? .white : AppColors.text)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
