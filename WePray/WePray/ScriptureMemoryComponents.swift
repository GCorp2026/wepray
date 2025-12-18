import SwiftUI

// MARK: - Memory Stat Badge

struct MemoryStatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Review Verse Card

struct ReviewVerseCard: View {
    let verse: MemoryVerse
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: verse.category.icon)
                        .foregroundColor(verse.category.color)
                    Spacer()
                    Image(systemName: verse.masteryLevel.icon)
                        .foregroundColor(verse.masteryLevel.color)
                }

                Text(verse.reference)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)

                Text(verse.text)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                    .lineLimit(2)
            }
            .padding()
            .frame(width: 160, height: 120)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(verse.masteryLevel.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Practice Mode Card

struct PracticeModeCard: View {
    let mode: PracticeMode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(AppColors.accent)

                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.text)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Memory Category Chip

struct MemoryCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.15))
            .cornerRadius(20)
        }
    }
}

// MARK: - Verse Card

struct VerseCard: View {
    let verse: MemoryVerse
    @ObservedObject var viewModel: ScriptureMemoryViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: verse.category.icon)
                            .foregroundColor(verse.category.color)
                        Text(verse.reference)
                            .font(.headline)
                            .foregroundColor(AppColors.text)
                    }

                    Spacer()

                    Button(action: { viewModel.toggleFavorite(verse) }) {
                        Image(systemName: verse.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(verse.isFavorite ? .red : AppColors.subtext)
                    }
                }

                Text(verse.text)
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .lineLimit(3)

                HStack {
                    Label(verse.translation, systemImage: "book")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: verse.masteryLevel.icon)
                        Text(verse.masteryLevel.title)
                    }
                    .font(.caption)
                    .foregroundColor(verse.masteryLevel.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(verse.masteryLevel.color.opacity(0.15))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Verse Stat Item

struct VerseStatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accent)
            Text(value)
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// Note: FlowLayout moved to UIHelpers.swift

// MARK: - Blank Item

struct BlankItem {
    let word: String
    let isBlank: Bool
    let blankIndex: Int?
}
