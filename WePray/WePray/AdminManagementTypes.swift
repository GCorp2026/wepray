//
//  AdminManagementTypes.swift
//  WePray - Admin Management Data Models
//

import SwiftUI

// MARK: - Managed User
struct ManagedUser: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var role: UserRole
    var status: UserStatus
    var joinDate: Date
    var lastActive: Date
    var prayerCount: Int
    var connectionsCount: Int
    var isVerified: Bool
    var isSuspended: Bool
    var suspensionReason: String?

    init(id: UUID = UUID(), name: String, email: String, role: UserRole = .user, status: UserStatus = .active,
         joinDate: Date = Date(), lastActive: Date = Date(), prayerCount: Int = 0, connectionsCount: Int = 0,
         isVerified: Bool = false, isSuspended: Bool = false, suspensionReason: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.status = status
        self.joinDate = joinDate
        self.lastActive = lastActive
        self.prayerCount = prayerCount
        self.connectionsCount = connectionsCount
        self.isVerified = isVerified
        self.isSuspended = isSuspended
        self.suspensionReason = suspensionReason
    }

    var initials: String {
        String(name.prefix(2)).uppercased()
    }
}

// MARK: - User Status
enum UserStatus: String, CaseIterable, Codable {
    case active = "Active"
    case inactive = "Inactive"
    case suspended = "Suspended"
    case pending = "Pending"

    var color: Color {
        switch self {
        case .active: return Color(hex: "#10B981")
        case .inactive: return Color(hex: "#6B7280")
        case .suspended: return Color(hex: "#EF4444")
        case .pending: return Color(hex: "#F59E0B")
        }
    }

    var icon: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .inactive: return "minus.circle.fill"
        case .suspended: return "xmark.circle.fill"
        case .pending: return "clock.fill"
        }
    }
}

// MARK: - Commission Settings
struct CommissionSettings: Codable, Equatable {
    var premiumCommissionRate: Double
    var userReferralRate: Double
    var eventHostingRate: Double
    var contentCreatorRate: Double
    var minimumPayout: Double
    var payoutSchedule: PayoutSchedule
    var updatedAt: Date

    init(premiumCommissionRate: Double = 0.15, userReferralRate: Double = 0.10,
         eventHostingRate: Double = 0.20, contentCreatorRate: Double = 0.25,
         minimumPayout: Double = 50.0, payoutSchedule: PayoutSchedule = .monthly,
         updatedAt: Date = Date()) {
        self.premiumCommissionRate = premiumCommissionRate
        self.userReferralRate = userReferralRate
        self.eventHostingRate = eventHostingRate
        self.contentCreatorRate = contentCreatorRate
        self.minimumPayout = minimumPayout
        self.payoutSchedule = payoutSchedule
        self.updatedAt = updatedAt
    }
}

// MARK: - Payout Schedule
enum PayoutSchedule: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
}

// MARK: - Revenue Stats
struct RevenueStats: Codable, Equatable {
    var totalRevenue: Double
    var monthlyRevenue: Double
    var subscriptionRevenue: Double
    var eventRevenue: Double
    var donationRevenue: Double
    var totalPayouts: Double
    var pendingPayouts: Double
    var activeSubscribers: Int
    var newSubscribersThisMonth: Int
    var churnRate: Double
    var averageRevenuePerUser: Double

    init(totalRevenue: Double = 0, monthlyRevenue: Double = 0, subscriptionRevenue: Double = 0,
         eventRevenue: Double = 0, donationRevenue: Double = 0, totalPayouts: Double = 0,
         pendingPayouts: Double = 0, activeSubscribers: Int = 0, newSubscribersThisMonth: Int = 0,
         churnRate: Double = 0, averageRevenuePerUser: Double = 0) {
        self.totalRevenue = totalRevenue
        self.monthlyRevenue = monthlyRevenue
        self.subscriptionRevenue = subscriptionRevenue
        self.eventRevenue = eventRevenue
        self.donationRevenue = donationRevenue
        self.totalPayouts = totalPayouts
        self.pendingPayouts = pendingPayouts
        self.activeSubscribers = activeSubscribers
        self.newSubscribersThisMonth = newSubscribersThisMonth
        self.churnRate = churnRate
        self.averageRevenuePerUser = averageRevenuePerUser
    }
}

