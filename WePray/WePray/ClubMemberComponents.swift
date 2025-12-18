//
//  ClubMemberComponents.swift
//  WePray - Club Member UI Components
//

import SwiftUI

// MARK: - Member Request Card
struct MemberRequestCard: View {
    let request: ClubMemberRequest
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(request.userRole.badgeColorValue)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(request.userInitials)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(request.userName)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(AppColors.text)
                        RoleBadgeView(role: request.userRole)
                    }
                    Text("Requested \(request.requestedAt, style: .relative)")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()
            }

            if !request.message.isEmpty {
                Text(request.message)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                    .padding(8)
                    .background(AppColors.background)
                    .cornerRadius(8)
            }

            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("Decline")
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.cardBackground)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 1))
                }

                Button(action: onApprove) {
                    Text("Approve")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
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

// MARK: - Club Member Row
struct ClubMemberRow: View {
    let member: ClubMember
    let canManage: Bool
    let onRemove: () -> Void
    let onChangeRole: (ClubMemberRole) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(member.userRole.badgeColorValue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(member.userInitials)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(member.userName)
                        .font(.subheadline)
                        .foregroundColor(AppColors.text)
                    RoleBadgeView(role: member.userRole)
                }

                HStack(spacing: 4) {
                    Image(systemName: member.clubRole.icon)
                        .font(.caption2)
                        .foregroundColor(member.clubRole.color)
                    Text(member.clubRole.rawValue)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Spacer()

            if canManage && member.clubRole != .owner {
                Menu {
                    ForEach(ClubMemberRole.allCases.filter { $0 != .owner }, id: \.self) { role in
                        Button {
                            onChangeRole(role)
                        } label: {
                            Label(role.rawValue, systemImage: role.icon)
                        }
                    }
                    Divider()
                    Button(role: .destructive, action: onRemove) {
                        Label("Remove", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppColors.subtext)
                        .padding(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Invitation Card
struct InvitationCard: View {
    let invitation: ClubInvitation
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.clubName)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text("Invited by \(invitation.invitedByName)")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
                Spacer()
            }

            HStack(spacing: 12) {
                Button(action: onDecline) {
                    Text("Decline")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppColors.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.cardBackground)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 1))
                }

                Button(action: onAccept) {
                    Text("Accept")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
