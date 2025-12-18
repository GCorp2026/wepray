//
//  UserRoleTypes.swift
//  WePray - User Role and Permission Types
//

import Foundation
import SwiftUI

// MARK: - User Role
enum UserRole: String, CaseIterable, Codable {
    case superAdmin = "super_admin"
    case admin = "admin"
    case premium = "premium"
    case user = "user"

    var displayName: String {
        switch self {
        case .superAdmin: return "Super Admin"
        case .admin: return "Admin"
        case .premium: return "Premium"
        case .user: return "User"
        }
    }

    var badgeIcon: String {
        switch self {
        case .superAdmin: return "crown.fill"
        case .admin: return "shield.fill"
        case .premium: return "star.fill"
        case .user: return "person.fill"
        }
    }

    var badgeColor: String {
        switch self {
        case .superAdmin: return "#FFD700"  // Gold
        case .admin: return "#3B82F6"       // Blue
        case .premium: return "#8B5CF6"     // Purple
        case .user: return "#6B7280"        // Gray
        }
    }

    /// Returns the badge color as a SwiftUI Color
    var badgeColorValue: Color {
        Color(hex: badgeColor)
    }

    var permissions: [RolePermission] {
        switch self {
        case .superAdmin:
            return RolePermission.allCases
        case .admin:
            return [.manageUsers, .manageRoles, .manageProducts, .manageCourses,
                    .manageEvents, .manageMeetings, .manageClubs, .manageGroups,
                    .managePrayerCircles, .managePricing, .viewMessages,
                    .viewSchedules, .setCommissions, .viewRevenue, .postTweets]
        case .premium:
            return [.createPrayerCircles, .createGroups, .createEvents,
                    .createMeetings, .viewOwnSchedule, .privateMessaging, .postTweets]
        case .user:
            return [.createProfile, .postTweets, .joinClubs, .joinPrayerCircles,
                    .joinGroups, .bookEvents, .bookMeetings, .privateMessaging]
        }
    }

    var canManageCommissions: Bool {
        self == .superAdmin || self == .admin
    }

    var canViewRevenue: Bool {
        self == .superAdmin || self == .admin
    }

    var canPostTweets: Bool {
        true // All roles can post tweets
    }

    var roleDescription: String {
        switch self {
        case .superAdmin:
            return "Full system access with all permissions"
        case .admin:
            return "Manages users, roles, products, courses, events, meetings, clubs, groups, prayer circles, pricing. Full oversight of messages, schedules, and revenue. Sets commission percentages."
        case .premium:
            return "Creates and manages own prayer circles, groups, events, and meetings. Private messaging and tweet posting."
        case .user:
            return "Standard user with profile, tweets, connections, and ability to join clubs, circles, and groups."
        }
    }
}

// MARK: - Role Permissions
enum RolePermission: String, CaseIterable, Codable {
    // Admin permissions
    case manageUsers = "manage_users"
    case manageRoles = "manage_roles"
    case manageProducts = "manage_products"
    case manageCourses = "manage_courses"
    case manageEvents = "manage_events"
    case manageMeetings = "manage_meetings"
    case manageClubs = "manage_clubs"
    case manageGroups = "manage_groups"
    case managePrayerCircles = "manage_prayer_circles"
    case managePricing = "manage_pricing"
    case viewMessages = "view_messages"
    case viewSchedules = "view_schedules"
    case setCommissions = "set_commissions"
    case viewRevenue = "view_revenue"

    // Premium permissions
    case createPrayerCircles = "create_prayer_circles"
    case createGroups = "create_groups"
    case createEvents = "create_events"
    case createMeetings = "create_meetings"
    case viewOwnSchedule = "view_own_schedule"

    // User permissions
    case createProfile = "create_profile"
    case postTweets = "post_tweets"
    case joinClubs = "join_clubs"
    case joinPrayerCircles = "join_prayer_circles"
    case joinGroups = "join_groups"
    case bookEvents = "book_events"
    case bookMeetings = "book_meetings"
    case privateMessaging = "private_messaging"

    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var icon: String {
        switch self {
        case .manageUsers: return "person.3.fill"
        case .manageRoles: return "person.badge.key.fill"
        case .manageProducts: return "shippingbox.fill"
        case .manageCourses: return "book.fill"
        case .manageEvents: return "calendar.badge.plus"
        case .manageMeetings: return "video.fill"
        case .manageClubs: return "person.3.sequence.fill"
        case .manageGroups: return "rectangle.3.group.fill"
        case .managePrayerCircles: return "hands.sparkles.fill"
        case .managePricing: return "dollarsign.circle.fill"
        case .viewMessages: return "message.fill"
        case .viewSchedules: return "calendar"
        case .setCommissions: return "percent"
        case .viewRevenue: return "chart.bar.fill"
        case .createPrayerCircles: return "hands.sparkles"
        case .createGroups: return "rectangle.3.group"
        case .createEvents: return "calendar.badge.plus"
        case .createMeetings: return "video"
        case .viewOwnSchedule: return "calendar"
        case .createProfile: return "person.crop.circle.badge.plus"
        case .postTweets: return "text.bubble"
        case .joinClubs: return "person.3"
        case .joinPrayerCircles: return "hands.sparkles"
        case .joinGroups: return "rectangle.3.group"
        case .bookEvents: return "calendar.badge.checkmark"
        case .bookMeetings: return "video.badge.checkmark"
        case .privateMessaging: return "envelope.fill"
        }
    }
}

// MARK: - Commission Settings
struct CommissionSettings: Codable {
    var premiumUserCommission: Double = 15.0  // Percentage
    var regularUserCommission: Double = 20.0  // Percentage

    static let `default` = CommissionSettings()
}

// MARK: - Revenue Stats
struct RevenueStats: Codable {
    var totalRevenue: Double = 0.0
    var premiumUserRevenue: Double = 0.0
    var regularUserRevenue: Double = 0.0
    var commissionsEarned: Double = 0.0
    var period: String = "all_time"

    var formattedTotalRevenue: String {
        String(format: "$%.2f", totalRevenue)
    }

    var formattedCommissions: String {
        String(format: "$%.2f", commissionsEarned)
    }
}
