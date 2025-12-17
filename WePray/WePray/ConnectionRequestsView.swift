//
//  ConnectionRequestsView.swift
//  WePray - Connection Management View
//

import SwiftUI

struct ConnectionRequestsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ConnectionViewModel()
    @State private var showSearchSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Stats Card
                    ConnectionStatsCard(stats: viewModel.stats)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Filter Chips
                    ConnectionFilterChips(selectedFilter: $viewModel.selectedFilter)
                        .padding(.vertical, 12)

                    // Connection List
                    if viewModel.filteredConnections.isEmpty {
                        EmptyConnectionsView(filter: viewModel.selectedFilter)
                            .frame(maxHeight: .infinity)
                    } else {
                        connectionList
                    }
                }

                // Floating Search Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        searchButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Network")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearchSheet = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showSearchSheet) {
                UserSearchView(viewModel: viewModel)
            }
        }
        .onAppear {
            if let userId = appState.currentUser?.id.uuidString {
                viewModel.setCurrentUser(id: userId)
            }
        }
    }

    // MARK: - Connection List
    private var connectionList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                switch viewModel.selectedFilter {
                case .all, .connected:
                    ForEach(viewModel.acceptedConnections) { connection in
                        ConnectionCard(
                            connection: connection,
                            onRemove: { viewModel.removeConnection(connectionId: connection.id) },
                            onMessage: { /* Navigate to messaging */ }
                        )
                    }
                case .pending:
                    ForEach(viewModel.pendingRequests) { connection in
                        ConnectionRequestCard(
                            connection: connection,
                            onAccept: { viewModel.acceptConnection(connectionId: connection.id) },
                            onReject: { viewModel.rejectConnection(connectionId: connection.id) }
                        )
                    }
                case .sent:
                    ForEach(viewModel.sentRequests) { connection in
                        SentRequestCard(
                            connection: connection,
                            onCancel: { viewModel.cancelRequest(connectionId: connection.id) }
                        )
                    }
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Search Button
    private var searchButton: some View {
        Button {
            showSearchSheet = true
        } label: {
            Image(systemName: "person.badge.plus")
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

// MARK: - User Search View
struct UserSearchView: View {
    @ObservedObject var viewModel: ConnectionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.subtext)

                        TextField("Search by name, profession, or skill...", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(AppColors.text)
                            .onChange(of: searchText) { _, newValue in
                                viewModel.searchUsers(query: newValue)
                            }

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                viewModel.clearSearch()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.subtext)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding()

                    // Results
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    } else if searchText.isEmpty {
                        searchPlaceholder
                    } else if viewModel.searchResults.isEmpty {
                        noResultsView
                    } else {
                        searchResultsList
                    }
                }
            }
            .navigationTitle("Find Connections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.text)
                    }
                }
            }
        }
    }

    // MARK: - Search Results List
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { user in
                    UserSearchResultCard(user: user) {
                        viewModel.sendConnectionRequest(to: user)
                        viewModel.searchUsers(query: searchText) // Refresh results
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Search Placeholder
    private var searchPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext.opacity(0.5))

            Text("Find Believers")
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            Text("Search for other believers by name,\nprofession, or skills.")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(40)
    }

    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext.opacity(0.5))

            Text("No Results")
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            Text("No users found matching \"\(searchText)\".\nTry a different search term.")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    ConnectionRequestsView()
        .environmentObject(AppState())
}
