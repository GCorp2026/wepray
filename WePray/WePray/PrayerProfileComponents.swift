//
//  PrayerProfileComponents.swift
//  WePray - Prayer Profile UI Components
//

import SwiftUI

// MARK: - Prayer Stats Card
struct PrayerStatsCard: View {
    let stats: PrayerProfileStats

    var body: some View {
        HStack(spacing: 0) {
            statItem(value: "\(stats.totalPrayers)", label: "Prayers", icon: "hands.sparkles.fill")
            Divider().frame(height: 40)
            statItem(value: "\(stats.prayerStreak)", label: "Streak", icon: "flame.fill")
            Divider().frame(height: 40)
            statItem(value: "\(stats.answeredPrayers)", label: "Answered", icon: "checkmark.circle.fill")
            Divider().frame(height: 40)
            statItem(value: "\(stats.prayerPartners)", label: "Partners", icon: "person.2.fill")
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.primary)
            Text(value)
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Focus Area Chip
struct FocusAreaChip: View {
    let area: PrayerFocusArea
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: area.icon)
                    .font(.caption)
                Text(area.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? area.color : AppColors.cardBackground)
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Prayer Time Chip
struct PrayerTimeChip: View {
    let time: PrayerTimePreference
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: time.icon)
                    .font(.caption)
                Text(time.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.primary : AppColors.cardBackground)
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Prayer Style Card
struct PrayerStyleCard: View {
    let style: PrayerStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(style.rawValue)
                        .font(.subheadline.bold())
                        .foregroundColor(isSelected ? .white : AppColors.text)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                Text(style.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.subtext)
                    .lineLimit(2)
            }
            .padding()
            .background(isSelected ? AppColors.primary : AppColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Scripture Card
struct ScriptureCard: View {
    let scripture: FavoriteScripture
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(scripture.reference)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.primary)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.subtext)
                }
            }
            Text(scripture.text)
                .font(.body)
                .foregroundColor(AppColors.text)
                .italic()
            if !scripture.note.isEmpty {
                Text(scripture.note)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Testimony Card
struct TestimonyCard: View {
    let testimony: PrayerTestimony
    let onToggleVisibility: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: testimony.category.icon)
                        .foregroundColor(testimony.category.color)
                    Text(testimony.title)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                }
                Spacer()
                Menu {
                    Button(action: onToggleVisibility) {
                        Label(testimony.isPublic ? "Make Private" : "Make Public",
                              systemImage: testimony.isPublic ? "lock.fill" : "globe")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppColors.subtext)
                        .padding(8)
                }
            }

            Text(testimony.story)
                .font(.body)
                .foregroundColor(AppColors.text)
                .lineLimit(3)

            HStack {
                Label(testimony.category.rawValue, systemImage: testimony.category.icon)
                    .font(.caption)
                    .foregroundColor(testimony.category.color)
                Spacer()
                Label(testimony.isPublic ? "Public" : "Private",
                      systemImage: testimony.isPublic ? "globe" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Visibility Picker
struct VisibilityPicker: View {
    @Binding var selection: PrayerRequestVisibility

    var body: some View {
        HStack(spacing: 8) {
            ForEach(PrayerRequestVisibility.allCases, id: \.self) { visibility in
                Button {
                    selection = visibility
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: visibility.icon)
                            .font(.caption)
                        Text(visibility.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selection == visibility ? AppColors.primary : AppColors.cardBackground)
                    .foregroundColor(selection == visibility ? .white : AppColors.text)
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Prayer Journey Badge
struct PrayerJourneyBadge: View {
    let years: Int?

    var body: some View {
        if let years = years, years > 0 {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                Text("\(years) year\(years == 1 ? "" : "s") in prayer")
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.primary)
            .cornerRadius(12)
        }
    }
}
