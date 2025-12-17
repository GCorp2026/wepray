//
//  EventDetailView.swift
//  WePray - Event Detail View
//

import SwiftUI

struct EventDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    let event: Event
    @ObservedObject var viewModel: EventViewModel
    @State private var showCancelConfirmation = false
    @State private var selectedTab = 0

    private var isHost: Bool {
        event.isHost(userId: appState.currentUser?.id.uuidString ?? "")
    }

    private var isRegistered: Bool {
        event.isAttending(userId: appState.currentUser?.id.uuidString ?? "")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Quick Info
                    quickInfoSection

                    // Description
                    descriptionSection

                    // Location/Virtual Link
                    locationSection

                    // Tab Selector
                    tabSelector

                    // Tab Content
                    if selectedTab == 0 {
                        attendeesSection
                    } else {
                        detailsSection
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                if isHost {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(role: .destructive) {
                                showCancelConfirmation = true
                            } label: {
                                Label("Cancel Event", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Cancel Event", isPresented: $showCancelConfirmation) {
                Button("Keep Event", role: .cancel) {}
                Button("Cancel Event", role: .destructive) {
                    viewModel.cancelEvent(eventId: event.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to cancel this event? All attendees will be notified.")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(event.category.color)
                    .frame(width: 80, height: 80)
                Image(systemName: event.category.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text(event.title)
                .font(.title2.bold())
                .foregroundColor(AppColors.text)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                EventStatusBadge(status: event.status)

                Text(event.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(event.category.color)
                    .cornerRadius(8)

                Label(event.eventType.rawValue, systemImage: event.eventType.icon)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            // Host Info
            HStack(spacing: 8) {
                Text("Hosted by")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                Text(event.hostName)
                    .font(.caption.bold())
                    .foregroundColor(AppColors.text)
                RoleBadgeView(role: event.hostRole, style: .compact)
            }
        }
    }

    private var quickInfoSection: some View {
        HStack(spacing: 16) {
            infoCard(icon: "calendar", title: "Date", value: event.startDate.formatted(date: .abbreviated, time: .omitted))
            infoCard(icon: "clock", title: "Time", value: event.startDate.formatted(date: .omitted, time: .shortened))
            infoCard(icon: "person.2", title: "Spots", value: "\(event.spotsLeft) left")
        }
    }

    private func infoCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(AppColors.text)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text(event.description)
                .font(.body)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !event.location.isEmpty {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AppColors.primary)
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(AppColors.text)
                }
            }
            if !event.virtualLink.isEmpty {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppColors.primary)
                    Link(event.virtualLink, destination: URL(string: event.virtualLink) ?? URL(string: "https://")!)
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Attendees (\(event.attendeeCount))", index: 0)
            tabButton(title: "Details", index: 1)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            Text(title)
                .font(.subheadline.weight(selectedTab == index ? .semibold : .regular))
                .foregroundColor(selectedTab == index ? .white : AppColors.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == index ? AppColors.primary : Color.clear)
                .cornerRadius(12)
        }
    }

    private var attendeesSection: some View {
        VStack(spacing: 12) {
            ForEach(event.attendees) { attendee in
                AttendeeRow(attendee: attendee, canManage: isHost) {
                    viewModel.markAttendance(eventId: event.id, attendeeId: attendee.id, attended: !attendee.attended)
                }
            }

            if event.attendees.isEmpty {
                Text("No attendees yet")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .padding()
            }

            // Register/Unregister Button
            if event.status == .upcoming {
                registerButton
            }
        }
    }

    private var registerButton: some View {
        Button {
            if isRegistered {
                viewModel.unregisterFromEvent(eventId: event.id, userId: appState.currentUser?.id.uuidString ?? "")
            } else {
                guard let user = appState.currentUser else { return }
                viewModel.registerForEvent(eventId: event.id, userId: user.id.uuidString, userName: user.displayName, userRole: user.role)
            }
        } label: {
            Text(isRegistered ? "Cancel Registration" : "Register for Event")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isRegistered ? AppColors.error : AppColors.primary)
                .cornerRadius(12)
        }
        .disabled(!isRegistered && event.isFull)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            detailRow(icon: "repeat", title: "Recurrence", value: event.recurrence.rawValue)
            detailRow(icon: "person.2.fill", title: "Max Attendees", value: "\(event.maxAttendees)")
            detailRow(icon: event.isPublic ? "globe" : "lock.fill", title: "Visibility", value: event.isPublic ? "Public" : "Private")
            detailRow(icon: "clock.arrow.circlepath", title: "Duration", value: formatDuration())
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.text)
        }
    }

    private func formatDuration() -> String {
        let interval = event.endDate.timeIntervalSince(event.startDate)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
