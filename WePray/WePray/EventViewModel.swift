//
//  EventViewModel.swift
//  WePray - Event Management ViewModel
//

import SwiftUI

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var selectedFilter: EventFilter = .all
    @Published var selectedCategory: EventCategory?

    private let eventsKey = "WePrayEvents"
    private var currentUserId: String = ""

    init() {
        loadEvents()
    }

    // MARK: - Load Events
    func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded
            updateEventStatuses()
        } else {
            events = Event.sampleEvents
            saveEvents()
        }
    }

    // MARK: - Save Events
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: eventsKey)
        }
    }

    // MARK: - Update Event Statuses
    private func updateEventStatuses() {
        let now = Date()
        for i in events.indices {
            if events[i].status != .cancelled {
                if events[i].endDate < now {
                    events[i].status = .completed
                } else if events[i].startDate <= now && events[i].endDate >= now {
                    events[i].status = .ongoing
                } else {
                    events[i].status = .upcoming
                }
            }
        }
        saveEvents()
    }

    // MARK: - Create Event
    func createEvent(title: String, description: String, category: EventCategory, eventType: EventType,
                     startDate: Date, endDate: Date, recurrence: EventRecurrence, location: String,
                     virtualLink: String, maxAttendees: Int, isPublic: Bool,
                     hostId: String, hostName: String, hostRole: UserRole) {
        let newEvent = Event(
            title: title,
            description: description,
            category: category,
            eventType: eventType,
            startDate: startDate,
            endDate: endDate,
            recurrence: recurrence,
            location: location,
            virtualLink: virtualLink,
            maxAttendees: maxAttendees,
            isPublic: isPublic,
            hostId: hostId,
            hostName: hostName,
            hostRole: hostRole,
            gradientColors: [category.color.toHex() ?? "#1E3A8A", "#3B82F6"]
        )
        events.insert(newEvent, at: 0)
        saveEvents()
    }

    // MARK: - Update Event
    func updateEvent(eventId: UUID, title: String, description: String, category: EventCategory,
                     eventType: EventType, startDate: Date, endDate: Date, recurrence: EventRecurrence,
                     location: String, virtualLink: String, maxAttendees: Int, isPublic: Bool) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return }
        events[index].title = title
        events[index].description = description
        events[index].category = category
        events[index].eventType = eventType
        events[index].startDate = startDate
        events[index].endDate = endDate
        events[index].recurrence = recurrence
        events[index].location = location
        events[index].virtualLink = virtualLink
        events[index].maxAttendees = maxAttendees
        events[index].isPublic = isPublic
        saveEvents()
    }

    // MARK: - Cancel Event
    func cancelEvent(eventId: UUID) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return }
        events[index].status = .cancelled
        saveEvents()
    }

    // MARK: - Delete Event
    func deleteEvent(eventId: UUID) {
        events.removeAll { $0.id == eventId }
        saveEvents()
    }

    // MARK: - Register for Event
    func registerForEvent(eventId: UUID, userId: String, userName: String, userRole: UserRole) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return }
        guard !events[index].isFull else { return }
        guard !events[index].isAttending(userId: userId) else { return }

        let attendee = EventAttendee(
            userId: userId,
            userName: userName,
            userInitials: String(userName.prefix(2)).uppercased(),
            userRole: userRole
        )
        events[index].attendees.append(attendee)
        saveEvents()
    }

    // MARK: - Unregister from Event
    func unregisterFromEvent(eventId: UUID, userId: String) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return }
        events[index].attendees.removeAll { $0.userId == userId }
        saveEvents()
    }

    // MARK: - Mark Attendance
    func markAttendance(eventId: UUID, attendeeId: UUID, attended: Bool) {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventId }),
              let attendeeIndex = events[eventIndex].attendees.firstIndex(where: { $0.id == attendeeId }) else { return }
        events[eventIndex].attendees[attendeeIndex].attended = attended
        saveEvents()
    }

    // MARK: - Filtered Events
    var filteredEvents: [Event] {
        var result = events

        switch selectedFilter {
        case .all: break
        case .upcoming:
            result = result.filter { $0.status == .upcoming }
        case .myEvents:
            result = result.filter { $0.isAttending(userId: currentUserId) }
        case .hosting:
            result = result.filter { $0.isHost(userId: currentUserId) }
        case .past:
            result = result.filter { $0.status == .completed }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery) ||
                $0.description.localizedCaseInsensitiveContains(searchQuery) ||
                $0.hostName.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return result.sorted { $0.startDate < $1.startDate }
    }

    // MARK: - My Events
    var myEvents: [Event] {
        events.filter { $0.isAttending(userId: currentUserId) || $0.isHost(userId: currentUserId) }
            .sorted { $0.startDate < $1.startDate }
    }

    // MARK: - Upcoming Events
    var upcomingEvents: [Event] {
        events.filter { $0.status == .upcoming }.sorted { $0.startDate < $1.startDate }
    }

    // MARK: - Set Current User
    func setCurrentUser(id: String) {
        currentUserId = id
    }

    // MARK: - Refresh
    func refresh() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadEvents()
            self?.isLoading = false
        }
    }
}
