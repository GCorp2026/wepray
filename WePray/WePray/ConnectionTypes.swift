//
//  ConnectionTypes.swift
//  WePray - Professional Networking Types
//

import SwiftUI

// MARK: - Connection Status
enum ConnectionStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case rejected
    case blocked

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Connected"
        case .rejected: return "Rejected"
        case .blocked: return "Blocked"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle"
        case .blocked: return "hand.raised.fill"
        }
    }

    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .green
        case .rejected: return .red
        case .blocked: return .gray
        }
    }
}

// MARK: - Connection Filter
enum ConnectionFilter: String, CaseIterable {
    case all
    case connected
    case pending
    case sent

    var displayName: String {
        switch self {
        case .all: return "All"
        case .connected: return "Connected"
        case .pending: return "Requests"
        case .sent: return "Sent"
        }
    }

    var icon: String {
        switch self {
        case .all: return "person.2"
        case .connected: return "person.2.fill"
        case .pending: return "person.badge.clock"
        case .sent: return "paperplane"
        }
    }
}

// MARK: - Connection Model
struct Connection: Identifiable, Codable {
    var id = UUID()
    let userId: String
    let userName: String
    let userRole: UserRole
    let userEmail: String
    var status: ConnectionStatus
    let requestDate: Date
    var acceptedDate: Date?
    let isIncoming: Bool  // True if request was received, false if sent

    var userInitial: String {
        String(userName.prefix(1)).uppercased()
    }

    init(id: UUID = UUID(), userId: String, userName: String, userRole: UserRole,
         userEmail: String, status: ConnectionStatus = .pending,
         requestDate: Date = Date(), acceptedDate: Date? = nil, isIncoming: Bool = true) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userRole = userRole
        self.userEmail = userEmail
        self.status = status
        self.requestDate = requestDate
        self.acceptedDate = acceptedDate
        self.isIncoming = isIncoming
    }
}

// MARK: - User Search Result
struct UserSearchResult: Identifiable, Codable {
    let id: String
    let displayName: String
    let email: String
    let role: UserRole
    let profession: String?
    let skills: [String]?
    let aboutMe: String?
    var connectionStatus: ConnectionStatus?

    var initial: String {
        String(displayName.prefix(1)).uppercased()
    }
}

// MARK: - Connection Statistics
struct ConnectionStats {
    var totalConnections: Int
    var pendingRequests: Int
    var sentRequests: Int

    static var empty: ConnectionStats {
        ConnectionStats(totalConnections: 0, pendingRequests: 0, sentRequests: 0)
    }
}

// MARK: - Sample Data
extension Connection {
    static let sampleConnections: [Connection] = [
        Connection(
            userId: "user1",
            userName: "Sarah Miller",
            userRole: .admin,
            userEmail: "sarah@wepray.com",
            status: .accepted,
            requestDate: Date().addingTimeInterval(-86400 * 30),
            acceptedDate: Date().addingTimeInterval(-86400 * 29),
            isIncoming: true
        ),
        Connection(
            userId: "user2",
            userName: "David Chen",
            userRole: .premium,
            userEmail: "david@gmail.com",
            status: .accepted,
            requestDate: Date().addingTimeInterval(-86400 * 14),
            acceptedDate: Date().addingTimeInterval(-86400 * 13),
            isIncoming: false
        ),
        Connection(
            userId: "user3",
            userName: "Emily Rodriguez",
            userRole: .user,
            userEmail: "emily@gmail.com",
            status: .pending,
            requestDate: Date().addingTimeInterval(-86400 * 2),
            isIncoming: true
        ),
        Connection(
            userId: "user4",
            userName: "Michael Brown",
            userRole: .user,
            userEmail: "michael@gmail.com",
            status: .pending,
            requestDate: Date().addingTimeInterval(-86400),
            isIncoming: false
        ),
        Connection(
            userId: "user5",
            userName: "Jessica Lee",
            userRole: .premium,
            userEmail: "jessica@gmail.com",
            status: .accepted,
            requestDate: Date().addingTimeInterval(-86400 * 7),
            acceptedDate: Date().addingTimeInterval(-86400 * 6),
            isIncoming: true
        ),
        Connection(
            userId: "user6",
            userName: "Grace Thompson",
            userRole: .user,
            userEmail: "grace@gmail.com",
            status: .pending,
            requestDate: Date().addingTimeInterval(-3600 * 12),
            isIncoming: true
        )
    ]
}

extension UserSearchResult {
    static let sampleUsers: [UserSearchResult] = [
        UserSearchResult(
            id: "search1",
            displayName: "John Smith",
            email: "john@example.com",
            role: .user,
            profession: "Software Engineer",
            skills: ["iOS Development", "Prayer Ministry"],
            aboutMe: "Passionate about faith and technology",
            connectionStatus: nil
        ),
        UserSearchResult(
            id: "search2",
            displayName: "Anna Williams",
            email: "anna@example.com",
            role: .premium,
            profession: "Teacher",
            skills: ["Youth Ministry", "Bible Study"],
            aboutMe: "Educator and prayer warrior",
            connectionStatus: .pending
        ),
        UserSearchResult(
            id: "search3",
            displayName: "Robert Johnson",
            email: "robert@example.com",
            role: .user,
            profession: "Pastor",
            skills: ["Counseling", "Leadership"],
            aboutMe: "Serving the community through prayer",
            connectionStatus: .accepted
        )
    ]
}
