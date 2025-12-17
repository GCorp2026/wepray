//
//  ConnectionViewModel.swift
//  WePray - Connection Management ViewModel
//

import SwiftUI

class ConnectionViewModel: ObservableObject {
    @Published var connections: [Connection] = []
    @Published var searchResults: [UserSearchResult] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var selectedFilter: ConnectionFilter = .all
    @Published var stats: ConnectionStats = .empty

    private let connectionsKey = "WePrayConnections"
    private var currentUserId: String = ""

    init() {
        loadConnections()
        updateStats()
    }

    // MARK: - Load Connections
    func loadConnections() {
        if let data = UserDefaults.standard.data(forKey: connectionsKey),
           let decoded = try? JSONDecoder().decode([Connection].self, from: data) {
            connections = decoded
        } else {
            connections = Connection.sampleConnections
            saveConnections()
        }
        updateStats()
    }

    // MARK: - Save Connections
    private func saveConnections() {
        if let encoded = try? JSONEncoder().encode(connections) {
            UserDefaults.standard.set(encoded, forKey: connectionsKey)
        }
    }

    // MARK: - Update Stats
    private func updateStats() {
        stats = ConnectionStats(
            totalConnections: connections.filter { $0.status == .accepted }.count,
            pendingRequests: connections.filter { $0.status == .pending && $0.isIncoming }.count,
            sentRequests: connections.filter { $0.status == .pending && !$0.isIncoming }.count
        )
    }

    // MARK: - Send Connection Request
    func sendConnectionRequest(to user: UserSearchResult, message: String = "") {
        let newConnection = Connection(
            userId: user.id,
            userName: user.displayName,
            userRole: user.role,
            userEmail: user.email,
            status: .pending,
            requestDate: Date(),
            isIncoming: false
        )
        connections.insert(newConnection, at: 0)
        saveConnections()
        updateStats()
    }

    // MARK: - Accept Connection
    func acceptConnection(connectionId: UUID) {
        if let index = connections.firstIndex(where: { $0.id == connectionId }) {
            connections[index].status = .accepted
            connections[index].acceptedDate = Date()
            saveConnections()
            updateStats()
        }
    }

    // MARK: - Reject Connection
    func rejectConnection(connectionId: UUID) {
        if let index = connections.firstIndex(where: { $0.id == connectionId }) {
            connections[index].status = .rejected
            saveConnections()
            updateStats()
        }
    }

    // MARK: - Block Connection
    func blockConnection(connectionId: UUID) {
        if let index = connections.firstIndex(where: { $0.id == connectionId }) {
            connections[index].status = .blocked
            saveConnections()
            updateStats()
        }
    }

    // MARK: - Remove Connection
    func removeConnection(connectionId: UUID) {
        connections.removeAll { $0.id == connectionId }
        saveConnections()
        updateStats()
    }

    // MARK: - Cancel Sent Request
    func cancelRequest(connectionId: UUID) {
        connections.removeAll { $0.id == connectionId }
        saveConnections()
        updateStats()
    }

    // MARK: - Filtered Connections
    var filteredConnections: [Connection] {
        var result = connections

        switch selectedFilter {
        case .all:
            result = connections.filter { $0.status == .accepted }
        case .connected:
            result = connections.filter { $0.status == .accepted }
        case .pending:
            result = connections.filter { $0.status == .pending && $0.isIncoming }
        case .sent:
            result = connections.filter { $0.status == .pending && !$0.isIncoming }
        }

        return result.sorted { $0.requestDate > $1.requestDate }
    }

    // MARK: - Pending Requests
    var pendingRequests: [Connection] {
        connections.filter { $0.status == .pending && $0.isIncoming }
            .sorted { $0.requestDate > $1.requestDate }
    }

    // MARK: - Sent Requests
    var sentRequests: [Connection] {
        connections.filter { $0.status == .pending && !$0.isIncoming }
            .sorted { $0.requestDate > $1.requestDate }
    }

    // MARK: - Accepted Connections
    var acceptedConnections: [Connection] {
        connections.filter { $0.status == .accepted }
            .sorted { ($0.acceptedDate ?? $0.requestDate) > ($1.acceptedDate ?? $1.requestDate) }
    }

    // MARK: - Search Users
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            // Filter sample users by query
            let lowerQuery = query.lowercased()
            self.searchResults = UserSearchResult.sampleUsers.filter { user in
                user.displayName.lowercased().contains(lowerQuery) ||
                (user.profession?.lowercased().contains(lowerQuery) ?? false) ||
                (user.skills?.contains { $0.lowercased().contains(lowerQuery) } ?? false)
            }.map { user in
                var result = user
                // Check if already connected
                if let conn = self.connections.first(where: { $0.userId == user.id }) {
                    result.connectionStatus = conn.status
                }
                return result
            }
            self.isLoading = false
        }
    }

    // MARK: - Check Connection Status
    func connectionStatus(for userId: String) -> ConnectionStatus? {
        connections.first { $0.userId == userId }?.status
    }

    // MARK: - Is Connected
    func isConnected(to userId: String) -> Bool {
        connections.contains { $0.userId == userId && $0.status == .accepted }
    }

    // MARK: - Has Pending Request
    func hasPendingRequest(to userId: String) -> Bool {
        connections.contains { $0.userId == userId && $0.status == .pending }
    }

    // MARK: - Set Current User
    func setCurrentUser(id: String) {
        currentUserId = id
    }

    // MARK: - Refresh
    func refresh() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadConnections()
            self?.isLoading = false
        }
    }

    // MARK: - Clear Search
    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }
}
