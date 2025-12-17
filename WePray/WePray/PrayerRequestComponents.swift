//
//  PrayerRequestComponents.swift
//  WePray - Prayer Request UI Components
//

import SwiftUI

// MARK: - Response Card
struct ResponseCard: View {
    let response: PrayerResponse

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(AppColors.primary.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(Text(String(response.authorName.prefix(1))).font(.caption.bold()))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(response.authorName)
                        .font(.subheadline.bold())
                    RoleBadgeView(role: response.authorRole, size: .small)
                    Spacer()
                    Text(response.formattedDate)
                        .font(.caption2)
                        .foregroundColor(AppColors.subtext)
                }
                Text(response.message)
                    .font(.subheadline)
                    .foregroundColor(AppColors.text)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Testimony Sheet
struct TestimonySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var testimonyText: String
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "hands.clap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)

                    Text("Praise God!")
                        .font(.title.bold())
                        .foregroundColor(AppColors.text)

                    Text("Share how God answered this prayer")
                        .font(.subheadline)
                        .foregroundColor(AppColors.subtext)

                    TextEditor(text: $testimonyText)
                        .frame(height: 150)
                        .padding(8)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)

                    Button { onSave() } label: {
                        Text("Share Testimony")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Answered Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Prayer Warrior Stats View
struct PrayerWarriorStatsView: View {
    let stats: PrayerWarriorStats
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Level Badge
                        VStack(spacing: 12) {
                            Image(systemName: stats.prayerWarriorLevel.icon)
                                .font(.system(size: 60))
                                .foregroundColor(stats.prayerWarriorLevel.color)
                            Text(stats.prayerWarriorLevel.rawValue)
                                .font(.title2.bold())
                                .foregroundColor(AppColors.text)
                            Text("Keep praying to reach the next level!")
                                .font(.subheadline)
                                .foregroundColor(AppColors.subtext)
                        }
                        .padding()

                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatBox(icon: "hands.sparkles.fill", value: "\(stats.totalPrayersOffered)", label: "Prayers Offered", color: .purple)
                            StatBox(icon: "text.bubble.fill", value: "\(stats.totalRequestsSubmitted)", label: "Requests Shared", color: .blue)
                            StatBox(icon: "checkmark.seal.fill", value: "\(stats.answeredPrayers)", label: "Answered Prayers", color: .green)
                            StatBox(icon: "flame.fill", value: "\(stats.currentStreak)", label: "Current Streak", color: .orange)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.title.bold())
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}
