//
//  TweetTypes.swift
//  WePray - Tweet/Timeline Data Models
//

import SwiftUI

// MARK: - Tweet Model
struct Tweet: Identifiable, Codable {
    var id = UUID()
    let authorId: String
    let authorName: String
    let authorRole: UserRole
    let content: String
    let timestamp: Date
    var likes: Int
    var retweets: Int
    var replyCount: Int
    var isLiked: Bool
    var isRetweeted: Bool
    var parentTweetId: UUID?  // For replies

    init(id: UUID = UUID(), authorId: String, authorName: String, authorRole: UserRole,
         content: String, timestamp: Date = Date(), likes: Int = 0, retweets: Int = 0,
         replyCount: Int = 0, isLiked: Bool = false, isRetweeted: Bool = false,
         parentTweetId: UUID? = nil) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorRole = authorRole
        self.content = content
        self.timestamp = timestamp
        self.likes = likes
        self.retweets = retweets
        self.replyCount = replyCount
        self.isLiked = isLiked
        self.isRetweeted = isRetweeted
        self.parentTweetId = parentTweetId
    }
}

// MARK: - Tweet Author
struct TweetAuthor: Identifiable, Codable {
    let id: String
    let name: String
    let role: UserRole
    var avatarInitial: String { String(name.prefix(1)) }
    var followersCount: Int
    var followingCount: Int
    var tweetCount: Int

    init(id: String, name: String, role: UserRole, followersCount: Int = 0,
         followingCount: Int = 0, tweetCount: Int = 0) {
        self.id = id
        self.name = name
        self.role = role
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.tweetCount = tweetCount
    }
}

// MARK: - Tweet Filter Options
enum TweetFilter: String, CaseIterable {
    case all = "All"
    case following = "Following"
    case trending = "Trending"
    case myTweets = "My Tweets"

    var icon: String {
        switch self {
        case .all: return "globe"
        case .following: return "person.2"
        case .trending: return "flame"
        case .myTweets: return "person"
        }
    }
}

// MARK: - Tweet Sort Options
enum TweetSort: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case mostLiked = "Most Liked"
    case mostRetweeted = "Most Retweeted"

    var icon: String {
        switch self {
        case .newest: return "clock"
        case .oldest: return "clock.arrow.circlepath"
        case .mostLiked: return "heart.fill"
        case .mostRetweeted: return "arrow.2.squarepath"
        }
    }
}

// MARK: - Sample Data
extension Tweet {
    static let sampleTweets: [Tweet] = [
        Tweet(
            authorId: "superAdmin123",
            authorName: "Sarah Miller",
            authorRole: .superAdmin,
            content: "Welcome to WePray! This is a space for sharing prayers and supporting one another. Let's build a community of faith together. #WePray #Community",
            timestamp: Date().addingTimeInterval(-86400 * 3),
            likes: 125,
            retweets: 42,
            replyCount: 18
        ),
        Tweet(
            authorId: "admin456",
            authorName: "David Chen",
            authorRole: .admin,
            content: "Announcing our next community prayer event! Join us this Sunday at 7 PM. All are welcome. #PrayerEvent #Community",
            timestamp: Date().addingTimeInterval(-86400 * 2),
            likes: 88,
            retweets: 28,
            replyCount: 12,
            isLiked: true
        ),
        Tweet(
            authorId: "premium789",
            authorName: "Emily Rodriguez",
            authorRole: .premium,
            content: "My heart goes out to all those affected by the recent events. Praying for strength, healing, and peace for everyone. God is with us always. #Prayers",
            timestamp: Date().addingTimeInterval(-86400),
            likes: 150,
            retweets: 65,
            replyCount: 24,
            isLiked: true,
            isRetweeted: true
        ),
        Tweet(
            authorId: "user101",
            authorName: "Michael Brown",
            authorRole: .user,
            content: "Praying for my family and friends who are going through tough times. Your prayers mean so much. #WePrayTogether",
            timestamp: Date().addingTimeInterval(-3600 * 6),
            likes: 32,
            retweets: 5,
            replyCount: 8
        ),
        Tweet(
            authorId: "user202",
            authorName: "Jessica Lee",
            authorRole: .user,
            content: "Starting my day with gratitude and prayer. Thankful for all the blessings in my life. What are you grateful for today? #Blessed #Gratitude",
            timestamp: Date().addingTimeInterval(-3600 * 2),
            likes: 67,
            retweets: 12,
            replyCount: 15,
            isLiked: true
        ),
        Tweet(
            authorId: "admin456",
            authorName: "David Chen",
            authorRole: .admin,
            content: "Remember: \"Be joyful in hope, patient in affliction, faithful in prayer.\" - Romans 12:12 #Scripture #Faith",
            timestamp: Date().addingTimeInterval(-3600),
            likes: 94,
            retweets: 38,
            replyCount: 7
        ),
        Tweet(
            authorId: "user303",
            authorName: "Grace Thompson",
            authorRole: .user,
            content: "Prayer request: Please pray for my grandmother's surgery tomorrow. We trust in God's healing hands. #PrayerRequest",
            timestamp: Date().addingTimeInterval(-1800),
            likes: 45,
            retweets: 8,
            replyCount: 22
        ),
        Tweet(
            authorId: "premium404",
            authorName: "James Wilson",
            authorRole: .premium,
            content: "Just finished 30 days of continuous prayer journaling. The growth has been incredible! Highly recommend starting a prayer journal. #PrayerJourney",
            timestamp: Date().addingTimeInterval(-900),
            likes: 78,
            retweets: 25,
            replyCount: 11
        )
    ]
}

extension TweetAuthor {
    static let sampleAuthors: [TweetAuthor] = [
        TweetAuthor(id: "superAdmin123", name: "Sarah Miller", role: .superAdmin, followersCount: 1250, followingCount: 85, tweetCount: 342),
        TweetAuthor(id: "admin456", name: "David Chen", role: .admin, followersCount: 890, followingCount: 120, tweetCount: 215),
        TweetAuthor(id: "premium789", name: "Emily Rodriguez", role: .premium, followersCount: 456, followingCount: 234, tweetCount: 128),
        TweetAuthor(id: "user101", name: "Michael Brown", role: .user, followersCount: 87, followingCount: 156, tweetCount: 45),
        TweetAuthor(id: "user202", name: "Jessica Lee", role: .user, followersCount: 234, followingCount: 189, tweetCount: 89),
        TweetAuthor(id: "user303", name: "Grace Thompson", role: .user, followersCount: 156, followingCount: 98, tweetCount: 67),
        TweetAuthor(id: "premium404", name: "James Wilson", role: .premium, followersCount: 567, followingCount: 145, tweetCount: 198)
    ]
}
