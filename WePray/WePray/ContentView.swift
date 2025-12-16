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
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home - Prayer Chat
            PrayerChatView()
                .tabItem { Label("Pray", systemImage: "hands.sparkles.fill") }
                .tag(0)

            // Prayer Plans
            PrayerPlanListView()
                .tabItem { Label("Plans", systemImage: "calendar.badge.clock") }
                .tag(1)

            // Prayer Journal
            JournalListView()
                .tabItem { Label("Journal", systemImage: "book.fill") }
                .tag(2)

            // Community Feed
            FeedView()
                .tabItem { Label("Feed", systemImage: "rectangle.stack.fill") }
                .tag(3)

            // Prayer Requests
            PrayerRequestListView()
                .tabItem { Label("Requests", systemImage: "hand.raised.fill") }
                .tag(4)

            // Prayer Groups
            GroupsView()
                .tabItem { Label("Groups", systemImage: "person.3.fill") }
                .tag(5)

            // Practice (Voice & Speaking)
            VoicePrayerView()
                .tabItem { Label("Voice", systemImage: "mic.fill") }
                .tag(6)

            // Settings & Profile
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(7)

            // Admin (conditional)
            if appState.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem { Label("Admin", systemImage: "shield.fill") }
                    .tag(8)
            }
        }
        .accentColor(AppColors.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
