//
//  ClubTypes.swift
//  WePray - Club Management Types
//

import SwiftUI

// MARK: - Club Category
enum ClubCategory: String, CaseIterable, Codable {
    case prayer = "Prayer"
    case study = "Bible Study"
    case worship = "Worship"
    case fellowship = "Fellowship"
    case missions = "Missions"
    case youth = "Youth"
    case women = "Women"
    case men = "Men"
    case seniors = "Seniors"
    case family = "Family"

    var icon: String {
        switch self {
        case .prayer: return "hands.sparkles.fill"
        case .study: return "book.closed.fill"
        case .worship: return "music.note.house.fill"
        case .fellowship: return "person.3.fill"
        case .missions: return "globe.americas.fill"
        case .youth: return "figure.run"
        case .women: return "figure.dress.line.vertical.figure"
        case .men: return "figure.stand"
        case .seniors: return "figure.roll"
        case .family: return "house.fill"
        }
    }

    var color: Color {
        switch self {
        case .prayer: return Color(hex: "#3B82F6")
        case .study: return Color(hex: "#10B981")
        case .worship: return Color(hex: "#8B5CF6")
        case .fellowship: return Color(hex: "#F59E0B")
        case .missions: return Color(hex: "#EF4444")
        case .youth: return Color(hex: "#06B6D4")
        case .women: return Color(hex: "#EC4899")
        case .men: return Color(hex: "#6B7280")
        case .seniors: return Color(hex: "#92400E")
        case .family: return Color(hex: "#14B8A6")
        }
    }
}

// MARK: - Club Member Role
enum ClubMemberRole: String, CaseIterable, Codable {
    case owner = "Owner"
    case admin = "Admin"
    case moderator = "Moderator"
    case member = "Member"

    var icon: String {
        switch self {
        case .owner: return "crown.fill"
        case .admin: return "star.fill"
        case .moderator: return "shield.fill"
        case .member: return "person.fill"
        }
    }

    var color: Color {
        switch self {
        case .owner: return Color(hex: "#FFD700")
        case .admin: return Color(hex: "#3B82F6")
        case .moderator: return Color(hex: "#8B5CF6")
        case .member: return Color(hex: "#6B7280")
        }
    }

    var canInvite: Bool { self != .member }
    var canRemoveMembers: Bool { self == .owner || self == .admin }
    var canApproveRequests: Bool { self != .member }
    var canEditClub: Bool { self == .owner || self == .admin }
    var canDeleteClub: Bool { self == .owner }
}

// MARK: - Club Member
struct ClubMember: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let userId: String
    let userName: String
    let userInitials: String
    let userRole: UserRole
    var clubRole: ClubMemberRole
    let joinedAt: Date

    static func == (lhs: ClubMember, rhs: ClubMember) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Club Member Request Status
enum MemberRequestStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

// MARK: - Club Member Request
struct ClubMemberRequest: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let userId: String
    let userName: String
    let userInitials: String
    let userRole: UserRole
    var message: String
    let requestedAt: Date
    var status: MemberRequestStatus = .pending

    static func == (lhs: ClubMemberRequest, rhs: ClubMemberRequest) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Club Invitation Status
enum InvitationStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
}

// MARK: - Club Invitation
struct ClubInvitation: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let clubId: UUID
    let clubName: String
    let invitedBy: String
    let invitedByName: String
    let invitedUserId: String
    let invitedAt: Date
    var status: InvitationStatus = .pending

    static func == (lhs: ClubInvitation, rhs: ClubInvitation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Club Filter
enum ClubFilter: String, CaseIterable {
    case all = "All"
    case myClubs = "My Clubs"
    case publicClubs = "Public"
    case privateClubs = "Private"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .myClubs: return "person.crop.circle.fill"
        case .publicClubs: return "globe"
        case .privateClubs: return "lock.fill"
        }
    }
}

