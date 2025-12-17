//
//  RoleBadgeView.swift
//  WePray - Role Badge Component
//

import SwiftUI

// MARK: - Role Badge View
struct RoleBadgeView: View {
    let role: UserRole
    var showText: Bool = false
    var size: BadgeSize = .small

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: role.badgeIcon)
                .font(.system(size: size.iconSize))
                .foregroundColor(Color(hex: role.badgeColor))

            if showText {
                Text(role.displayName)
                    .font(.system(size: size.textSize, weight: .medium))
                    .foregroundColor(Color(hex: role.badgeColor))
            }
        }
        .padding(.horizontal, showText ? 8 : 4)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(hex: role.badgeColor).opacity(0.15))
        )
    }

    enum BadgeSize {
        case small
        case medium
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 14
            case .large: return 18
            }
        }

        var textSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
    }
}

// MARK: - User Name with Badge
struct UserNameWithBadge: View {
    let name: String
    let role: UserRole
    var fontSize: CGFloat = 16

    var body: some View {
        HStack(spacing: 6) {
            Text(name)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(AppColors.text)

            RoleBadgeView(role: role, size: .small)
        }
    }
}

// MARK: - Role Selection View (for Admin Panel)
struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User Role")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            Picker("Role", selection: $selectedRole) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    HStack {
                        Image(systemName: role.badgeIcon)
                            .foregroundColor(Color(hex: role.badgeColor))
                        Text(role.displayName)
                    }
                    .tag(role)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Role Info Card
struct RoleInfoCard: View {
    let role: UserRole

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: role.badgeColor).opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: role.badgeIcon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: role.badgeColor))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(role.displayName)
                    .font(.headline)
                    .foregroundColor(AppColors.text)

                Text(roleDescription)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }

    private var roleDescription: String {
        switch role {
        case .superAdmin:
            return "Full system access, manages all users and content"
        case .admin:
            return "Manages users, content, and platform settings"
        case .premium:
            return "Creates prayer circles, groups, and events"
        case .user:
            return "Standard user with basic features"
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Badge variations
        HStack(spacing: 16) {
            RoleBadgeView(role: .superAdmin)
            RoleBadgeView(role: .admin)
            RoleBadgeView(role: .premium)
            RoleBadgeView(role: .user)
        }

        // With text
        HStack(spacing: 16) {
            RoleBadgeView(role: .superAdmin, showText: true)
            RoleBadgeView(role: .admin, showText: true)
        }

        // User name with badge
        UserNameWithBadge(name: "John Doe", role: .admin)

        // Role cards
        VStack(spacing: 12) {
            RoleInfoCard(role: .superAdmin)
            RoleInfoCard(role: .admin)
            RoleInfoCard(role: .premium)
            RoleInfoCard(role: .user)
        }
        .padding()
    }
    .padding()
    .background(AppColors.background)
}
