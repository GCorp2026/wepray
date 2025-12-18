//
//  AdminUserTypes.swift
//  WePray - Admin User Management Types
//

import SwiftUI

// MARK: - Account Status
enum AccountStatus: String, Codable, CaseIterable {
    case active
    case pending
    case suspended
    case banned

    var displayName: String {
        switch self {
        case .active: return "Active"
        case .pending: return "Pending"
        case .suspended: return "Suspended"
        case .banned: return "Banned"
        }
    }

    var icon: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .pending: return "clock.fill"
        case .suspended: return "pause.circle.fill"
        case .banned: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .active: return .green
        case .pending: return .orange
        case .suspended: return .yellow
        case .banned: return .red
        }
    }
}

// MARK: - User Action
enum UserAction: String, CaseIterable {
    case approve
    case promote
    case demote
    case suspend
    case unsuspend
    case ban
    case unban
    case delete
    case resetPassword

    var displayName: String {
        switch self {
        case .approve: return "Approve"
        case .promote: return "Promote"
        case .demote: return "Demote"
        case .suspend: return "Suspend"
        case .unsuspend: return "Unsuspend"
        case .ban: return "Ban"
        case .unban: return "Unban"
        case .delete: return "Delete"
        case .resetPassword: return "Reset Password"
        }
    }

    var icon: String {
        switch self {
        case .approve: return "checkmark.circle"
        case .promote: return "arrow.up.circle"
        case .demote: return "arrow.down.circle"
        case .suspend: return "pause.circle"
        case .unsuspend: return "play.circle"
        case .ban: return "xmark.circle"
        case .unban: return "arrow.uturn.backward.circle"
        case .delete: return "trash"
        case .resetPassword: return "key"
        }
    }

    var color: Color {
        switch self {
        case .approve: return .green
        case .promote: return .blue
        case .demote: return .orange
        case .suspend: return .yellow
        case .unsuspend: return .green
        case .ban, .delete: return .red
        case .unban: return .blue
        case .resetPassword: return .purple
        }
    }

    var isDestructive: Bool {
        self == .ban || self == .delete || self == .suspend
    }
}

// MARK: - User Filter
enum UserFilter: String, CaseIterable {
    case all
    case pending
    case active
    case suspended
    case banned
    case admins
    case premium

    var displayName: String {
        switch self {
        case .all: return "All Users"
        case .pending: return "Pending"
        case .active: return "Active"
        case .suspended: return "Suspended"
        case .banned: return "Banned"
        case .admins: return "Admins"
        case .premium: return "Premium"
        }
    }

    var icon: String {
        switch self {
        case .all: return "person.3"
        case .pending: return "clock"
        case .active: return "checkmark.circle"
        case .suspended: return "pause.circle"
        case .banned: return "xmark.circle"
        case .admins: return "shield"
        case .premium: return "star"
        }
    }
}

// Note: ManagedUser moved to AdminManagementTypes.swift
// Use ManagedUser.sampleUsers from AdminManagementTypes.swift for sample data
