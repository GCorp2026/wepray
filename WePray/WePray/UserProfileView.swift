//
//  UserProfileView.swift
//  WePray - User Profile & Follow System
//

import SwiftUI

// MARK: - User Profile Model
struct UserProfileData: Identifiable, Codable {
    var id = UUID()
    let name: String
    let bio: String
    let avatarInitial: String
    var followersCount: Int
    var followingCount: Int
    var isFollowing: Bool
    let prayerCount: Int
    let joinDate: Date

    static let sampleUsers: [UserProfileData] = [
        UserProfileData(name: "Sarah M.", bio: "Devoted to daily prayer and spreading God's love.", avatarInitial: "S", followersCount: 234, followingCount: 156, isFollowing: false, prayerCount: 89, joinDate: Date(timeIntervalSinceNow: -86400 * 180)),
        UserProfileData(name: "David K.", bio: "Prayer warrior. Believer. Father of 3.", avatarInitial: "D", followersCount: 512, followingCount: 203, isFollowing: true, prayerCount: 156, joinDate: Date(timeIntervalSinceNow: -86400 * 365)),
        UserProfileData(name: "Grace L.", bio: "Walking in faith, one prayer at a time.", avatarInitial: "G", followersCount: 189, followingCount: 97, isFollowing: false, prayerCount: 67, joinDate: Date(timeIntervalSinceNow: -86400 * 90)),
        UserProfileData(name: "Michael R.", bio: "Youth pastor. Praying for the next generation.", avatarInitial: "M", followersCount: 876, followingCount: 312, isFollowing: true, prayerCount: 234, joinDate: Date(timeIntervalSinceNow: -86400 * 500))
    ]
}

// MARK: - User Profile View
struct UserProfileView: View {
    @State var userProfile: UserProfileData
    @State private var userPosts: [PrayerPost] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader

                    // Stats Row
                    statsRow

                    // Follow Button
                    followButton

                    // User's Prayers Section
                    prayersSection
                }
                .padding()
            }
        }
        .navigationTitle(userProfile.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadUserPosts() }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)

                Text(userProfile.avatarInitial)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: AppColors.primary.opacity(0.3), radius: 10)

            // Name
            Text(userProfile.name)
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            // Bio
            Text(userProfile.bio)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Join Date
            Text("Member since \(userProfile.joinDate, format: .dateTime.month().year())")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            ProfileStatItem(value: userProfile.prayerCount, label: "Prayers")
            Divider().frame(height: 40).background(AppColors.border)
            ProfileStatItem(value: userProfile.followersCount, label: "Followers")
            Divider().frame(height: 40).background(AppColors.border)
            ProfileStatItem(value: userProfile.followingCount, label: "Following")
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Follow Button
    private var followButton: some View {
        Button(action: toggleFollow) {
            HStack {
                Image(systemName: userProfile.isFollowing ? "person.badge.minus" : "person.badge.plus")
                Text(userProfile.isFollowing ? "Unfollow" : "Follow")
            }
            .font(.headline)
            .foregroundColor(userProfile.isFollowing ? AppColors.text : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if userProfile.isFollowing {
                        AppColors.cardBackground
                    } else {
                        LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(userProfile.isFollowing ? AppColors.border : Color.clear, lineWidth: 1)
            )
        }
    }

    // MARK: - Prayers Section
    private var prayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(userProfile.name)'s Prayers")
                .font(.headline)
                .foregroundColor(AppColors.text)

            if userPosts.isEmpty {
                Text("No prayers shared yet")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(userPosts) { post in
                    UserPrayerCard(post: post)
                }
            }
        }
    }

    // MARK: - Actions
    private func toggleFollow() {
        userProfile.isFollowing.toggle()
        userProfile.followersCount += userProfile.isFollowing ? 1 : -1
    }

    private func loadUserPosts() {
        userPosts = [
            PrayerPost(authorName: userProfile.name, content: "Praying for strength and guidance today.", timestamp: Date(timeIntervalSinceNow: -3600), likes: 12, isLiked: false),
            PrayerPost(authorName: userProfile.name, content: "Thank you Lord for another beautiful day!", timestamp: Date(timeIntervalSinceNow: -86400), likes: 24, isLiked: true)
        ]
    }
}

// MARK: - Profile Stat Item (renamed to avoid conflict with SpeakingPracticeView.StatItem)
struct ProfileStatItem: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3.bold())
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - User Prayer Card
struct UserPrayerCard: View {
    let post: PrayerPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.content)
                .font(.body)
                .foregroundColor(AppColors.text)

            HStack {
                Text(post.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(post.isLiked ? .red : AppColors.subtext)
                    Text("\(post.likes)")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        UserProfileView(userProfile: UserProfileData.sampleUsers[0])
    }
}
