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
            PrayerChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(0)

            VoicePrayerView()
                .tabItem {
                    Label("Voice", systemImage: "mic.fill")
                }
                .tag(1)

            SpeakingPracticeView()
                .tabItem {
                    Label("Speak", systemImage: "waveform")
                }
                .tag(2)

            ListeningPracticeView()
                .tabItem {
                    Label("Listen", systemImage: "headphones")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)

            if appState.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "shield.fill")
                    }
                    .tag(5)
            }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
