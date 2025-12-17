//
//  AdminUserManagementView.swift
//  WePray - Admin User Management
//

import SwiftUI

// MARK: - Admin User Management View
struct AdminUserManagementView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AdminUserViewModel()
    @State private var showingAddUser = false
    @State private var selectedUser: ManagedUser?

    var body: some View {
        VStack(spacing: 0) {
            statsHeader
            filterBar
            userListSection
        }
        .background(AppColors.background)
        .navigationTitle("User Management")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search users...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingAddUser = true } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView(users: $viewModel.users)
        }
        .sheet(item: $selectedUser) { user in
            UserDetailSheet(user: user, users: $viewModel.users)
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(title: "Total", value: "\(viewModel.totalUsers)", icon: "person.3.fill", color: AppColors.primary)
            StatCard(title: "Admins", value: "\(viewModel.adminCount)", icon: "shield.fill", color: .blue)
            StatCard(title: "Premium", value: "\(viewModel.premiumCount)", icon: "star.fill", color: .purple)
            StatCard(title: "Pending", value: "\(viewModel.pendingCount)", icon: "clock.fill", color: .orange)
        }
        .padding()
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(UserFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        icon: filter.icon,
                        color: AppColors.accent,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(AppColors.cardBackground)
    }

    // MARK: - User List
    private var userListSection: some View {
        Group {
            if viewModel.filteredUsers.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.subtext.opacity(0.5))
                    Text("No users found")
                        .font(.headline)
                        .foregroundColor(AppColors.subtext)
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.filteredUsers) { user in
                        UserRow(user: user)
                            .listRowBackground(AppColors.cardBackground)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedUser = user }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteUser(id: user.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                if user.status == .pending {
                                    Button {
                                        viewModel.approveUser(id: user.id)
                                    } label: {
                                        Label("Approve", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationView {
        AdminUserManagementView()
            .environmentObject(AppState())
    }
}
