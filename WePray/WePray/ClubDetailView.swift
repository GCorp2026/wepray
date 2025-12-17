//
//  ClubDetailView.swift
//  WePray - Club Detail View
//

import SwiftUI

// MARK: - Club Detail View
struct ClubDetailView: View {
    let club: Club
    @ObservedObject var viewModel: ClubViewModel
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    private var currentUserId: String {
        appState.currentUser?.id.uuidString ?? ""
    }

    private var myRole: ClubMemberRole? {
        club.getMemberRole(userId: currentUserId)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    clubHeader

                    // Tab Selector
                    Picker("", selection: $selectedTab) {
                        Text("Members (\(club.members.count))").tag(0)
                        if myRole?.canApproveRequests == true {
                            Text("Requests (\(club.pendingRequests.count))").tag(1)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Content
                    if selectedTab == 0 {
                        membersSection
                    } else {
                        requestsSection
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(club.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Club Header
    private var clubHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(club.gradient)
                    .frame(width: 80, height: 80)
                Image(systemName: club.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }

            HStack(spacing: 8) {
                Text(club.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(club.category.color.opacity(0.2))
                    .foregroundColor(club.category.color)
                    .cornerRadius(12)

                if !club.isPublic {
                    Label("Private", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Text(club.description)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("\(club.memberCount) members")
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Members Section
    private var membersSection: some View {
        LazyVStack(spacing: 8) {
            ForEach(club.members) { member in
                ClubMemberRow(
                    member: member,
                    canManage: myRole?.canRemoveMembers == true,
                    onRemove: {
                        viewModel.removeMember(clubId: club.id, memberId: member.id)
                    },
                    onChangeRole: { newRole in
                        viewModel.changeMemberRole(clubId: club.id, memberId: member.id, newRole: newRole)
                    }
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Requests Section
    private var requestsSection: some View {
        LazyVStack(spacing: 8) {
            if club.pendingRequests.isEmpty {
                Text("No pending requests")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .padding()
            } else {
                ForEach(club.pendingRequests) { request in
                    MemberRequestCard(
                        request: request,
                        onApprove: {
                            viewModel.approveRequest(clubId: club.id, requestId: request.id)
                        },
                        onReject: {
                            viewModel.rejectRequest(clubId: club.id, requestId: request.id)
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Create Club Sheet
struct CreateClubSheet: View {
    @ObservedObject var viewModel: ClubViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var category: ClubCategory = .prayer
    @State private var isPublic = true

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Club Name")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppColors.text)
                            TextField("Enter club name", text: $name)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppColors.text)
                            TextField("Describe your club", text: $description, axis: .vertical)
                                .lineLimit(3...5)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppColors.text)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(ClubCategory.allCases, id: \.self) { cat in
                                        Button {
                                            category = cat
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: cat.icon)
                                                Text(cat.rawValue)
                                            }
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(category == cat ? cat.color : AppColors.cardBackground)
                                            .foregroundColor(category == cat ? .white : AppColors.text)
                                            .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }

                        // Privacy
                        Toggle(isOn: $isPublic) {
                            HStack {
                                Image(systemName: isPublic ? "globe" : "lock.fill")
                                    .foregroundColor(AppColors.primary)
                                Text(isPublic ? "Public Club" : "Private Club")
                                    .foregroundColor(AppColors.text)
                            }
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)

                        Text(isPublic ? "Anyone can discover and join." : "Members must be approved.")
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)

                        // Create Button
                        Button {
                            createClub()
                        } label: {
                            Text("Create Club")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    name.isEmpty ? Color.gray : LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                        }
                        .disabled(name.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Club")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
            }
        }
    }

    private func createClub() {
        guard let user = appState.currentUser else { return }
        viewModel.createClub(
            name: name,
            description: description,
            category: category,
            isPublic: isPublic,
            creatorId: user.id.uuidString,
            creatorName: user.displayName,
            creatorRole: user.role
        )
        dismiss()
    }
}
