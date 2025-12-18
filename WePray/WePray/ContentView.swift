//
//  ContentView.swift
//  WePray - Prayer Tutoring App
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            Group {
                if appState.isLoggedIn {
                    MainTabView()
                } else {
                    LandingPageView()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Daily Devotionals (FIRST)
            DevotionalListView()
                .tabItem { Label("Devos", systemImage: "sun.max.fill") }
                .tag(0)

            // Scripture Memory (SECOND)
            ScriptureMemoryView()
                .tabItem { Label("Memory", systemImage: "book.closed.fill") }
                .tag(1)

            // Prayer Chat
            PrayerChatView()
                .tabItem { Label("Pray", systemImage: "hands.sparkles.fill") }
                .tag(2)

            // Prayer Plans
            PrayerPlanListView()
                .tabItem { Label("Plans", systemImage: "calendar.badge.clock") }
                .tag(3)

            // Guided Meditation
            MeditationListView()
                .tabItem { Label("Meditate", systemImage: "sparkles") }
                .tag(4)

            // Prayer Journal
            JournalListView()
                .tabItem { Label("Journal", systemImage: "book.fill") }
                .tag(5)

            // Events & Meetings
            EventListView()
                .tabItem { Label("Events", systemImage: "calendar.badge.plus") }
                .tag(6)

            // Tweet Timeline
            TweetTimelineView()
                .tabItem { Label("Tweets", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(7)

            // Community Feed
            FeedView()
                .tabItem { Label("Feed", systemImage: "rectangle.stack.fill") }
                .tag(8)

            // Prayer Requests
            PrayerRequestListView()
                .tabItem { Label("Requests", systemImage: "hand.raised.fill") }
                .tag(9)

            // Prayer Groups
            GroupsView()
                .tabItem { Label("Groups", systemImage: "person.3.fill") }
                .tag(10)

            // Clubs Management
            ClubManagementView()
                .tabItem { Label("Clubs", systemImage: "building.2.fill") }
                .tag(11)

            // Professional Network
            ConnectionRequestsView()
                .tabItem { Label("Network", systemImage: "person.2.fill") }
                .tag(12)

            // Private Messages
            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
                .tag(13)

            // Practice (Voice & Speaking)
            VoicePrayerView()
                .tabItem { Label("Voice", systemImage: "mic.fill") }
                .tag(14)

            // Settings & Profile
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(15)

            // Admin (conditional)
            if appState.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem { Label("Admin", systemImage: "shield.fill") }
                    .tag(16)
            }
        }
        .accentColor(AppColors.accent)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .fullScreenCover(isPresented: $appState.showPrayerFriendOnboarding) {
            PrayerFriendOnboardingView()
                .environmentObject(appState)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
