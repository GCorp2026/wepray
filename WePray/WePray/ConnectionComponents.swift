//
//  ConnectionComponents.swift
//  WePray - Connection UI Components
//

import SwiftUI

// MARK: - Connection Card
struct ConnectionCard: View {
    let connection: Connection
    let onRemove: () -> Void
    let onMessage: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [connection.userRole.badgeColorValue, connection.userRole.badgeColorValue.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(connection.userInitial)
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(connection.userName)
                        .font(.headline)
                        .foregroundColor(AppColors.text)

                    RoleBadgeView(role: connection.userRole)
                }

                if connection.status == .accepted, let date = connection.acceptedDate {
                    Text("Connected \(date, style: .relative)")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                // Message button
                Button(action: onMessage) {
                    Image(systemName: "message.fill")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                        .padding(8)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }

                // Menu
                Menu {
                    Button(action: onMessage) {
                        Label("Message", systemImage: "message")
                    }
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

// MARK: - Connection Request Card
struct ConnectionRequestCard: View {
    let connection: Connection
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [connection.userRole.badgeColorValue, connection.userRole.badgeColorValue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(connection.userInitial)
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(connection.userName)
                            .font(.headline)
                            .foregroundColor(AppColors.text)

                        RoleBadgeView(role: connection.userRole)
                    }

                    Text("Requested \(connection.requestDate, style: .relative)")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("Decline")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppColors.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.cardBackground)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }

                Button(action: onAccept) {
                    Text("Accept")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColors.primary.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Sent Request Card
struct SentRequestCard: View {
    let connection: Connection
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [connection.userRole.badgeColorValue, connection.userRole.badgeColorValue.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(connection.userInitial)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(connection.userName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppColors.text)

                    RoleBadgeView(role: connection.userRole)
                }

                Text("Sent \(connection.requestDate, style: .relative)")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.caption.weight(.medium))
                    .foregroundColor(AppColors.subtext)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.cardBackground)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - User Search Result Card
struct UserSearchResultCard: View {
    let user: UserSearchResult
    let onConnect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [user.role.badgeColorValue, user.role.badgeColorValue.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.initial)
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.headline)
                        .foregroundColor(AppColors.text)

                    RoleBadgeView(role: user.role)
                }

                if let profession = user.profession, !profession.isEmpty {
                    Text(profession)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                if let skills = user.skills, !skills.isEmpty {
                    Text(skills.prefix(3).joined(separator: " • "))
                        .font(.caption2)
                        .foregroundColor(AppColors.accent)
                        .lineLimit(1)
                }
            }

            Spacer()

            connectButton
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    @ViewBuilder
    private var connectButton: some View {
        if user.connectionStatus == .accepted {
            Text("Connected")
                .font(.caption.weight(.medium))
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
        } else if user.connectionStatus == .pending {
            Text("Pending")
                .font(.caption.weight(.medium))
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
        } else {
            Button(action: onConnect) {
                Text("Connect")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.primary)
                    .cornerRadius(6)
            }
        }
    }
}

// Note: ConnectionFilterChips, ConnectionFilterChip, ConnectionStatsCard, and EmptyConnectionsView
// are now in ConnectionFilterComponents.swift
