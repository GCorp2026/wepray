//
//  SubscriptionView.swift
//  WePray - Subscription Management
//

import SwiftUI

// MARK: - Subscription Tier
enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "Free"
    case standard = "Standard"
    case premium = "Premium"

    var price: String {
        switch self {
        case .free: return "Free"
        case .standard: return "$4.99"
        case .premium: return "$9.99"
        }
    }

    var period: String {
        switch self {
        case .free: return "Forever"
        case .standard, .premium: return "per month"
        }
    }

    var features: [SubscriptionFeature] {
        switch self {
        case .free:
            return [
                SubscriptionFeature(name: "5 Featured Prayers", included: true),
                SubscriptionFeature(name: "3 Articles per day", included: true),
                SubscriptionFeature(name: "Basic Prayer Timer", included: true),
                SubscriptionFeature(name: "All Prayers & Articles", included: false),
                SubscriptionFeature(name: "AI Prayer Guidance", included: false),
                SubscriptionFeature(name: "Voice Prayers", included: false)
            ]
        case .standard:
            return [
                SubscriptionFeature(name: "All 10 Featured Prayers", included: true),
                SubscriptionFeature(name: "Unlimited Articles", included: true),
                SubscriptionFeature(name: "Community Groups", included: true),
                SubscriptionFeature(name: "Prayer Feed Access", included: true),
                SubscriptionFeature(name: "AI Prayer Guidance", included: false),
                SubscriptionFeature(name: "Voice Prayers", included: false)
            ]
        case .premium:
            return [
                SubscriptionFeature(name: "Everything in Standard", included: true),
                SubscriptionFeature(name: "AI Prayer Guidance", included: true),
                SubscriptionFeature(name: "Voice Prayer Mode", included: true),
                SubscriptionFeature(name: "Speaking Practice", included: true),
                SubscriptionFeature(name: "Listening Practice", included: true),
                SubscriptionFeature(name: "Priority Support", included: true)
            ]
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .free: return [Color(hex: "#1E293B"), Color(hex: "#334155")]
        case .standard: return [Color(hex: "#1E3A8A"), Color(hex: "#3B82F6")]
        case .premium: return [Color(hex: "#0F172A"), Color(hex: "#1E3A8A"), Color(hex: "#60A5FA")]
        }
    }

    var iconName: String {
        switch self {
        case .free: return "heart"
        case .standard: return "star.fill"
        case .premium: return "crown.fill"
        }
    }
}

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let name: String
    let included: Bool
}

// MARK: - Subscription View
struct SubscriptionView: View {
    @State private var currentPlan: SubscriptionTier = .free
    @State private var selectedTier: SubscriptionTier = .standard
    @StateObject private var stripeService = StripeService.shared
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss

    // TODO: Replace with actual user ID from auth
    private let userId = "user_placeholder_id"

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.accent)

                            Text("Unlock Your Prayer Journey")
                                .font(.title2.bold())
                                .foregroundColor(AppColors.text)

                            Text("Choose the plan that's right for you")
                                .font(.subheadline)
                                .foregroundColor(AppColors.subtext)
                        }
                        .padding(.top)

                        // Subscription Cards
                        ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                            SubscriptionCard(
                                tier: tier,
                                isCurrentPlan: currentPlan == tier,
                                isSelected: selectedTier == tier,
                                onSelect: { selectedTier = tier },
                                onSubscribe: { subscribeTo(tier) }
                            )
                        }

                        // Terms
                        Text("Cancel anytime. Subscriptions auto-renew.")
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)
                            .padding(.bottom)
                    }
                    .padding()
                }
            }
                // Loading Overlay
                if stripeService.isProcessingPayment {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Processing payment...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(32)
                    .background(Color(hex: "#1E293B"))
                    .cornerRadius(16)
                }
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
            }
            .alert("Payment Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("You are now subscribed to \(currentPlan.rawValue)!")
            }
        }
    }

    private func subscribeTo(_ tier: SubscriptionTier) {
        Task {
            let result = await stripeService.processPayment(for: tier, userId: userId)
            switch result {
            case .success(let status):
                if let tierString = SubscriptionTier(rawValue: status.tier.capitalized) {
                    currentPlan = tierString
                } else {
                    currentPlan = tier
                }
                showSuccess = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Subscription Card
struct SubscriptionCard: View {
    let tier: SubscriptionTier
    let isCurrentPlan: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    let onSubscribe: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: tier.iconName)
                    .font(.title2)
                    .foregroundColor(.white)

                Text(tier.rawValue)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                if isCurrentPlan {
                    Text("CURRENT")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
            }

            // Price
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(tier.price)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Text(tier.period)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()
            }

            Divider().background(Color.white.opacity(0.3))

            // Features
            VStack(alignment: .leading, spacing: 10) {
                ForEach(tier.features) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: feature.included ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundColor(feature.included ? .green : .white.opacity(0.4))

                        Text(feature.name)
                            .font(.subheadline)
                            .foregroundColor(feature.included ? .white : .white.opacity(0.5))
                    }
                }
            }

            // Subscribe Button
            Button(action: onSubscribe) {
                Text(isCurrentPlan ? "Current Plan" : "Subscribe")
                    .font(.headline)
                    .foregroundColor(isCurrentPlan ? .white.opacity(0.6) : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCurrentPlan ? Color.white.opacity(0.1) : Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
            .disabled(isCurrentPlan)
        }
        .padding(20)
        .background(
            LinearGradient(colors: tier.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected && !isCurrentPlan ? AppColors.accent : Color.clear, lineWidth: 3)
        )
        .shadow(color: tier.gradientColors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 5)
        .onTapGesture { onSelect() }
    }
}

#Preview {
    SubscriptionView()
}
