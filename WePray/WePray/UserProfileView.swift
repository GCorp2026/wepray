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
    var connectionsCount: Int
    var isFollowing: Bool
    var isConnected: Bool
    var hasPendingRequest: Bool
    let prayerCount: Int
    let joinDate: Date
    var role: UserRole
    var profession: String
    var skills: [String]

    static let sampleUsers: [UserProfileData] = [
        UserProfileData(name: "Sarah M.", bio: "Devoted to daily prayer and spreading God's love.", avatarInitial: "S", followersCount: 234, followingCount: 156, connectionsCount: 89, isFollowing: false, isConnected: false, hasPendingRequest: false, prayerCount: 89, joinDate: Date(timeIntervalSinceNow: -86400 * 180), role: .premium, profession: "Youth Pastor", skills: ["Prayer", "Leadership"]),
        UserProfileData(name: "David K.", bio: "Prayer warrior. Believer. Father of 3.", avatarInitial: "D", followersCount: 512, followingCount: 203, connectionsCount: 156, isFollowing: true, isConnected: true, hasPendingRequest: false, prayerCount: 156, joinDate: Date(timeIntervalSinceNow: -86400 * 365), role: .user, profession: "Teacher", skills: ["Bible Study", "Mentoring"]),
        UserProfileData(name: "Grace L.", bio: "Walking in faith, one prayer at a time.", avatarInitial: "G", followersCount: 189, followingCount: 97, connectionsCount: 45, isFollowing: false, isConnected: false, hasPendingRequest: true, prayerCount: 67, joinDate: Date(timeIntervalSinceNow: -86400 * 90), role: .user, profession: "Nurse", skills: ["Healthcare", "Compassion"]),
        UserProfileData(name: "Michael R.", bio: "Youth pastor. Praying for the next generation.", avatarInitial: "M", followersCount: 876, followingCount: 312, connectionsCount: 234, isFollowing: true, isConnected: true, hasPendingRequest: false, prayerCount: 234, joinDate: Date(timeIntervalSinceNow: -86400 * 500), role: .admin, profession: "Senior Pastor", skills: ["Preaching", "Counseling", "Leadership"])
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
                    .fill(LinearGradient(
                        colors: [userProfile.role.badgeColor, userProfile.role.badgeColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)

                Text(userProfile.avatarInitial)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: userProfile.role.badgeColor.opacity(0.3), radius: 10)

            // Name with Role Badge
            HStack(spacing: 8) {
                Text(userProfile.name)
                    .font(.title2.bold())
                    .foregroundColor(AppColors.text)

                RoleBadgeView(role: userProfile.role, style: .standard)
            }

            // Profession
            if !userProfile.profession.isEmpty {
                Text(userProfile.profession)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppColors.accent)
            }

            // Bio
            Text(userProfile.bio)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Skills
            if !userProfile.skills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(userProfile.skills, id: \.self) { skill in
                            Text(skill)
                                .font(.caption)
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppColors.primary.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }

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
            ProfileStatItem(value: userProfile.connectionsCount, label: "Connections")
            Divider().frame(height: 40).background(AppColors.border)
            ProfileStatItem(value: userProfile.followersCount, label: "Followers")
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Action Buttons
    private var followButton: some View {
        HStack(spacing: 12) {
            // Connect Button
            Button(action: toggleConnect) {
                HStack {
                    Image(systemName: connectButtonIcon)
                    Text(connectButtonText)
                }
                .font(.headline)
                .foregroundColor(userProfile.isConnected ? AppColors.text : .white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if userProfile.isConnected {
                            AppColors.cardBackground
                        } else if userProfile.hasPendingRequest {
                            Color.orange.opacity(0.2)
                        } else {
                            LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                        }
                    }
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(userProfile.isConnected || userProfile.hasPendingRequest ? AppColors.border : Color.clear, lineWidth: 1)
                )
            }
            .disabled(userProfile.hasPendingRequest)

            // Message Button (only if connected)
            if userProfile.isConnected {
                Button(action: { /* Open messaging */ }) {
                    Image(systemName: "message.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(AppColors.accent)
                        .cornerRadius(12)
                }
            }
        }
    }

    private var connectButtonIcon: String {
        if userProfile.isConnected { return "checkmark.circle.fill" }
        if userProfile.hasPendingRequest { return "clock.fill" }
        return "person.badge.plus"
    }

    private var connectButtonText: String {
        if userProfile.isConnected { return "Connected" }
        if userProfile.hasPendingRequest { return "Pending" }
        return "Connect"
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

    private func toggleConnect() {
        if userProfile.isConnected {
            // Already connected - could show disconnect confirmation
            userProfile.isConnected = false
            userProfile.connectionsCount -= 1
        } else if !userProfile.hasPendingRequest {
            // Send connection request
            userProfile.hasPendingRequest = true
        }
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
