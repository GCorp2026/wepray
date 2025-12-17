//
//  EventTypes.swift
//  WePray - Event and Meeting Data Models
//

import SwiftUI

// MARK: - Event Category
enum EventCategory: String, CaseIterable, Codable {
    case prayerMeeting = "Prayer Meeting"
    case bibleStudy = "Bible Study"
    case worship = "Worship"
    case fellowship = "Fellowship"
    case retreat = "Retreat"
    case conference = "Conference"
    case workshop = "Workshop"
    case outreach = "Outreach"
    case youth = "Youth"
    case other = "Other"

    var icon: String {
        switch self {
        case .prayerMeeting: return "hands.sparkles.fill"
        case .bibleStudy: return "book.fill"
        case .worship: return "music.note.list"
        case .fellowship: return "person.3.fill"
        case .retreat: return "leaf.fill"
        case .conference: return "mic.fill"
        case .workshop: return "hammer.fill"
        case .outreach: return "heart.fill"
        case .youth: return "figure.wave"
        case .other: return "calendar"
        }
    }

    var color: Color {
        switch self {
        case .prayerMeeting: return Color(hex: "#3B82F6")
        case .bibleStudy: return Color(hex: "#10B981")
        case .worship: return Color(hex: "#8B5CF6")
        case .fellowship: return Color(hex: "#F59E0B")
        case .retreat: return Color(hex: "#06B6D4")
        case .conference: return Color(hex: "#EC4899")
        case .workshop: return Color(hex: "#6366F1")
        case .outreach: return Color(hex: "#EF4444")
        case .youth: return Color(hex: "#14B8A6")
        case .other: return Color(hex: "#6B7280")
        }
    }
}

// MARK: - Event Type
enum EventType: String, CaseIterable, Codable {
    case inPerson = "In Person"
    case virtual = "Virtual"
    case hybrid = "Hybrid"

    var icon: String {
        switch self {
        case .inPerson: return "mappin.circle.fill"
        case .virtual: return "video.fill"
        case .hybrid: return "rectangle.on.rectangle.fill"
        }
    }
}

// MARK: - Event Status
enum EventStatus: String, CaseIterable, Codable {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var color: Color {
        switch self {
        case .upcoming: return Color(hex: "#3B82F6")
        case .ongoing: return Color(hex: "#10B981")
        case .completed: return Color(hex: "#6B7280")
        case .cancelled: return Color(hex: "#EF4444")
        }
    }
}

// MARK: - Event Recurrence
enum EventRecurrence: String, CaseIterable, Codable {
    case none = "One-time"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
}

// MARK: - Event Attendee
struct EventAttendee: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: String
    let userName: String
    let userInitials: String
    let userRole: UserRole
    let registeredAt: Date
    var attended: Bool

    init(id: UUID = UUID(), userId: String, userName: String, userInitials: String, userRole: UserRole, registeredAt: Date = Date(), attended: Bool = false) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userInitials = userInitials
        self.userRole = userRole
        self.registeredAt = registeredAt
        self.attended = attended
    }
}

// MARK: - Event Model
struct Event: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var category: EventCategory
    var eventType: EventType
    var status: EventStatus
    var startDate: Date
    var endDate: Date
    var recurrence: EventRecurrence
    var location: String
    var virtualLink: String
    var maxAttendees: Int
    var isPublic: Bool
    var hostId: String
    var hostName: String
    var hostRole: UserRole
    var attendees: [EventAttendee]
    var createdAt: Date
    var gradientColors: [String]

    init(id: UUID = UUID(), title: String, description: String, category: EventCategory, eventType: EventType, status: EventStatus = .upcoming, startDate: Date, endDate: Date, recurrence: EventRecurrence = .none, location: String = "", virtualLink: String = "", maxAttendees: Int = 50, isPublic: Bool = true, hostId: String, hostName: String, hostRole: UserRole, attendees: [EventAttendee] = [], createdAt: Date = Date(), gradientColors: [String] = ["#1E3A8A", "#3B82F6"]) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.eventType = eventType
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.recurrence = recurrence
        self.location = location
        self.virtualLink = virtualLink
        self.maxAttendees = maxAttendees
        self.isPublic = isPublic
        self.hostId = hostId
        self.hostName = hostName
        self.hostRole = hostRole
        self.attendees = attendees
        self.createdAt = createdAt
        self.gradientColors = gradientColors
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var attendeeCount: Int { attendees.count }
    var isFull: Bool { attendees.count >= maxAttendees }
    var spotsLeft: Int { max(0, maxAttendees - attendees.count) }

    func isAttending(userId: String) -> Bool {
        attendees.contains { $0.userId == userId }
    }

    func isHost(userId: String) -> Bool {
        hostId == userId
    }
}

// MARK: - Event Filter
enum EventFilter: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case myEvents = "My Events"
    case hosting = "Hosting"
    case past = "Past"

    var icon: String {
        switch self {
        case .all: return "calendar"
        case .upcoming: return "clock.fill"
        case .myEvents: return "person.fill"
        case .hosting: return "star.fill"
        case .past: return "clock.arrow.circlepath"
        }
    }
}

// MARK: - Sample Events
extension Event {
    static let sampleEvents: [Event] = [
        Event(
            title: "Morning Prayer Circle",
            description: "Join us for a powerful morning prayer session to start your day with God.",
            category: .prayerMeeting,
            eventType: .hybrid,
            startDate: Date().addingTimeInterval(86400),
            endDate: Date().addingTimeInterval(86400 + 3600),
            recurrence: .weekly,
            location: "Community Church, Room 101",
            virtualLink: "https://zoom.us/j/123456789",
            maxAttendees: 30,
            hostId: "user1",
            hostName: "Pastor John",
            hostRole: .admin,
            gradientColors: ["#1E40AF", "#3B82F6"]
        ),
        Event(
            title: "Bible Study: Book of Romans",
            description: "Deep dive into the Book of Romans. Bring your Bible and an open heart.",
            category: .bibleStudy,
            eventType: .inPerson,
            startDate: Date().addingTimeInterval(172800),
            endDate: Date().addingTimeInterval(172800 + 5400),
            location: "Fellowship Hall",
            maxAttendees: 25,
            hostId: "user2",
            hostName: "Sarah Mitchell",
            hostRole: .premium,
            gradientColors: ["#065F46", "#10B981"]
        ),
        Event(
            title: "Youth Worship Night",
            description: "A night of worship, fellowship, and fun for young adults ages 18-30.",
            category: .youth,
            eventType: .inPerson,
            startDate: Date().addingTimeInterval(259200),
            endDate: Date().addingTimeInterval(259200 + 10800),
            location: "Main Sanctuary",
            maxAttendees: 100,
            hostId: "user3",
            hostName: "Youth Ministry",
            hostRole: .admin,
            gradientColors: ["#0D9488", "#14B8A6"]
        )
    ]
}
