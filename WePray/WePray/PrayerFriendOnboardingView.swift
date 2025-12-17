//
//  PrayerFriendOnboardingView.swift
//  WePray - Prayer Friend Naming Onboarding
//

import SwiftUI

struct PrayerFriendOnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var friendName: String = ""
    @State private var showError = false

    private let suggestedNames = [
        "Grace", "Hope", "Faith", "Joy", "Peace",
        "Emmanuel", "Gabriel", "Michael", "Seraph", "Angel"
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    nameInputSection
                    suggestionsSection
                    continueButton
                }
                .padding(24)
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Name Your Prayer Friend")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
                .multilineTextAlignment(.center)

            Text("Your Prayer Friend will guide you through prayers, devotionals, and spiritual growth. Give them a name that feels meaningful to you.")
                .font(.body)
                .foregroundColor(AppColors.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 40)
    }

    // MARK: - Name Input Section
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prayer Friend Name")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.accent)
                    .frame(width: 20)

                TextField("Enter a name...", text: $friendName)
                    .autocapitalization(.words)

                if !friendName.isEmpty {
                    Button(action: { friendName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.subtext)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(showError && friendName.isEmpty ? AppColors.error : AppColors.border, lineWidth: 1)
            )

            if showError && friendName.isEmpty {
                Text("Please enter a name for your Prayer Friend")
                    .font(.caption)
                    .foregroundColor(AppColors.error)
            }
        }
    }

    // MARK: - Suggestions Section
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggestions")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)

            FlowLayout(spacing: 8) {
                ForEach(suggestedNames, id: \.self) { name in
                    Button(action: { friendName = name }) {
                        Text(name)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(friendName == name ? AppColors.accent : AppColors.cardBackground)
                            .foregroundColor(friendName == name ? .white : AppColors.text)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Continue Button
    private var continueButton: some View {
        VStack(spacing: 16) {
            Button(action: handleContinue) {
                HStack {
                    Text("Continue")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }

            Button(action: skipOnboarding) {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Actions
    private func handleContinue() {
        if friendName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError = true
            return
        }
        appState.completePrayerFriendOnboarding(name: friendName.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func skipOnboarding() {
        appState.completePrayerFriendOnboarding(name: "Prayer Friend")
    }
}

// MARK: - Flow Layout for Suggestion Chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

#Preview {
    PrayerFriendOnboardingView()
        .environmentObject(AppState())
}
