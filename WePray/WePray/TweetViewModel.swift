//
//  TweetViewModel.swift
//  WePray - Tweet Management ViewModel
//

import SwiftUI

class TweetViewModel: ObservableObject {
    @Published var tweets: [Tweet] = []
    @Published var isLoading = false
    @Published var selectedFilter: TweetFilter = .all
    @Published var selectedSort: TweetSort = .newest

    private let userDefaultsKey = "WePrayTweets"
    private var currentUserId: String = ""

    init() {
        loadTweets()
    }

    // MARK: - Load Tweets
    func loadTweets() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedTweets = try? JSONDecoder().decode([Tweet].self, from: data) {
            tweets = decodedTweets
        } else {
            tweets = Tweet.sampleTweets
            saveTweets()
        }
    }

    // MARK: - Save Tweets
    private func saveTweets() {
        if let encodedData = try? JSONEncoder().encode(tweets) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }

    // MARK: - Post Tweet
    func postTweet(content: String, authorId: String, authorName: String, authorRole: UserRole) {
        let newTweet = Tweet(
            authorId: authorId,
            authorName: authorName,
            authorRole: authorRole,
            content: content,
            timestamp: Date()
        )
        tweets.insert(newTweet, at: 0)
        saveTweets()
    }

    // MARK: - Like Tweet
    func likeTweet(tweetId: UUID) {
        if let index = tweets.firstIndex(where: { $0.id == tweetId }) {
            tweets[index].isLiked.toggle()
            tweets[index].likes += tweets[index].isLiked ? 1 : -1
            saveTweets()
        }
    }

    // MARK: - Retweet
    func retweetTweet(tweetId: UUID) {
        if let index = tweets.firstIndex(where: { $0.id == tweetId }) {
            tweets[index].isRetweeted.toggle()
            tweets[index].retweets += tweets[index].isRetweeted ? 1 : -1
            saveTweets()
        }
    }

    // MARK: - Delete Tweet
    func deleteTweet(tweetId: UUID) {
        tweets.removeAll { $0.id == tweetId }
        saveTweets()
    }

    // MARK: - Reply to Tweet
    func replyToTweet(parentId: UUID, content: String, authorId: String, authorName: String, authorRole: UserRole) {
        let reply = Tweet(
            authorId: authorId,
            authorName: authorName,
            authorRole: authorRole,
            content: content,
            timestamp: Date(),
            parentTweetId: parentId
        )
        tweets.insert(reply, at: 0)

        // Increment reply count on parent
        if let index = tweets.firstIndex(where: { $0.id == parentId }) {
            tweets[index].replyCount += 1
        }
        saveTweets()
    }

    // MARK: - Filtered Tweets
    var filteredTweets: [Tweet] {
        var result = tweets.filter { $0.parentTweetId == nil }  // Only top-level tweets

        switch selectedFilter {
        case .all:
            break
        case .following:
            // In a real app, filter by followed users
            break
        case .trending:
            result = result.filter { $0.likes > 50 || $0.retweets > 20 }
        case .myTweets:
            result = result.filter { $0.authorId == currentUserId }
        }

        return sortedTweets(result)
    }

    // MARK: - Sorted Tweets
    private func sortedTweets(_ tweets: [Tweet]) -> [Tweet] {
        switch selectedSort {
        case .newest:
            return tweets.sorted { $0.timestamp > $1.timestamp }
        case .oldest:
            return tweets.sorted { $0.timestamp < $1.timestamp }
        case .mostLiked:
            return tweets.sorted { $0.likes > $1.likes }
        case .mostRetweeted:
            return tweets.sorted { $0.retweets > $1.retweets }
        }
    }

    // MARK: - Get Replies for Tweet
    func getReplies(for tweetId: UUID) -> [Tweet] {
        tweets.filter { $0.parentTweetId == tweetId }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Set Current User
    func setCurrentUser(id: String) {
        currentUserId = id
    }

    // MARK: - Refresh
    func refresh() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadTweets()
            self?.isLoading = false
        }
    }
}
