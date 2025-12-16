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

            // Community Feed
            FeedView()
                .tabItem { Label("Feed", systemImage: "rectangle.stack.fill") }
                .tag(1)

            // Prayer Groups
            GroupsView()
                .tabItem { Label("Groups", systemImage: "person.3.fill") }
                .tag(2)

            // Practice (Voice & Speaking)
            VoicePrayerView()
                .tabItem { Label("Voice", systemImage: "mic.fill") }
                .tag(3)

            // Settings & Profile
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)

            // Admin (conditional)
            if appState.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem { Label("Admin", systemImage: "shield.fill") }
                    .tag(5)
            }
        }
        .accentColor(AppColors.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
