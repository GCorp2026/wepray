//
//  GroupsView.swift
//  WePray - Prayer Community Groups
//

import SwiftUI

// MARK: - Prayer Group Model
struct PrayerGroup: Identifiable, Codable {
    var id = UUID()
    let name: String
    let description: String
    var memberCount: Int
    let iconName: String
    let gradientColors: [String]
    var isJoined: Bool

    static let sampleGroups: [PrayerGroup] = [
        PrayerGroup(name: "Morning Prayer", description: "Start your day with prayer and devotion.", memberCount: 156, iconName: "sun.max.fill", gradientColors: ["#1E3A8A", "#3B82F6"], isJoined: false),
        PrayerGroup(name: "Evening Devotion", description: "End your day with gratitude and reflection.", memberCount: 223, iconName: "moon.stars.fill", gradientColors: ["#1A237E", "#5C6BC0"], isJoined: true),
        PrayerGroup(name: "Healing Prayers", description: "Prayers for healing, strength and recovery.", memberCount: 89, iconName: "heart.fill", gradientColors: ["#0D47A1", "#42A5F5"], isJoined: false),
        PrayerGroup(name: "Community Support", description: "Praying together for our community's needs.", memberCount: 312, iconName: "person.3.fill", gradientColors: ["#283593", "#7986CB"], isJoined: true),
        PrayerGroup(name: "Youth Prayer", description: "Young believers praying and growing together.", memberCount: 178, iconName: "sparkles", gradientColors: ["#1565C0", "#64B5F6"], isJoined: false),
        PrayerGroup(name: "Family Blessings", description: "Prayers for families and loved ones.", memberCount: 245, iconName: "house.fill", gradientColors: ["#0277BD", "#4FC3F7"], isJoined: false)
    ]
}

// MARK: - Groups View
struct GroupsView: View {
    @State private var prayerGroups: [PrayerGroup] = PrayerGroup.sampleGroups
    @State private var showingCreateGroupSheet = false
    @State private var newGroupName = ""
    @State private var newGroupDescription = ""
    @State private var searchText = ""

    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var filteredGroups: [PrayerGroup] {
        if searchText.isEmpty { return prayerGroups }
        return prayerGroups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    // My Groups Section
                    if prayerGroups.contains(where: { $0.isJoined }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Groups")
                                .font(.headline)
                                .foregroundColor(AppColors.text)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(prayerGroups.filter { $0.isJoined }) { group in
                                        MyGroupCard(group: group)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }

                    // All Groups Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Discover Groups")
                            .font(.headline)
                            .foregroundColor(AppColors.text)
                            .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredGroups) { group in
                                GroupCard(group: group, joinAction: { toggleJoinStatus(groupId: group.id) })
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Prayer Groups")
            .searchable(text: $searchText, prompt: "Search groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingCreateGroupSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingCreateGroupSheet) {
                CreateGroupSheet(isPresented: $showingCreateGroupSheet, name: $newGroupName, description: $newGroupDescription, onCreate: createNewGroup)
                    .presentationDetents([.medium])
            }
        }
    }

    private func toggleJoinStatus(groupId: UUID) {
        if let index = prayerGroups.firstIndex(where: { $0.id == groupId }) {
            prayerGroups[index].isJoined.toggle()
            prayerGroups[index].memberCount += prayerGroups[index].isJoined ? 1 : -1
        }
    }

    private func createNewGroup() {
        guard !newGroupName.isEmpty else { return }
        let newGroup = PrayerGroup(name: newGroupName, description: newGroupDescription, memberCount: 1, iconName: "hands.sparkles.fill", gradientColors: ["#1E3A8A", "#60A5FA"], isJoined: true)
        prayerGroups.insert(newGroup, at: 0)
        newGroupName = ""; newGroupDescription = ""
    }
}

// MARK: - My Group Card (Horizontal)
struct MyGroupCard: View {
    let group: PrayerGroup

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: group.gradientColors.map { Color(hex: $0) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                Image(systemName: group.iconName)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name).font(.subheadline.bold()).foregroundColor(AppColors.text)
                Text("\(group.memberCount) members").font(.caption).foregroundColor(AppColors.subtext)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Group Card (Grid)
struct GroupCard: View {
    let group: PrayerGroup
    let joinAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: group.gradientColors.map { Color(hex: $0) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 80)
                Image(systemName: group.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }

            Text(group.name).font(.headline).foregroundColor(AppColors.text).lineLimit(1)
            Text(group.description).font(.caption).foregroundColor(AppColors.subtext).lineLimit(2)

            HStack {
                Text("\(group.memberCount) members").font(.caption2).foregroundColor(AppColors.subtext)
                Spacer()
                Button(action: joinAction) {
                    Text(group.isJoined ? "Joined" : "Join")
                        .font(.caption.bold())
                        .foregroundColor(group.isJoined ? AppColors.subtext : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(group.isJoined ? AppColors.border : AppColors.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Create Group Sheet
struct CreateGroupSheet: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var description: String
    let onCreate: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Group Name", text: $name)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(AppColors.text)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(AppColors.text)

                    Spacer()

                    Button(action: { onCreate(); isPresented = false }) {
                        Text("Create Group")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(AppColors.accent)
                }
            }
        }
    }
}

#Preview {
    GroupsView()
}
