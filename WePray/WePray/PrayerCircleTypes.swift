import SwiftUI

// MARK: - Prayer Circle Model

struct PrayerCircle: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let category: CircleCategory
    var memberCount: Int
    let iconName: String
    let gradientColors: [String]
    var isJoined: Bool
    var isPrivate: Bool
    let createdBy: String
    let createdAt: Date
    var nextMeeting: CircleMeeting?
    var prayerRequests: [CirclePrayerRequest]
    var members: [CircleMember]

    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let sampleCircles: [PrayerCircle] = [
        PrayerCircle(
            name: "Moms Praying for Kids",
            description: "A supportive circle for mothers praying for their children's spiritual growth, safety, and success.",
            category: .family,
            memberCount: 45,
            iconName: "heart.circle.fill",
            gradientColors: ["#1E3A8A", "#EC4899"],
            isJoined: true,
            isPrivate: false,
            createdBy: "Sarah M.",
            createdAt: Date().addingTimeInterval(-86400 * 30),
            nextMeeting: CircleMeeting.sampleMeeting,
            prayerRequests: CirclePrayerRequest.sampleRequests,
            members: CircleMember.sampleMembers
        ),
        PrayerCircle(
            name: "Healing & Recovery",
            description: "Dedicated prayers for those battling illness, recovering from surgery, or seeking physical and emotional healing.",
            category: .healing,
            memberCount: 78,
            iconName: "cross.circle.fill",
            gradientColors: ["#0D47A1", "#4CAF50"],
            isJoined: false,
            isPrivate: false,
            createdBy: "Pastor James",
            createdAt: Date().addingTimeInterval(-86400 * 60),
            nextMeeting: nil,
            prayerRequests: [],
            members: []
        ),
        PrayerCircle(
            name: "Young Professionals",
            description: "Prayers for career guidance, work-life balance, and faith in the workplace.",
            category: .career,
            memberCount: 34,
            iconName: "briefcase.circle.fill",
            gradientColors: ["#1565C0", "#FFC107"],
            isJoined: false,
            isPrivate: false,
            createdBy: "Michael T.",
            createdAt: Date().addingTimeInterval(-86400 * 15),
            nextMeeting: nil,
            prayerRequests: [],
            members: []
        ),
        PrayerCircle(
            name: "Marriage & Relationships",
            description: "Supporting couples through prayer for stronger marriages and healthy relationships.",
            category: .relationships,
            memberCount: 56,
            iconName: "person.2.circle.fill",
            gradientColors: ["#283593", "#E91E63"],
            isJoined: true,
            isPrivate: true,
            createdBy: "David & Lisa",
            createdAt: Date().addingTimeInterval(-86400 * 45),
            nextMeeting: nil,
            prayerRequests: [],
            members: []
        )
    ]
}

// MARK: - Circle Category

enum CircleCategory: String, CaseIterable, Codable {
    case family = "Family"
    case healing = "Healing"
    case career = "Career"
    case relationships = "Relationships"
    case faith = "Faith Growth"
    case community = "Community"
    case youth = "Youth"
    case seniors = "Seniors"
    case missions = "Missions"
    case gratitude = "Gratitude"

    var icon: String {
        switch self {
        case .family: return "house.fill"
        case .healing: return "heart.fill"
        case .career: return "briefcase.fill"
        case .relationships: return "person.2.fill"
        case .faith: return "book.fill"
        case .community: return "person.3.fill"
        case .youth: return "sparkles"
        case .seniors: return "figure.stand"
        case .missions: return "globe.americas.fill"
        case .gratitude: return "hands.clap.fill"
        }
    }

    var color: Color {
        switch self {
        case .family: return Color(hex: "#EC4899")
        case .healing: return Color(hex: "#4CAF50")
        case .career: return Color(hex: "#FFC107")
        case .relationships: return Color(hex: "#E91E63")
        case .faith: return Color(hex: "#3B82F6")
        case .community: return Color(hex: "#8B5CF6")
        case .youth: return Color(hex: "#06B6D4")
        case .seniors: return Color(hex: "#F59E0B")
        case .missions: return Color(hex: "#10B981")
        case .gratitude: return Color(hex: "#F97316")
        }
    }
}

// MARK: - Circle Meeting

