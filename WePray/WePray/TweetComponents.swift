//
//  TweetComponents.swift
//  WePray - Tweet UI Components
//

import SwiftUI

// MARK: - Tweet Card
struct TweetCard: View {
    let tweet: Tweet
    let onLike: () -> Void
    let onRetweet: () -> Void
    let onReply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with author info
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [tweet.authorRole.badgeColorValue, tweet.authorRole.badgeColorValue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(tweet.authorName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(tweet.authorName)
                            .font(.headline)
                            .foregroundColor(AppColors.text)

                        RoleBadgeView(role: tweet.authorRole)
                    }

                    Text(tweet.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                Menu {
                    Button(action: {}) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive, action: {}) {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppColors.subtext)
                        .padding(8)
                }
            }

            // Content
            Text(tweet.content)
                .font(.body)
                .foregroundColor(AppColors.text)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            // Action Bar
            TweetActionBar(
                likes: tweet.likes,
                retweets: tweet.retweets,
                replies: tweet.replyCount,
                isLiked: tweet.isLiked,
                isRetweeted: tweet.isRetweeted,
                onLike: onLike,
                onRetweet: onRetweet,
                onReply: onReply
            )
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.primary.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Tweet Action Bar
struct TweetActionBar: View {
    let likes: Int
    let retweets: Int
    let replies: Int
    let isLiked: Bool
    let isRetweeted: Bool
    let onLike: () -> Void
    let onRetweet: () -> Void
    let onReply: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Reply
            TweetActionButton(
                icon: "bubble.left",
                count: replies,
                isActive: false,
                activeColor: AppColors.accent,
                action: onReply
            )

            Spacer()

            // Retweet
            TweetActionButton(
                icon: "arrow.2.squarepath",
                count: retweets,
                isActive: isRetweeted,
                activeColor: .green,
                action: onRetweet
            )

            Spacer()

            // Like
            TweetActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: likes,
                isActive: isLiked,
                activeColor: .red,
                action: onLike
            )

            Spacer()

            // Share
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Tweet Action Button
struct TweetActionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                if count > 0 {
                    Text(formatCount(count))
                        .font(.caption)
                }
            }
            .foregroundColor(isActive ? activeColor : AppColors.subtext)
        }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Tweet Filter Chips
struct TweetFilterChips: View {
    @Binding var selectedFilter: TweetFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TweetFilter.allCases, id: \.self) { filter in
                    TweetFilterChip(
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

// MARK: - Tweet Filter Chip
struct TweetFilterChip: View {
    let filter: TweetFilter
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

// MARK: - Empty Timeline View
struct EmptyTimelineView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext.opacity(0.5))

            Text("No Tweets Yet")
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            Text("Be the first to share a prayer or thought!")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Compose Button
struct TweetComposeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}
