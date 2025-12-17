import SwiftUI

struct PrayerCircleDetailView: View {
    let circle: PrayerCircle
    @ObservedObject var viewModel: PrayerCircleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingScheduleMeeting = false
    @State private var showingAddRequest = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        if let meeting = circle.nextMeeting {
                            meetingCard(meeting)
                        }
                        tabSelector
                        tabContent
                    }
                    .padding()
                }
            }
            .navigationTitle(circle.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if circle.isJoined {
                            Button(action: { showingScheduleMeeting = true }) {
                                Label("Schedule Meeting", systemImage: "calendar.badge.plus")
                            }
                            Button(action: { showingAddRequest = true }) {
                                Label("Add Prayer Request", systemImage: "plus.bubble")
                            }
                            Divider()
                            Button(role: .destructive, action: leaveCircle) {
                                Label("Leave Circle", systemImage: "person.badge.minus")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingScheduleMeeting) {
                ScheduleMeetingView(circleId: circle.id, viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddRequest) {
                AddPrayerRequestView(circleId: circle.id, viewModel: viewModel)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(circle.gradient)
                    .frame(width: 80, height: 80)
                Image(systemName: circle.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                HStack {
                    Text(circle.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    if circle.isPrivate {
                        Image(systemName: "lock.fill")
                            .foregroundColor(AppColors.subtext)
                    }
                }

                Text(circle.description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 24) {
                CircleStatView(value: "\(circle.memberCount)", label: "Members", icon: "person.2")
                CircleStatView(value: "\(circle.prayerRequests.count)", label: "Requests", icon: "hands.sparkles")
                CircleStatView(value: circle.category.rawValue, label: "Category", icon: circle.category.icon)
            }

            if !circle.isJoined {
                Button(action: joinCircle) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Join Circle")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Meeting Card

    private func meetingCard(_ meeting: CircleMeeting) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundColor(.green)
                Text("Next Meeting")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                if meeting.isRecurring, let recurrence = meeting.recurrenceType {
                    Label(recurrence.rawValue, systemImage: recurrence.icon)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Text(meeting.title)
                .font(.subheadline)
                .foregroundColor(AppColors.text)

            HStack {
                Label(meeting.formattedDate, systemImage: "calendar")
                Spacer()
                Label(meeting.formattedDuration, systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(AppColors.subtext)

            HStack {
                Text("\(meeting.attendees.count) attending")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                Spacer()
                Button(action: { openMeetingLink(meeting.meetingLink) }) {
                    HStack {
                        Image(systemName: "video.fill")
                        Text("Join")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            CircleTabButton(title: "Requests", isSelected: selectedTab == 0) { selectedTab = 0 }
            CircleTabButton(title: "Members", isSelected: selectedTab == 1) { selectedTab = 1 }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            prayerRequestsSection
        case 1:
            membersSection
        default:
            EmptyView()
        }
    }

    // MARK: - Prayer Requests Section

    private var prayerRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if circle.prayerRequests.isEmpty {
                emptyRequestsView
            } else {
                ForEach(circle.prayerRequests) { request in
                    PrayerRequestCard(request: request, circleId: circle.id, viewModel: viewModel)
                }
            }
        }
    }

    private var emptyRequestsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "hands.sparkles")
                .font(.system(size: 36))
                .foregroundColor(AppColors.subtext)
            Text("No prayer requests yet")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
            if circle.isJoined {
                Button(action: { showingAddRequest = true }) {
                    Text("Add First Request")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Members Section

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(circle.members) { member in
                MemberCard(member: member)
            }
        }
    }

    // MARK: - Actions

    private func joinCircle() {
        viewModel.joinCircle(circle)
        dismiss()
    }

    private func leaveCircle() {
        viewModel.leaveCircle(circle)
        dismiss()
    }

    private func openMeetingLink(_ link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    PrayerCircleDetailView(
        circle: PrayerCircle.sampleCircles[0],
        viewModel: PrayerCircleViewModel()
    )
}