// MARK: - Content Report
struct ContentReport: Identifiable, Codable, Equatable {
    let id: UUID
    var contentType: ContentType
    var contentId: String
    var reporterId: String
    var reporterName: String
    var reason: ReportReason
    var description: String
    var status: ReportStatus
    var createdAt: Date
    var resolvedAt: Date?
    var resolvedBy: String?

    init(id: UUID = UUID(), contentType: ContentType, contentId: String, reporterId: String,
         reporterName: String, reason: ReportReason, description: String, status: ReportStatus = .pending,
         createdAt: Date = Date(), resolvedAt: Date? = nil, resolvedBy: String? = nil) {
        self.id = id
        self.contentType = contentType
        self.contentId = contentId
        self.reporterId = reporterId
        self.reporterName = reporterName
        self.reason = reason
        self.description = description
        self.status = status
        self.createdAt = createdAt
        self.resolvedAt = resolvedAt
        self.resolvedBy = resolvedBy
    }
}

// MARK: - Content Type
enum ContentType: String, CaseIterable, Codable {
    case tweet = "Tweet"
    case prayer = "Prayer"
    case message = "Message"
    case profile = "Profile"
    case event = "Event"
    case testimony = "Testimony"

    var icon: String {
        switch self {
        case .tweet: return "bubble.left.fill"
        case .prayer: return "hands.sparkles.fill"
        case .message: return "message.fill"
        case .profile: return "person.fill"
        case .event: return "calendar"
        case .testimony: return "heart.fill"
        }
    }
}

// MARK: - Report Reason
enum ReportReason: String, CaseIterable, Codable {
    case spam = "Spam"
    case inappropriate = "Inappropriate Content"
    case harassment = "Harassment"
    case misinformation = "Misinformation"
    case copyright = "Copyright Violation"
    case other = "Other"
}

// MARK: - Report Status
enum ReportStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case reviewing = "Under Review"
    case resolved = "Resolved"
    case dismissed = "Dismissed"

    var color: Color {
        switch self {
        case .pending: return Color(hex: "#F59E0B")
        case .reviewing: return Color(hex: "#3B82F6")
        case .resolved: return Color(hex: "#10B981")
        case .dismissed: return Color(hex: "#6B7280")
        }
    }
}

// MARK: - Sample Data
extension ManagedUser {
    static let sampleUsers: [ManagedUser] = [
        ManagedUser(name: "John Smith", email: "john@email.com", role: .premium, status: .active, prayerCount: 156, connectionsCount: 89, isVerified: true),
        ManagedUser(name: "Sarah Johnson", email: "sarah@email.com", role: .user, status: .active, prayerCount: 45, connectionsCount: 23),
        ManagedUser(name: "Mike Brown", email: "mike@email.com", role: .user, status: .inactive, prayerCount: 12, connectionsCount: 5),
        ManagedUser(name: "Emily Davis", email: "emily@email.com", role: .admin, status: .active, prayerCount: 234, connectionsCount: 156, isVerified: true),
        ManagedUser(name: "David Wilson", email: "david@email.com", role: .user, status: .suspended, isSuspended: true, suspensionReason: "Policy violation")
    ]
}

extension RevenueStats {
    static let sample = RevenueStats(
        totalRevenue: 125000, monthlyRevenue: 12500, subscriptionRevenue: 9500,
        eventRevenue: 2000, donationRevenue: 1000, totalPayouts: 18750,
        pendingPayouts: 3125, activeSubscribers: 450, newSubscribersThisMonth: 32,
        churnRate: 2.5, averageRevenuePerUser: 27.78
    )
}
