import SwiftUI

// MARK: - Upcoming Meeting Card

struct UpcomingMeetingCard: View {
    let circle: PrayerCircle
    let meeting: CircleMeeting
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Text(meeting.formattedDuration)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Text(circle.name)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)

                Text(meeting.formattedDate)
                    .font(.caption)
                    .foregroundColor(AppColors.accent)

                HStack {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text("\(meeting.attendees.count) attending")
                        .font(.caption)
                }
                .foregroundColor(AppColors.subtext)
            }
            .padding()
            .frame(width: 180)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - My Circle Card

struct MyCircleCard: View {
    let circle: PrayerCircle
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(circle.gradient)
                        .frame(width: 56, height: 56)
                    Image(systemName: circle.iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Text(circle.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption2)
                    Text("\(circle.memberCount)")
                        .font(.caption2)
                }
                .foregroundColor(AppColors.subtext)
            }
            .frame(width: 100)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Discover Circle Card

struct DiscoverCircleCard: View {
    let circle: PrayerCircle
    @ObservedObject var viewModel: PrayerCircleViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(circle.gradient)
                        .frame(width: 56, height: 56)
                    Image(systemName: circle.iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(circle.name)
                            .font(.headline)
                            .foregroundColor(AppColors.text)
                        if circle.isPrivate {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(AppColors.subtext)
                        }
                    }

                    Text(circle.description)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        Label("\(circle.memberCount)", systemImage: "person.2")
                        Label(circle.category.rawValue, systemImage: circle.category.icon)
                    }
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                }

                Spacer()

                if circle.isJoined {
                    Text("Joined")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(8)
                } else {
                    Button(action: { viewModel.joinCircle(circle) }) {
                        Text("Join")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Circle Category Chip

struct CircleCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.15))
            .cornerRadius(20)
        }
    }
}

// MARK: - Circle Stat View

struct CircleStatView: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accent)
            Text(value)
                .font(.headline)
                .foregroundColor(AppColors.text)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
    }
}

// MARK: - Tab Button

struct CircleTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? AppColors.text : AppColors.subtext)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? AppColors.primary.opacity(0.2) : Color.clear)
        }
    }
}

// MARK: - Prayer Request Card

struct PrayerRequestCard: View {
    let request: CirclePrayerRequest
    let circleId: UUID
    @ObservedObject var viewModel: PrayerCircleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(request.authorInitials)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(request.authorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.text)
                    Text(request.timeAgo)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                if request.isUrgent {
                    Label("Urgent", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                HStack(spacing: 4) {
                    Image(systemName: request.status.icon)
                    Text(request.status.rawValue)
                }
                .font(.caption)
                .foregroundColor(request.status.color)
            }

            Text(request.content)
                .font(.subheadline)
                .foregroundColor(AppColors.text)

            HStack {
                Button(action: { viewModel.markAsPrayed(requestId: request.id, in: circleId) }) {
                    HStack(spacing: 4) {
                        Image(systemName: request.hasPrayed ? "hands.sparkles.fill" : "hands.sparkles")
                        Text("\(request.prayerCount)")
                    }
                    .font(.caption)
                    .foregroundColor(request.hasPrayed ? AppColors.accent : AppColors.subtext)
                }
                Spacer()
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Member Card

struct MemberCard: View {
    let member: CircleMember

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppColors.primary)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(member.initials)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.text)
                Text("\(member.prayerCount) prayers")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: member.role.icon)
                Text(member.role.rawValue)
            }
            .font(.caption)
            .foregroundColor(member.role.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(member.role.color.opacity(0.15))
            .cornerRadius(8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
