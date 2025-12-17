//
//  ConnectionFilterComponents.swift
//  WePray - Connection Filter & Stats UI Components
//

import SwiftUI

// MARK: - Connection Filter Chips
struct ConnectionFilterChips: View {
    @Binding var selectedFilter: ConnectionFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ConnectionFilter.allCases, id: \.self) { filter in
                    ConnectionFilterChip(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Connection Filter Chip
struct ConnectionFilterChip: View {
    let filter: ConnectionFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.displayName)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [AppColors.cardBackground, AppColors.cardBackground], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Connection Stats Card
struct ConnectionStatsCard: View {
    let stats: ConnectionStats

    var body: some View {
        HStack(spacing: 0) {
            ConnectionStatColumn(value: stats.totalConnections, label: "Connections", icon: "person.2.fill")
            Divider().frame(height: 40).background(AppColors.border)
            ConnectionStatColumn(value: stats.pendingRequests, label: "Requests", icon: "clock.fill")
            Divider().frame(height: 40).background(AppColors.border)
            ConnectionStatColumn(value: stats.sentRequests, label: "Sent", icon: "paperplane.fill")
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Connection Stat Column
struct ConnectionStatColumn: View {
    let value: Int
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(AppColors.primary)
                Text("\(value)")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.text)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty Connections View
struct EmptyConnectionsView: View {
    let filter: ConnectionFilter

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyIcon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.subtext.opacity(0.5))

            Text(emptyTitle)
                .font(.title2.bold())
                .foregroundColor(AppColors.text)

            Text(emptyMessage)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private var emptyIcon: String {
        switch filter {
        case .all, .connected: return "person.2.slash"
        case .pending: return "person.badge.clock"
        case .sent: return "paperplane"
        }
    }

    private var emptyTitle: String {
        switch filter {
        case .all, .connected: return "No Connections Yet"
        case .pending: return "No Pending Requests"
        case .sent: return "No Sent Requests"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .all, .connected: return "Start connecting with other believers!"
        case .pending: return "You have no pending connection requests."
        case .sent: return "You haven't sent any connection requests."
        }
    }
}
