//
//  TweetTimelineView.swift
//  WePray - Tweet Timeline Feed
//

import SwiftUI

struct TweetTimelineView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = TweetViewModel()
    @State private var showComposeSheet = false
    @State private var selectedTweet: Tweet?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter Chips
                    TweetFilterChips(selectedFilter: $viewModel.selectedFilter)
                        .padding(.vertical, 12)

                    // Tweet List
                    if viewModel.filteredTweets.isEmpty {
                        EmptyTimelineView()
                            .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredTweets) { tweet in
                                    TweetCard(
                                        tweet: tweet,
                                        onLike: { viewModel.likeTweet(tweetId: tweet.id) },
                                        onRetweet: { viewModel.retweetTweet(tweetId: tweet.id) },
                                        onReply: { selectedTweet = tweet }
                                    )
                                    .onTapGesture {
                                        selectedTweet = tweet
                                    }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            viewModel.refresh()
                        }
                    }
                }

                // Floating Compose Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TweetComposeButton {
                            showComposeSheet = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Tweets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(TweetSort.allCases, id: \.self) { sort in
                            Button {
                                viewModel.selectedSort = sort
                            } label: {
                                Label(sort.rawValue, systemImage: sort.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showComposeSheet) {
                TweetComposeView(isPresented: $showComposeSheet) { content in
                    postTweet(content: content)
                }
            }
            .sheet(item: $selectedTweet) { tweet in
                TweetDetailView(tweet: tweet, viewModel: viewModel)
            }
        }
        .onAppear {
            if let userId = appState.currentUser?.id.uuidString {
                viewModel.setCurrentUser(id: userId)
            }
        }
    }

    private func postTweet(content: String) {
        let authorId = appState.currentUser?.id.uuidString ?? UUID().uuidString
        let authorName = appState.currentUser?.displayName ?? "Anonymous"
        let authorRole = appState.currentUser?.role ?? .user

        viewModel.postTweet(
            content: content,
            authorId: authorId,
            authorName: authorName,
            authorRole: authorRole
        )
    }
}

// MARK: - Tweet Detail View
struct TweetDetailView: View {
    let tweet: Tweet
    @ObservedObject var viewModel: TweetViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var replyContent = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Main Tweet
                        TweetCard(
                            tweet: tweet,
                            onLike: { viewModel.likeTweet(tweetId: tweet.id) },
                            onRetweet: { viewModel.retweetTweet(tweetId: tweet.id) },
                            onReply: {}
                        )

                        // Reply Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Replies")
                                .font(.headline)
                                .foregroundColor(AppColors.text)

                            // Reply Input
                            HStack(spacing: 12) {
                                TextField("Write a reply...", text: $replyContent)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(20)

                                Button {
                                    sendReply()
                                } label: {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(
                                            replyContent.isEmpty
                                                ? Color.gray
                                                : AppColors.primary
                                        )
                                        .clipShape(Circle())
                                }
                                .disabled(replyContent.isEmpty)
                            }

                            // Replies List
                            let replies = viewModel.getReplies(for: tweet.id)
                            if replies.isEmpty {
                                Text("No replies yet. Be the first!")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.subtext)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(replies) { reply in
                                    ReplyCard(reply: reply)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Tweet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.text)
                    }
                }
            }
        }
    }

    private func sendReply() {
        guard !replyContent.isEmpty else { return }

        let authorId = appState.currentUser?.id.uuidString ?? UUID().uuidString
        let authorName = appState.currentUser?.displayName ?? "Anonymous"
        let authorRole = appState.currentUser?.role ?? .user

        viewModel.replyToTweet(
            parentId: tweet.id,
            content: replyContent,
            authorId: authorId,
            authorName: authorName,
            authorRole: authorRole
        )
        replyContent = ""
    }
}

// MARK: - Reply Card
struct ReplyCard: View {
    let reply: Tweet

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(reply.authorRole.badgeColorValue.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(reply.authorName.prefix(1)))
                        .font(.caption.bold())
                        .foregroundColor(reply.authorRole.badgeColorValue)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(reply.authorName)
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.text)

                    RoleBadgeView(role: reply.authorRole)

                    Text(reply.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Text(reply.content)
                    .font(.subheadline)
                    .foregroundColor(AppColors.text)
            }

            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    TweetTimelineView()
        .environmentObject(AppState())
}
