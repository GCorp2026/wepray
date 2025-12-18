//
//  UserManagementView.swift
//  WePray - User Management for Admins
//

import SwiftUI

struct UserManagementView: View {
    @EnvironmentObject var appState: AppState
    @State private var users: [ManagedUser] = ManagedUser.sampleUsers
    @State private var searchQuery = ""
    @State private var selectedStatus: UserStatus?
    @State private var selectedRole: UserRole?
    @State private var selectedUser: ManagedUser?
    @State private var showUserDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // Search & Filters
            VStack(spacing: 12) {
                searchBar
                filterChips
            }
            .padding()
            .background(AppColors.cardBackground)

            // User Stats
            userStats
                .padding()

            // Users List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredUsers) { user in
                        UserManagementCard(user: user) {
                            selectedUser = user
                            showUserDetail = true
                        }
                    }
                }
                .padding()
            }
        }
        .background(AppColors.background)
        .navigationTitle("User Management")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showUserDetail) {
            if let user = selectedUser {
                UserMgmtDetailSheet(user: binding(for: user), onSave: saveUser)
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.subtext)
            TextField("Search users...", text: $searchQuery)
                .textFieldStyle(.plain)
        }
        .padding()
        .background(AppColors.background)
        .cornerRadius(12)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Status Filters
                ForEach(UserStatus.allCases, id: \.self) { status in
                    UserMgmtFilterChip(title: status.rawValue, isSelected: selectedStatus == status) {
                        selectedStatus = selectedStatus == status ? nil : status
                    }
                }

                Divider().frame(height: 24)

                // Role Filters
                ForEach(UserRole.allCases, id: \.self) { role in
                    UserMgmtFilterChip(title: role.displayName, isSelected: selectedRole == role) {
                        selectedRole = selectedRole == role ? nil : role
                    }
                }
            }
        }
    }

    private var userStats: some View {
        HStack(spacing: 12) {
            UserMgmtStatCard(value: "\(users.count)", label: "Total", color: AppColors.primary)
            UserMgmtStatCard(value: "\(users.filter { $0.status == .active }.count)", label: "Active", color: Color(hex: "#10B981"))
            UserMgmtStatCard(value: "\(users.filter { $0.status == .suspended }.count)", label: "Suspended", color: Color(hex: "#EF4444"))
            UserMgmtStatCard(value: "\(users.filter { $0.role == .premium }.count)", label: "Premium", color: Color(hex: "#8B5CF6"))
        }
    }

    private var filteredUsers: [ManagedUser] {
        var result = users

        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        if let role = selectedRole {
            result = result.filter { $0.role == role }
        }
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.email.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return result.sorted { $0.lastActive > $1.lastActive }
    }

    private func binding(for user: ManagedUser) -> Binding<ManagedUser> {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else {
            return .constant(user)
        }
        return $users[index]
    }

    private func saveUser(_ user: ManagedUser) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
}

// MARK: - User Management Card
struct UserManagementCard: View {
    let user: ManagedUser
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(user.role.badgeColorValue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(user.initials)
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundColor(AppColors.text)
                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppColors.primary)
                                .font(.caption)
                        }
                        RoleBadgeView(role: user.role, style: .compact)
                    }
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: user.status.icon)
                        .font(.caption)
                    Text(user.status.rawValue)
                        .font(.caption)
                }
                .foregroundColor(user.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(user.status.color.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - User Management Filter Chip
struct UserMgmtFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .white : AppColors.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.primary : AppColors.background)
                .cornerRadius(16)
        }
    }
}

// MARK: - User Management Stat Card
struct UserMgmtStatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - User Management Detail Sheet
struct UserMgmtDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var user: ManagedUser
    let onSave: (ManagedUser) -> Void
    @State private var showSuspendAlert = false
    @State private var suspensionReason = ""

    var body: some View {
        NavigationView {
            Form {
                Section("User Info") {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                    LabeledContent("Joined", value: user.joinDate.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("Last Active", value: user.lastActive.formatted(date: .abbreviated, time: .shortened))
                }

                Section("Stats") {
                    LabeledContent("Prayers", value: "\(user.prayerCount)")
                    LabeledContent("Connections", value: "\(user.connectionsCount)")
                }

                Section("Role") {
                    Picker("User Role", selection: $user.role) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                }

                Section("Status") {
                    Toggle("Verified", isOn: $user.isVerified)

                    if user.isSuspended {
                        LabeledContent("Suspension Reason", value: user.suspensionReason ?? "N/A")
                        Button("Unsuspend User") {
                            user.isSuspended = false
                            user.status = .active
                            user.suspensionReason = nil
                        }
                        .foregroundColor(AppColors.primary)
                    } else {
                        Button("Suspend User") {
                            showSuspendAlert = true
                        }
                        .foregroundColor(AppColors.error)
                    }
                }
            }
            .navigationTitle("User Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(user)
                        dismiss()
                    }
                }
            }
            .alert("Suspend User", isPresented: $showSuspendAlert) {
                TextField("Reason", text: $suspensionReason)
                Button("Cancel", role: .cancel) {}
                Button("Suspend", role: .destructive) {
                    user.isSuspended = true
                    user.status = .suspended
                    user.suspensionReason = suspensionReason
                }
            } message: {
                Text("Enter reason for suspension")
            }
        }
    }
}
