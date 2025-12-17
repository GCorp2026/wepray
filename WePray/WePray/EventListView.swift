//
//  EventListView.swift
//  WePray - Event List View
//

import SwiftUI

struct EventListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = EventViewModel()
    @State private var showCreateEvent = false
    @State private var selectedEvent: Event?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Upcoming Events Section
                        if !viewModel.upcomingEvents.isEmpty {
                            upcomingSection
                        }

                        // Filter Chips
                        EventFilterChips(selectedFilter: $viewModel.selectedFilter)

                        // Category Chips
                        EventCategoryChips(selectedCategory: $viewModel.selectedCategory)

                        // Search Bar
                        searchBar

                        // Events List
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredEvents) { event in
                                EventCard(
                                    event: event,
                                    isRegistered: event.isAttending(userId: appState.currentUser?.id.uuidString ?? ""),
                                    onRegister: {
                                        registerForEvent(event)
                                    }
                                )
                                .onTapGesture {
                                    selectedEvent = event
                                }
                            }
                        }
                        .padding(.horizontal)

                        if viewModel.filteredEvents.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.refresh()
                }

                // Create Event Button
                if canCreateEvents {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            createEventButton
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCreateEvent) {
                CreateEventSheet(viewModel: viewModel)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, viewModel: viewModel)
            }
            .onAppear {
                viewModel.setCurrentUser(id: appState.currentUser?.id.uuidString ?? "")
            }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.headline)
                .foregroundColor(AppColors.text)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.upcomingEvents.prefix(5)) { event in
                        UpcomingEventCard(event: event)
                            .frame(width: 280)
                            .onTapGesture {
                                selectedEvent = event
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.subtext)
            TextField("Search events...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext)
            Text("No events found")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text("Try adjusting your filters or create a new event")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private var createEventButton: some View {
        Button(action: { showCreateEvent = true }) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding()
    }

    private var canCreateEvents: Bool {
        guard let role = appState.currentUser?.role else { return false }
        return role == .superAdmin || role == .admin || role == .premium
    }

    private func registerForEvent(_ event: Event) {
        guard let user = appState.currentUser else { return }
        viewModel.registerForEvent(
            eventId: event.id,
            userId: user.id.uuidString,
            userName: user.displayName,
            userRole: user.role
        )
    }
}

// MARK: - Create Event Sheet
struct CreateEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: EventViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var category: EventCategory = .prayerMeeting
    @State private var eventType: EventType = .inPerson
    @State private var startDate = Date().addingTimeInterval(86400)
    @State private var endDate = Date().addingTimeInterval(86400 + 3600)
    @State private var recurrence: EventRecurrence = .none
    @State private var location = ""
    @State private var virtualLink = ""
    @State private var maxAttendees = 50
    @State private var isPublic = true

    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Category", selection: $category) {
                        ForEach(EventCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    Picker("Type", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                }

                Section("Schedule") {
                    DatePicker("Start", selection: $startDate)
                    DatePicker("End", selection: $endDate)
                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(EventRecurrence.allCases, id: \.self) { rec in
                            Text(rec.rawValue).tag(rec)
                        }
                    }
                }

                Section("Location") {
                    if eventType != .virtual {
                        TextField("Address", text: $location)
                    }
                    if eventType != .inPerson {
                        TextField("Virtual Link", text: $virtualLink)
                    }
                }

                Section("Settings") {
                    Stepper("Max Attendees: \(maxAttendees)", value: $maxAttendees, in: 5...500, step: 5)
                    Toggle("Public Event", isOn: $isPublic)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createEvent() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func createEvent() {
        guard let user = appState.currentUser else { return }
        viewModel.createEvent(
            title: title, description: description, category: category, eventType: eventType,
            startDate: startDate, endDate: endDate, recurrence: recurrence, location: location,
            virtualLink: virtualLink, maxAttendees: maxAttendees, isPublic: isPublic,
            hostId: user.id.uuidString, hostName: user.displayName, hostRole: user.role
        )
        dismiss()
    }
}
