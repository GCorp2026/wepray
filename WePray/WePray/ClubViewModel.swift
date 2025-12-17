//
//  ClubViewModel.swift
//  WePray - Club Management ViewModel
//

import SwiftUI

class ClubViewModel: ObservableObject {
    @Published var clubs: [Club] = []
    @Published var myInvitations: [ClubInvitation] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var selectedFilter: ClubFilter = .all
    @Published var selectedCategory: ClubCategory?

    private let clubsKey = "WePrayClubs"
    private let invitationsKey = "WePrayClubInvitations"
    private var currentUserId: String = ""

    init() {
        loadClubs()
        loadInvitations()
    }

    // MARK: - Load Clubs
    func loadClubs() {
        if let data = UserDefaults.standard.data(forKey: clubsKey),
           let decoded = try? JSONDecoder().decode([Club].self, from: data) {
            clubs = decoded
        } else {
            clubs = Club.sampleClubs
            saveClubs()
        }
    }

    // MARK: - Save Clubs
    private func saveClubs() {
        if let encoded = try? JSONEncoder().encode(clubs) {
            UserDefaults.standard.set(encoded, forKey: clubsKey)
        }
    }

    // MARK: - Load Invitations
    func loadInvitations() {
        if let data = UserDefaults.standard.data(forKey: invitationsKey),
           let decoded = try? JSONDecoder().decode([ClubInvitation].self, from: data) {
            myInvitations = decoded.filter { $0.invitedUserId == currentUserId && $0.status == .pending }
        }
    }

    // MARK: - Save Invitations
    private func saveInvitations() {
        if let encoded = try? JSONEncoder().encode(myInvitations) {
            UserDefaults.standard.set(encoded, forKey: invitationsKey)
        }
    }

    // MARK: - Create Club
    func createClub(name: String, description: String, category: ClubCategory, isPublic: Bool,
                    creatorId: String, creatorName: String, creatorRole: UserRole) {
        let ownerMember = ClubMember(
            userId: creatorId,
            userName: creatorName,
            userInitials: String(creatorName.prefix(2)).uppercased(),
            userRole: creatorRole,
            clubRole: .owner,
            joinedAt: Date()
        )

        let newClub = Club(
            name: name,
            description: description,
            category: category,
            iconName: category.icon,
            gradientColors: ["#1E3A8A", "#3B82F6"],
            isPublic: isPublic,
            memberCount: 1,
            createdBy: creatorId,
            createdByName: creatorName,
            createdAt: Date(),
            members: [ownerMember],
            pendingRequests: []
        )

        clubs.insert(newClub, at: 0)
        saveClubs()
    }

    // MARK: - Update Club
    func updateClub(clubId: UUID, name: String, description: String, category: ClubCategory, isPublic: Bool) {
        if let index = clubs.firstIndex(where: { $0.id == clubId }) {
            clubs[index].name = name
            clubs[index].description = description
            clubs[index].category = category
            clubs[index].isPublic = isPublic
            clubs[index].iconName = category.icon
            saveClubs()
        }
    }

    // MARK: - Delete Club
    func deleteClub(clubId: UUID) {
        clubs.removeAll { $0.id == clubId }
        saveClubs()
    }

    // MARK: - Request to Join
    func requestToJoin(clubId: UUID, userId: String, userName: String, userRole: UserRole, message: String) {
        guard let index = clubs.firstIndex(where: { $0.id == clubId }) else { return }

        let request = ClubMemberRequest(
            userId: userId,
            userName: userName,
            userInitials: String(userName.prefix(2)).uppercased(),
            userRole: userRole,
            message: message,
            requestedAt: Date()
        )

        clubs[index].pendingRequests.append(request)
        saveClubs()
    }

