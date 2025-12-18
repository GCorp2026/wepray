//
//  EventComponents.swift
//  WePray - Event UI Components
//

import SwiftUI

// MARK: - Event Card
struct EventCard: View {
    let event: Event
    let isRegistered: Bool
    let onRegister: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                ZStack {
                    Circle()
                        .fill(event.category.color)
                        .frame(width: 44, height: 44)
                    Image(systemName: event.category.icon)
                        .foregroundColor(.white)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text(event.category.rawValue)
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)
                        Text("•")
                            .foregroundColor(AppColors.subtext)
                        Image(systemName: event.eventType.icon)
                            .font(.caption2)
                        Text(event.eventType.rawValue)
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)
                    }
                }

                Spacer()

                EventStatusBadge(status: event.status)
            }

            // Date & Time
            HStack(spacing: 16) {
                Label {
                    Text(event.startDate, style: .date)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.primary)
                }

                Label {
                    Text(event.startDate, style: .time)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundColor(AppColors.primary)
                }
            }
            .foregroundColor(AppColors.text)

            // Location
            if !event.location.isEmpty {
                Label(event.location, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                    .lineLimit(1)
            }

            // Footer
            HStack {
                Label("\(event.attendeeCount)/\(event.maxAttendees)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)

                Spacer()

                Button(action: onRegister) {
                    Text(isRegistered ? "Registered" : (event.isFull ? "Full" : "Register"))
                        .font(.caption.bold())
                        .foregroundColor(isRegistered ? AppColors.subtext : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isRegistered ? AppColors.border : (event.isFull ? AppColors.subtext : AppColors.primary))
                        .cornerRadius(8)
                }
                .disabled(isRegistered || event.isFull)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Event Status Badge
struct EventStatusBadge: View {
    let status: EventStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color)
            .cornerRadius(8)
    }
}

// MARK: - Event Filter Chips
struct EventFilterChips: View {
    @Binding var selectedFilter: EventFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EventFilter.allCases, id: \.self) { filter in
                    EventFilterChip(filter: filter, isSelected: selectedFilter == filter) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Event Filter Chip
struct EventFilterChip: View {
    let filter: EventFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [AppColors.cardBackground, AppColors.cardBackground], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Category Chips
struct EventCategoryChips: View {
    @Binding var selectedCategory: EventCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                } label: {
                    Text("All")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedCategory == nil ? AppColors.primary : AppColors.cardBackground)
                        .foregroundColor(selectedCategory == nil ? .white : AppColors.text)
                        .cornerRadius(16)
                }

                ForEach(EventCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedCategory == category ? category.color : AppColors.cardBackground)
                        .foregroundColor(selectedCategory == category ? .white : AppColors.text)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Upcoming Event Card (Compact)
struct UpcomingEventCard: View {
    let event: Event

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(event.category.color)
                    .frame(width: 50, height: 50)
                Image(systemName: event.category.icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(event.startDate, style: .relative)
                        .font(.caption)
                }
                .foregroundColor(AppColors.subtext)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Attendee Row
struct AttendeeRow: View {
    let attendee: EventAttendee
    let canManage: Bool
    let onToggleAttendance: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(attendee.userRole.badgeColorValue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(attendee.userInitials)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(attendee.userName)
                        .font(.subheadline)
                        .foregroundColor(AppColors.text)
                    RoleBadgeView(role: attendee.userRole)
                }
                Text("Registered \(attendee.registeredAt, style: .relative)")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()

            if canManage {
                Button(action: onToggleAttendance) {
                    Image(systemName: attendee.attended ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(attendee.attended ? AppColors.success : AppColors.subtext)
                        .font(.title2)
                }
            } else if attendee.attended {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.success)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
