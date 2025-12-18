//
//  AdminUserComponents.swift
//  WePray - Admin User UI Components
//

import SwiftUI

// ManagedUser is defined in AdminUserTypes.swift

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(AppColors.text)
            Text(title)
                .font(.caption2)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var color: Color = AppColors.accent
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : AppColors.text)
            .background(isSelected ? color : AppColors.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3), lineWidth: 1))
        }
    }
}

// MARK: - User Row
struct UserRow: View {
    let user: ManagedUser

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(user.role.badgeColorValue.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(Text(user.profileInitial).font(.headline).foregroundColor(user.role.badgeColorValue))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.text)
                    RoleBadgeView(role: user.role, style: .compact)
                }
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()
            StatusBadge(status: user.status)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: AccountStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.2))
        .foregroundColor(status.color)
        .cornerRadius(8)
    }
}

// MARK: - Add User View
struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var users: [ManagedUser]
    @State private var displayName = ""
    @State private var email = ""
    @State private var selectedRole: UserRole = .user

    var body: some View {
        NavigationView {
            Form {
                Section("User Details") {
                    TextField("Display Name", text: $displayName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                Section("Role") {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            HStack {
                                Image(systemName: role.badgeIcon)
                                Text(role.displayName)
                            }.tag(role)
                        }
                    }
                }
            }
            .navigationTitle("Add User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addUser() }.disabled(displayName.isEmpty || email.isEmpty)
                }
            }
        }
    }

    private func addUser() {
        let newUser = ManagedUser(email: email, displayName: displayName, role: selectedRole, status: .pending, isPending: true)
        users.append(newUser)
        dismiss()
    }
}

// MARK: - User Detail Sheet
struct UserDetailSheet: View {
    let user: ManagedUser
    @Binding var users: [ManagedUser]
    @Environment(\.dismiss) var dismiss
    @State private var editedRole: UserRole
    @State private var editedStatus: AccountStatus

    init(user: ManagedUser, users: Binding<[ManagedUser]>) {
        self.user = user
        self._users = users
        self._editedRole = State(initialValue: user.role)
        self._editedStatus = State(initialValue: user.status)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Circle()
                            .fill(user.role.badgeColorValue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(Text(user.profileInitial).font(.title).foregroundColor(user.role.badgeColorValue))
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(user.displayName).font(.headline)
                                RoleBadgeView(role: user.role, style: .compact)
                            }
                            Text(user.email).font(.subheadline).foregroundColor(.secondary)
                            Text("Joined \(user.joinDate, style: .date)").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                Section("Role") {
                    Picker("Role", selection: $editedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            HStack {
                                Image(systemName: role.badgeIcon)
                                Text(role.displayName)
                            }.tag(role)
                        }
                    }
                }
                Section("Status") {
                    Picker("Status", selection: $editedStatus) {
                        ForEach(AccountStatus.allCases, id: \.self) { status in
                            HStack {
                                Image(systemName: status.icon)
                                Text(status.displayName)
                            }.tag(status)
                        }
                    }
                }
                Section {
                    Button("Save Changes", action: saveChanges)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .listRowBackground(AppColors.primary)
                }
            }
            .navigationTitle("User Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }

    private func saveChanges() {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].role = editedRole
            users[index].status = editedStatus
            users[index].isPending = (editedStatus == .pending)
        }
        dismiss()
    }
}
