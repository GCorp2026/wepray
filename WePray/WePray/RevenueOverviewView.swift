//
//  RevenueOverviewView.swift
//  WePray - Revenue Overview for Super Admin
//

import SwiftUI

struct RevenueOverviewView: View {
    @State private var stats = RevenueStats.sample
    @State private var selectedPeriod: TimePeriod = .month

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                periodSelector

                // Total Revenue Card
                totalRevenueCard

                // Revenue Breakdown
                revenueBreakdownSection

                // Subscriber Stats
                subscriberStatsSection

                // Payout Summary
                payoutSummarySection

                // Key Metrics
                keyMetricsSection
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Revenue Overview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation { selectedPeriod = period }
                } label: {
                    Text(period.rawValue)
                        .font(.subheadline.weight(selectedPeriod == period ? .semibold : .regular))
                        .foregroundColor(selectedPeriod == period ? .white : AppColors.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedPeriod == period ? AppColors.primary : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private var totalRevenueCard: some View {
        VStack(spacing: 12) {
            Text("Total Revenue")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
            Text(stats.totalRevenue, format: .currency(code: "USD"))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.text)
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(AppColors.success)
                Text("+12.5% from last month")
                    .font(.caption)
                    .foregroundColor(AppColors.success)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(colors: [AppColors.primary.opacity(0.1), AppColors.primaryLight.opacity(0.05)],
                          startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
    }

    private var revenueBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Revenue Breakdown")
                .font(.headline)
                .foregroundColor(AppColors.text)

            VStack(spacing: 12) {
                revenueRow(title: "Subscriptions", amount: stats.subscriptionRevenue, icon: "creditcard.fill", color: Color(hex: "#8B5CF6"))
                revenueRow(title: "Events", amount: stats.eventRevenue, icon: "calendar", color: Color(hex: "#3B82F6"))
                revenueRow(title: "Donations", amount: stats.donationRevenue, icon: "heart.fill", color: Color(hex: "#EC4899"))
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func revenueRow(title: String, amount: Double, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.text)
                Text("\(Int((amount / stats.monthlyRevenue) * 100))% of monthly")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()

            Text(amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundColor(AppColors.text)
        }
    }

    private var subscriberStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscribers")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 16) {
                subscriberStat(value: "\(stats.activeSubscribers)", label: "Active", color: AppColors.success)
                subscriberStat(value: "+\(stats.newSubscribersThisMonth)", label: "New", color: AppColors.primary)
                subscriberStat(value: String(format: "%.1f%%", stats.churnRate), label: "Churn", color: AppColors.error)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func subscriberStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .frame(maxWidth: .infinity)
    }

    private var payoutSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payouts")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 16) {
                payoutCard(title: "Total Paid", amount: stats.totalPayouts, color: AppColors.success)
                payoutCard(title: "Pending", amount: stats.pendingPayouts, color: Color(hex: "#F59E0B"))
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func payoutCard(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
            Text(amount, format: .currency(code: "USD"))
                .font(.title3.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)
                .foregroundColor(AppColors.text)

            VStack(spacing: 12) {
                metricRow(title: "Avg. Revenue Per User", value: String(format: "$%.2f", stats.averageRevenuePerUser))
                metricRow(title: "Monthly Revenue", value: stats.monthlyRevenue.formatted(.currency(code: "USD")))
                metricRow(title: "Net Revenue", value: (stats.monthlyRevenue - stats.pendingPayouts).formatted(.currency(code: "USD")))
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.text)
        }
    }
}

// MARK: - Time Period
enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
}