    // MARK: - Approve Request
    func approveRequest(clubId: UUID, requestId: UUID) {
        guard let clubIndex = clubs.firstIndex(where: { $0.id == clubId }),
              let requestIndex = clubs[clubIndex].pendingRequests.firstIndex(where: { $0.id == requestId }) else { return }

        let request = clubs[clubIndex].pendingRequests[requestIndex]

        let newMember = ClubMember(
            userId: request.userId,
            userName: request.userName,
            userInitials: request.userInitials,
            userRole: request.userRole,
            clubRole: .member,
            joinedAt: Date()
        )

        clubs[clubIndex].members.append(newMember)
        clubs[clubIndex].pendingRequests.remove(at: requestIndex)
        clubs[clubIndex].memberCount += 1
        saveClubs()
    }

    // MARK: - Reject Request
    func rejectRequest(clubId: UUID, requestId: UUID) {
        guard let clubIndex = clubs.firstIndex(where: { $0.id == clubId }) else { return }
        clubs[clubIndex].pendingRequests.removeAll { $0.id == requestId }
        saveClubs()
    }

    // MARK: - Invite User
    func inviteUser(clubId: UUID, clubName: String, inviterId: String, inviterName: String, invitedUserId: String) {
        let invitation = ClubInvitation(
            clubId: clubId,
            clubName: clubName,
            invitedBy: inviterId,
            invitedByName: inviterName,
            invitedUserId: invitedUserId,
            invitedAt: Date()
        )
        myInvitations.append(invitation)
        saveInvitations()
    }

    // MARK: - Accept Invitation
    func acceptInvitation(invitationId: UUID, userId: String, userName: String, userRole: UserRole) {
        guard let invIndex = myInvitations.firstIndex(where: { $0.id == invitationId }) else { return }
        let invitation = myInvitations[invIndex]

        guard let clubIndex = clubs.firstIndex(where: { $0.id == invitation.clubId }) else { return }

        let newMember = ClubMember(
            userId: userId,
            userName: userName,
            userInitials: String(userName.prefix(2)).uppercased(),
            userRole: userRole,
            clubRole: .member,
            joinedAt: Date()
        )

        clubs[clubIndex].members.append(newMember)
        clubs[clubIndex].memberCount += 1
        myInvitations.remove(at: invIndex)

        saveClubs()
        saveInvitations()
    }

    // MARK: - Decline Invitation
    func declineInvitation(invitationId: UUID) {
        myInvitations.removeAll { $0.id == invitationId }
        saveInvitations()
    }

    // MARK: - Remove Member
    func removeMember(clubId: UUID, memberId: UUID) {
        guard let clubIndex = clubs.firstIndex(where: { $0.id == clubId }) else { return }
        clubs[clubIndex].members.removeAll { $0.id == memberId }
        clubs[clubIndex].memberCount -= 1
        saveClubs()
    }

    // MARK: - Change Member Role
    func changeMemberRole(clubId: UUID, memberId: UUID, newRole: ClubMemberRole) {
        guard let clubIndex = clubs.firstIndex(where: { $0.id == clubId }),
              let memberIndex = clubs[clubIndex].members.firstIndex(where: { $0.id == memberId }) else { return }
        clubs[clubIndex].members[memberIndex].clubRole = newRole
        saveClubs()
    }

    // MARK: - Leave Club
    func leaveClub(clubId: UUID, userId: String) {
        guard let clubIndex = clubs.firstIndex(where: { $0.id == clubId }) else { return }
        clubs[clubIndex].members.removeAll { $0.userId == userId }
        clubs[clubIndex].memberCount -= 1
        saveClubs()
    }

    // MARK: - Filtered Clubs
    var filteredClubs: [Club] {
        var result = clubs

        // Apply filter
        switch selectedFilter {
        case .all: break
        case .myClubs:
            result = result.filter { $0.isMember(userId: currentUserId) }
        case .publicClubs:
            result = result.filter { $0.isPublic }
        case .privateClubs:
            result = result.filter { !$0.isPublic }
        }

        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Apply search
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.description.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return result.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - My Clubs
    var myClubs: [Club] {
        clubs.filter { $0.isMember(userId: currentUserId) }
    }

    // MARK: - Set Current User
    func setCurrentUser(id: String) {
        currentUserId = id
        loadInvitations()
    }

    // MARK: - Refresh
    func refresh() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadClubs()
            self?.loadInvitations()
            self?.isLoading = false
        }
    }
}
