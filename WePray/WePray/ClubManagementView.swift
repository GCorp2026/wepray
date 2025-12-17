//
//  ClubManagementView.swift
//  WePray - Club Management View
//

import SwiftUI

struct ClubManagementView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ClubViewModel()
    @State private var showCreateSheet = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Invitations Banner
                    if !viewModel.myInvitations.isEmpty {
                        invitationsBanner
                    }

                    // Filter Chips
                    ClubFilterChips(selectedFilter: $viewModel.selectedFilter)
                        .padding(.vertical, 8)

                    // Category Chips
                    ClubCategoryChips(selectedCategory: $viewModel.selectedCategory)
                        .padding(.bottom, 8)

                    // Club List
                    if viewModel.filteredClubs.isEmpty {
                        emptyView
                    } else {
                        clubList
                    }
                }

                // Floating Create Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        createButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Clubs")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, prompt: "Search clubs")
            .sheet(isPresented: $showCreateSheet) {
                CreateClubSheet(viewModel: viewModel)
            }
        }
        .onAppear {
            if let userId = appState.currentUser?.id.uuidString {
                viewModel.setCurrentUser(id: userId)
            }
        }
    }

    // MARK: - Invitations Banner
    private var invitationsBanner: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.myInvitations) { invitation in
                InvitationCard(
                    invitation: invitation,
                    onAccept: {
                        if let user = appState.currentUser {
                            viewModel.acceptInvitation(
                                invitationId: invitation.id,
                                userId: user.id.uuidString,
                                userName: user.displayName,
                                userRole: user.role
                            )
                        }
                    },
                    onDecline: {
                        viewModel.declineInvitation(invitationId: invitation.id)
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Club List
    private var clubList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // My Clubs Section
                if !viewModel.myClubs.isEmpty && viewModel.selectedFilter != .myClubs {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Clubs")
                            .font(.headline)
                            .foregroundColor(AppColors.text)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.myClubs) { club in
                                    NavigationLink(destination: ClubDetailView(club: club, viewModel: viewModel)) {
                                        MyClubCard(club: club)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // All Clubs Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.selectedFilter == .myClubs ? "My Clubs" : "Discover Clubs")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredClubs) { club in
                            NavigationLink(destination: ClubDetailView(club: club, viewModel: viewModel)) {
                                ClubCard(
                                    club: club,
                                    isMember: club.isMember(userId: appState.currentUser?.id.uuidString ?? ""),
                                    onJoin: {
                                        if let user = appState.currentUser {
                                            viewModel.requestToJoin(
                                                clubId: club.id,
                                                userId: user.id.uuidString,
                                                userName: user.displayName,
                                                userRole: user.role,
                                                message: ""
                                            )
                                        }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext.opacity(0.5))

            Text("No Clubs Found")
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            Text("Create a club or try a different search.")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(40)
    }

    // MARK: - Create Button
    private var createButton: some View {
        Button {
            showCreateSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

// Note: CreateClubSheet and ClubDetailView are in ClubDetailView.swift

#Preview {
    ClubManagementView()
        .environmentObject(AppState())
}
