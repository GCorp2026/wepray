//
//  LandingPageView.swift
//  WePray - Prayer Tutoring App
//
//  Cinematic landing page with featured prayers carousel

import SwiftUI

struct LandingPageView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAuth = false
    @State private var currentPrayerIndex = 0
    @State private var currentArticleIndex = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            CinematicPrayerBackground()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    BenefitsSection()
                    prayersCarouselSection
                    articlesCarouselSection
                    actionButtons
                    footerText
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showAuth) {
            AuthView()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            logoView
            VStack(spacing: 8) {
                Text("WePray")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(titleGradient)

                Text("Your Prayer Friend for Every Faith")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
    }

    private var logoView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.primary.opacity(0.3),
                            AppColors.primaryLight.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 20)

            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? .white : AppColors.primary,
                            colorScheme == .dark ? AppColors.primaryLight : AppColors.primaryDark
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private var titleGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? .white : AppColors.text,
                colorScheme == .dark ? AppColors.primaryLight : AppColors.primary
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Prayers Carousel Section
    private var prayersCarouselSection: some View {
        VStack(spacing: 16) {
            Text("Featured Prayers")
                .font(.headline)
                .foregroundColor(.secondary)

            FeaturedPrayersCarousel(
                prayers: appState.adminSettings.featuredPrayers.filter { $0.isActive },
                currentIndex: $currentPrayerIndex
            )
            .frame(height: 280)

            prayersCarouselIndicators
        }
    }

    private var prayersCarouselIndicators: some View {
        HStack(spacing: 8) {
            let activePrayers = appState.adminSettings.featuredPrayers.filter { $0.isActive }
            ForEach(0..<activePrayers.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPrayerIndex ? AppColors.primary : AppColors.border)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentPrayerIndex)
            }
        }
    }

    // MARK: - Articles Carousel Section
    private var articlesCarouselSection: some View {
        VStack(spacing: 16) {
            Text("Featured Articles")
                .font(.headline)
                .foregroundColor(.secondary)

            FeaturedArticlesCarousel(
                articles: appState.adminSettings.featuredArticles.filter { $0.isActive },
                currentIndex: $currentArticleIndex
            )
            .frame(height: 320)
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: { showAuth = true }) {
                HStack {
                    Image(systemName: "person.fill")
                    Text("Sign In / Sign Up")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }

            Button(action: { continueAsGuest() }) {
                HStack {
                    Image(systemName: "arrow.right.circle")
                    Text("Continue as Guest")
                }
                .font(.subheadline)
                .foregroundColor(AppColors.primary)
            }
        }
        .padding(.horizontal, 20)
    }

    private var footerText: some View {
        Text("Pray in 6 languages across 10 Christian traditions")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }

    private func continueAsGuest() {
        appState.currentUser = UserProfile.sample
        appState.isLoggedIn = true
    }
}

// MARK: - Cinematic Prayer Background
struct CinematicPrayerBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animate = false

    var body: some View {
        ZStack {
            baseGradient
            animatedOrbs
            floatingSymbols
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }

    private var baseGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark ? [
                Color.black,
                Color.indigo.opacity(0.02),
                Color.purple.opacity(0.01)
            ] : [
                Color.white,
                AppColors.primary.opacity(0.02),
                AppColors.secondary.opacity(0.01)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var animatedOrbs: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                AppColors.primary.opacity(colorScheme == .dark ? 0.05 : 0.03),
                                AppColors.secondary.opacity(colorScheme == .dark ? 0.03 : 0.01),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 200
                        )
                    )
                    .frame(width: CGFloat(150 + index * 30))
                    .position(
                        x: animate ? CGFloat(100 + index * 80) : CGFloat(200 + index * 50),
                        y: animate ? CGFloat(200 + index * 150) : CGFloat(300 + index * 100)
                    )
                    .blur(radius: 50)
                    .animation(
                        .easeInOut(duration: Double(8 + index * 2))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index)),
                        value: animate
                    )
            }
        }
    }

    private var floatingSymbols: some View {
        let symbols = ["cross.fill", "hands.sparkles", "star.fill", "heart.fill", "book.fill"]
        return ForEach(0..<5, id: \.self) { index in
            Image(systemName: symbols[index])
                .font(.system(size: CGFloat(20 + index * 3)))
                .foregroundColor(AppColors.primary.opacity(colorScheme == .dark ? 0.03 : 0.02))
                .position(
                    x: CGFloat(50 + index * 70),
                    y: CGFloat(100 + index * 150)
                )
                .blur(radius: 15)
        }
    }
}

#Preview {
    LandingPageView()
        .environmentObject(AppState())
}
