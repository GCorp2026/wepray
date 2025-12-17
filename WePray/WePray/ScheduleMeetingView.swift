import SwiftUI

struct ScheduleMeetingView: View {
    let circleId: UUID
    @ObservedObject var viewModel: PrayerCircleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Weekly Prayer Call"
    @State private var scheduledDate = Date().addingTimeInterval(86400)
    @State private var duration = 30
    @State private var meetingLink = ""
    @State private var description = ""
    @State private var isRecurring = false
    @State private var recurrenceType: RecurrenceType = .weekly

    private let durations = [15, 30, 45, 60, 90, 120]

    private var canSchedule: Bool {
        !title.isEmpty && !meetingLink.isEmpty && scheduledDate > Date()
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        titleSection
                        dateTimeSection
                        durationSection
                        linkSection
                        descriptionSection
                        recurrenceSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Schedule Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schedule") { scheduleMeeting() }
                        .foregroundColor(canSchedule ? AppColors.accent : AppColors.subtext)
                        .disabled(!canSchedule)
                }
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meeting Title")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("e.g., Weekly Prayer Call", text: $title)
                .padding()
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
        }
    }

    // MARK: - Date Time Section

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date & Time")
                .font(.headline)
                .foregroundColor(AppColors.text)

            DatePicker("", selection: $scheduledDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .accentColor(AppColors.accent)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
        }
    }

    // MARK: - Duration Section

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(durations, id: \.self) { mins in
                        Button(action: { duration = mins }) {
                            Text(formatDuration(mins))
                                .font(.subheadline)
                                .foregroundColor(duration == mins ? .white : AppColors.accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(duration == mins ? AppColors.accent : AppColors.accent.opacity(0.15))
                                .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Link Section

    private var linkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meeting Link")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("https://meet.example.com/...", text: $meetingLink)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .padding()
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)

            Text("Paste a Zoom, Google Meet, or other video call link")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description (Optional)")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("What will you be praying about?", text: $description)
                .padding()
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
        }
    }

    // MARK: - Recurrence Section

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recurring Meeting")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text("Automatically schedule follow-up meetings")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                Toggle("", isOn: $isRecurring)
                    .tint(AppColors.accent)
            }

            if isRecurring {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(RecurrenceType.allCases, id: \.self) { type in
                            Button(action: { recurrenceType = type }) {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                }
                                .font(.subheadline)
                                .foregroundColor(recurrenceType == type ? .white : AppColors.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(recurrenceType == type ? AppColors.accent : AppColors.accent.opacity(0.15))
                                .cornerRadius(20)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours) hour"
        }
        return "\(minutes) min"
    }

    private func scheduleMeeting() {
        let meeting = CircleMeeting(
            title: title,
            scheduledDate: scheduledDate,
            duration: duration,
            meetingLink: meetingLink,
            isRecurring: isRecurring,
            recurrenceType: isRecurring ? recurrenceType : nil,
            hostName: "You",
            description: description,
            attendees: ["You"]
        )
        viewModel.scheduleMeeting(for: circleId, meeting: meeting)
        dismiss()
    }
}

#Preview {
    ScheduleMeetingView(circleId: UUID(), viewModel: PrayerCircleViewModel())
}