struct CircleMeeting: Identifiable, Codable, Equatable {
    var id = UUID()
    let title: String
    let scheduledDate: Date
    let duration: Int // minutes
    let meetingLink: String
    let isRecurring: Bool
    let recurrenceType: RecurrenceType?
    let hostName: String
    let description: String
    var attendees: [String]

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scheduledDate)
    }

    var formattedDuration: String {
        if duration >= 60 {
            let hours = duration / 60
            let mins = duration % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(duration) min"
    }

    var isUpcoming: Bool {
        scheduledDate > Date()
    }

    static let sampleMeeting = CircleMeeting(
        title: "Weekly Prayer Call",
        scheduledDate: Date().addingTimeInterval(86400 * 2),
        duration: 30,
        meetingLink: "https://meet.example.com/prayer-circle",
        isRecurring: true,
        recurrenceType: .weekly,
        hostName: "Sarah M.",
        description: "Join us for our weekly prayer time together.",
        attendees: ["Sarah M.", "Jennifer L.", "Amanda K."]
    )
}

enum RecurrenceType: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"

    var icon: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .biweekly: return "calendar"
        case .monthly: return "calendar.circle"
        }
    }
}

// MARK: - Circle Prayer Request

struct CirclePrayerRequest: Identifiable, Codable, Equatable {
    var id = UUID()
    let authorName: String
    let authorInitials: String
    let content: String
    let submittedAt: Date
    var status: RequestStatus
    var prayerCount: Int
    var hasPrayed: Bool
    let isUrgent: Bool
    var responses: [CirclePrayerResponse]

    var timeAgo: String {
        let interval = Date().timeIntervalSince(submittedAt)
        if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }

    static let sampleRequests: [CirclePrayerRequest] = [
        CirclePrayerRequest(
            authorName: "Jennifer L.",
            authorInitials: "JL",
            content: "Please pray for my son's college entrance exams next week. He's been studying hard but feeling anxious.",
            submittedAt: Date().addingTimeInterval(-3600 * 5),
            status: .active,
            prayerCount: 12,
            hasPrayed: true,
            isUrgent: true,
            responses: []
        ),
        CirclePrayerRequest(
            authorName: "Amanda K.",
            authorInitials: "AK",
            content: "Grateful update - my daughter got accepted to her first choice school! Thank you all for your prayers!",
            submittedAt: Date().addingTimeInterval(-86400),
            status: .answered,
            prayerCount: 24,
            hasPrayed: false,
            isUrgent: false,
            responses: []
        )
    ]
}

enum RequestStatus: String, CaseIterable, Codable {
    case active = "Active"
    case answered = "Answered"
    case ongoing = "Ongoing"

    var color: Color {
        switch self {
        case .active: return .blue
        case .answered: return .green
        case .ongoing: return .orange
        }
    }

    var icon: String {
        switch self {
        case .active: return "hands.sparkles.fill"
        case .answered: return "checkmark.circle.fill"
        case .ongoing: return "arrow.clockwise"
        }
    }
}

// MARK: - Circle Prayer Response

struct CirclePrayerResponse: Identifiable, Codable, Equatable {
    var id = UUID()
    let authorName: String
    let content: String
    let submittedAt: Date
}

// MARK: - Circle Member

struct CircleMember: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let initials: String
    let role: MemberRole
    let joinedAt: Date
    var prayerCount: Int

    static let sampleMembers: [CircleMember] = [
        CircleMember(name: "Sarah M.", initials: "SM", role: .leader, joinedAt: Date().addingTimeInterval(-86400 * 30), prayerCount: 156),
        CircleMember(name: "Jennifer L.", initials: "JL", role: .member, joinedAt: Date().addingTimeInterval(-86400 * 25), prayerCount: 89),
        CircleMember(name: "Amanda K.", initials: "AK", role: .member, joinedAt: Date().addingTimeInterval(-86400 * 20), prayerCount: 67),
        CircleMember(name: "Rachel T.", initials: "RT", role: .moderator, joinedAt: Date().addingTimeInterval(-86400 * 28), prayerCount: 124)
    ]
}

enum MemberRole: String, CaseIterable, Codable {
    case leader = "Leader"
    case moderator = "Moderator"
    case member = "Member"

    var color: Color {
        switch self {
        case .leader: return .yellow
        case .moderator: return .purple
        case .member: return .blue
        }
    }

    var icon: String {
        switch self {
        case .leader: return "star.fill"
        case .moderator: return "shield.fill"
        case .member: return "person.fill"
        }
    }
}