// MARK: - Club Model
struct Club: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var category: ClubCategory
    var iconName: String
    var gradientColors: [String]
    var isPublic: Bool
    var memberCount: Int
    let createdBy: String
    let createdByName: String
    let createdAt: Date
    var members: [ClubMember]
    var pendingRequests: [ClubMemberRequest]

    static func == (lhs: Club, rhs: Club) -> Bool {
        lhs.id == rhs.id
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func isMember(userId: String) -> Bool {
        members.contains { $0.userId == userId }
    }

    func getMemberRole(userId: String) -> ClubMemberRole? {
        members.first { $0.userId == userId }?.clubRole
    }

    static let sampleClubs: [Club] = [
        Club(
            name: "Morning Prayer Warriors",
            description: "Join us every morning at 6 AM for powerful prayer sessions.",
            category: .prayer,
            iconName: "sun.max.fill",
            gradientColors: ["#1E3A8A", "#3B82F6"],
            isPublic: true,
            memberCount: 156,
            createdBy: "user1",
            createdByName: "Sarah Mitchell",
            createdAt: Date(timeIntervalSinceNow: -86400 * 90),
            members: ClubMember.sampleMembers,
            pendingRequests: ClubMemberRequest.sampleRequests
        ),
        Club(
            name: "Women of Faith",
            description: "A private community for women seeking spiritual growth.",
            category: .women,
            iconName: "heart.circle.fill",
            gradientColors: ["#831843", "#EC4899"],
            isPublic: false,
            memberCount: 89,
            createdBy: "user2",
            createdByName: "Grace Lee",
            createdAt: Date(timeIntervalSinceNow: -86400 * 60),
            members: [],
            pendingRequests: []
        ),
        Club(
            name: "Youth on Fire",
            description: "Young believers igniting faith through worship and fellowship.",
            category: .youth,
            iconName: "flame.fill",
            gradientColors: ["#0891B2", "#06B6D4"],
            isPublic: true,
            memberCount: 234,
            createdBy: "user3",
            createdByName: "Michael Chen",
            createdAt: Date(timeIntervalSinceNow: -86400 * 45),
            members: [],
            pendingRequests: []
        ),
        Club(
            name: "Bible Study Group",
            description: "Deep dive into Scripture every Wednesday evening.",
            category: .study,
            iconName: "book.closed.fill",
            gradientColors: ["#065F46", "#10B981"],
            isPublic: true,
            memberCount: 67,
            createdBy: "user4",
            createdByName: "Pastor James",
            createdAt: Date(timeIntervalSinceNow: -86400 * 120),
            members: [],
            pendingRequests: []
        )
    ]
}

// MARK: - Sample Data Extensions
extension ClubMember {
    static let sampleMembers: [ClubMember] = [
        ClubMember(userId: "user1", userName: "Sarah Mitchell", userInitials: "SM", userRole: .premium, clubRole: .owner, joinedAt: Date(timeIntervalSinceNow: -86400 * 90)),
        ClubMember(userId: "user5", userName: "David Kim", userInitials: "DK", userRole: .user, clubRole: .admin, joinedAt: Date(timeIntervalSinceNow: -86400 * 80)),
        ClubMember(userId: "user6", userName: "Emily Rose", userInitials: "ER", userRole: .user, clubRole: .moderator, joinedAt: Date(timeIntervalSinceNow: -86400 * 70)),
        ClubMember(userId: "user7", userName: "John Adams", userInitials: "JA", userRole: .user, clubRole: .member, joinedAt: Date(timeIntervalSinceNow: -86400 * 30))
    ]
}

extension ClubMemberRequest {
    static let sampleRequests: [ClubMemberRequest] = [
        ClubMemberRequest(userId: "user8", userName: "Anna Williams", userInitials: "AW", userRole: .user, message: "I'd love to join this prayer group!", requestedAt: Date(timeIntervalSinceNow: -3600 * 12)),
        ClubMemberRequest(userId: "user9", userName: "Robert Johnson", userInitials: "RJ", userRole: .premium, message: "Looking forward to growing in faith with you all.", requestedAt: Date(timeIntervalSinceNow: -86400))
    ]
}
