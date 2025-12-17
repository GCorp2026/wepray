//
//  AdminUserViewModel.swift
//  WePray - Admin User Management ViewModel
//

import SwiftUI

class AdminUserViewModel: ObservableObject {
    @Published var users: [ManagedUser] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: UserFilter = .all
    @Published var isLoading = false

    private let usersKey = "WePrayManagedUsers"

    init() {
        loadUsers()
    }

    // MARK: - Load Users
    func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decodedUsers = try? JSONDecoder().decode([ManagedUser].self, from: data) {
            users = decodedUsers
        } else {
            users = ManagedUser.sampleUsers
            saveUsers()
        }
    }

    // MARK: - Save Users
    private func saveUsers() {
        if let encodedData = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encodedData, forKey: usersKey)
        }
    }

    // MARK: - User Actions
    func approveUser(id: UUID) {
        updateUser(id: id) { user in
            user.status = .active
            user.isPending = false
        }
    }

    func promoteUser(id: UUID) {
        updateUser(id: id) { user in
            switch user.role {
            case .user: user.role = .premium
            case .premium: user.role = .admin
            case .admin: user.role = .superAdmin
            case .superAdmin: break
            }
        }
    }

    func demoteUser(id: UUID) {
        updateUser(id: id) { user in
            switch user.role {
            case .superAdmin: user.role = .admin
            case .admin: user.role = .premium
            case .premium: user.role = .user
            case .user: break
            }
        }
    }

    func suspendUser(id: UUID) {
        updateUser(id: id) { user in
            user.status = .suspended
        }
    }

    func unsuspendUser(id: UUID) {
        updateUser(id: id) { user in
            user.status = .active
        }
    }

    func banUser(id: UUID) {
        updateUser(id: id) { user in
            user.status = .banned
        }
    }

    func unbanUser(id: UUID) {
        updateUser(id: id) { user in
            user.status = .active
        }
    }

    func deleteUser(id: UUID) {
        users.removeAll { $0.id == id }
        saveUsers()
    }

    func changeRole(id: UUID, to newRole: UserRole) {
        updateUser(id: id) { user in
            user.role = newRole
        }
    }

    private func updateUser(id: UUID, update: (inout ManagedUser) -> Void) {
        if let index = users.firstIndex(where: { $0.id == id }) {
            update(&users[index])
            users[index].lastActive = Date()
            saveUsers()
        }
    }

    // MARK: - Filtered Users
    var filteredUsers: [ManagedUser] {
        var result = users

        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .pending:
            result = result.filter { $0.status == .pending }
        case .active:
            result = result.filter { $0.status == .active }
        case .suspended:
            result = result.filter { $0.status == .suspended }
        case .banned:
            result = result.filter { $0.status == .banned }
        case .admins:
            result = result.filter { $0.role == .admin || $0.role == .superAdmin }
        case .premium:
            result = result.filter { $0.role == .premium }
        }

        return result.sorted { $0.displayName < $1.displayName }
    }

    // MARK: - Statistics
    var totalUsers: Int { users.count }
    var pendingCount: Int { users.filter { $0.status == .pending }.count }
    var activeCount: Int { users.filter { $0.status == .active }.count }
    var suspendedCount: Int { users.filter { $0.status == .suspended }.count }
    var adminCount: Int { users.filter { $0.role == .admin || $0.role == .superAdmin }.count }
    var premiumCount: Int { users.filter { $0.role == .premium }.count }

    // MARK: - Available Actions
    func availableActions(for user: ManagedUser) -> [UserAction] {
        var actions: [UserAction] = []

        // Pending approval
        if user.status == .pending {
            actions.append(.approve)
        }

        // Role changes (can't demote superAdmin or promote to superAdmin easily)
        if user.role != .superAdmin {
            actions.append(.promote)
        }
        if user.role != .user {
            actions.append(.demote)
        }

        // Status changes
        switch user.status {
        case .active:
            actions.append(.suspend)
            actions.append(.ban)
        case .suspended:
            actions.append(.unsuspend)
            actions.append(.ban)
        case .banned:
            actions.append(.unban)
        case .pending:
            actions.append(.ban)
        }

        // Always available (except for superAdmin)
        if user.role != .superAdmin {
            actions.append(.resetPassword)
            actions.append(.delete)
        }

        return actions
    }

    // MARK: - Perform Action
    func performAction(_ action: UserAction, on userId: UUID) {
        switch action {
        case .approve: approveUser(id: userId)
        case .promote: promoteUser(id: userId)
        case .demote: demoteUser(id: userId)
        case .suspend: suspendUser(id: userId)
        case .unsuspend: unsuspendUser(id: userId)
        case .ban: banUser(id: userId)
        case .unban: unbanUser(id: userId)
        case .delete: deleteUser(id: userId)
        case .resetPassword: break // Would trigger password reset flow
        }
    }

    // MARK: - Refresh
    func refresh() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadUsers()
            self?.isLoading = false
        }
    }
}
