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

    // MARK: - Computed Properties (extracted to help compiler)
    private var createButtonBackground: some View {
        Group {
            if name.isEmpty {
                Color.gray
            } else {
                LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
            }
        }
    }

    private var privacyIcon: String {
        isPublic ? "globe" : "lock.fill"
    }

    private var privacyText: String {
        isPublic ? "Public Club" : "Private Club"
    }

    private var privacyHelpText: String {
        isPublic ? "Anyone can discover and join." : "Members must be approved."
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                formContent
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

    // MARK: - Form Content
    private var formContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                nameField
                descriptionField
                categorySection
                privacyToggle
                createButton
            }
            .padding()
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Club Name")
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.text)
            TextField("Enter club name", text: $name)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
        }
    }

    private var descriptionField: some View {
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
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.text)
            categoryScrollView
        }
    }

    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ClubCategory.allCases, id: \.self) { cat in
                    CategoryChipButton(
                        category: cat,
                        isSelected: category == cat,
                        onTap: { category = cat }
                    )
                }
            }
        }
    }

    private var privacyToggle: some View {
        VStack(spacing: 8) {
            Toggle(isOn: $isPublic) {
                HStack {
                    Image(systemName: privacyIcon)
                        .foregroundColor(AppColors.primary)
                    Text(privacyText)
                        .foregroundColor(AppColors.text)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)

            Text(privacyHelpText)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
    }

    private var createButton: some View {
        Button(action: createClub) {
            Text("Create Club")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(createButtonBackground)
                .cornerRadius(12)
        }
        .disabled(name.isEmpty)
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

// MARK: - Category Chip Button (extracted helper)
private struct CategoryChipButton: View {
    let category: ClubCategory
    let isSelected: Bool
    let onTap: () -> Void

    private var backgroundColor: Color {
        isSelected ? category.color : AppColors.cardBackground
    }

    private var textColor: Color {
        isSelected ? .white : AppColors.text
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(16)
        }
    }
}
