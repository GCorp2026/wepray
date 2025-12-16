//
//  FeedView.swift
//  WePray - Prayer Sharing Feed
//

import SwiftUI

// MARK: - Prayer Post Model
struct PrayerPost: Identifiable, Codable {
    var id = UUID()
    let authorName: String
    let content: String
    let timestamp: Date
    var likes: Int
    var isLiked: Bool

    static let samplePosts: [PrayerPost] = [
        PrayerPost(authorName: "Sarah M.", content: "Praying for healing for my family. God is faithful!", timestamp: Date(), likes: 12, isLiked: false),
        PrayerPost(authorName: "David K.", content: "Thankful for all my blessings today. Praise the Lord!", timestamp: Date(timeIntervalSinceNow: -3600), likes: 8, isLiked: true),
        PrayerPost(authorName: "Grace L.", content: "Please pray for my job interview tomorrow. Trusting in God's plan.", timestamp: Date(timeIntervalSinceNow: -7200), likes: 15, isLiked: false),
        PrayerPost(authorName: "Michael R.", content: "Praying for peace in our community and around the world.", timestamp: Date(timeIntervalSinceNow: -14400), likes: 23, isLiked: true)
    ]
}

// MARK: - Feed View
struct FeedView: View {
    @State private var prayerPosts: [PrayerPost] = PrayerPost.samplePosts
    @State private var isShowingNewPostSheet = false
    @State private var newPostContent = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(prayerPosts) { post in
                            PrayerPostCard(post: post, likeAction: {
                                toggleLike(for: post)
                            })
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingNewPostSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $isShowingNewPostSheet) {
                NewPrayerPostSheet(isPresented: $isShowingNewPostSheet, content: $newPostContent, onPost: addNewPost)
                    .presentationDetents([.medium])
            }
        }
    }

    private func toggleLike(for post: PrayerPost) {
        if let index = prayerPosts.firstIndex(where: { $0.id == post.id }) {
            prayerPosts[index].isLiked.toggle()
            prayerPosts[index].likes += prayerPosts[index].isLiked ? 1 : -1
        }
    }

    private func addNewPost() {
        guard !newPostContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newPost = PrayerPost(authorName: "You", content: newPostContent, timestamp: Date(), likes: 0, isLiked: false)
        prayerPosts.insert(newPost, at: 0)
        newPostContent = ""
    }
}

// MARK: - Prayer Post Card
struct PrayerPostCard: View {
    let post: PrayerPost
    let likeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .overlay(Text(String(post.authorName.prefix(1))).font(.headline).foregroundColor(.white))

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName).font(.headline).foregroundColor(AppColors.text)
                    Text(post.timestamp, style: .relative).font(.caption).foregroundColor(AppColors.subtext)
                }
                Spacer()
            }

            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(AppColors.text)
                .lineLimit(nil)

            // Actions
            HStack {
                Button(action: likeAction) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        Text("\(post.likes)")
                    }
                    .font(.subheadline)
                    .foregroundColor(post.isLiked ? .red : AppColors.subtext)
                }

                Spacer()

                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "hands.sparkles")
                        Text("Pray")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.accent)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - New Prayer Post Sheet
struct NewPrayerPostSheet: View {
    @Binding var isPresented: Bool
    @Binding var content: String
    let onPost: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Share a Prayer Request")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.text)

                    TextEditor(text: $content)
                        .frame(height: 150)
                        .padding(12)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))

                    HStack(spacing: 16) {
                        Button("Cancel") {
                            content = ""
                            isPresented = false
                        }
                        .foregroundColor(AppColors.error)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)

                        Button("Post Prayer") {
                            onPost()
                            isPresented = false
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    FeedView()
}
