//
//  FeaturedPrayersAdminView.swift
//  WePray - Prayer Tutoring App
//
//  Admin view for managing featured prayers on landing page carousel

import SwiftUI

struct FeaturedPrayersAdminView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddPrayer = false
    @State private var prayerToEdit: FeaturedPrayer?
    @State private var showDeleteConfirmation = false
    @State private var prayerToDelete: FeaturedPrayer?

    var body: some View {
        List {
            instructionsSection
            activePrayersSection
            inactivePrayersSection
        }
        .navigationTitle("Featured Prayers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddPrayer = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddPrayer) {
            AddEditPrayerView(prayer: nil)
        }
        .sheet(item: $prayerToEdit) { prayer in
            AddEditPrayerView(prayer: prayer)
        }
        .alert("Delete Prayer", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let prayer = prayerToDelete {
                    deletePrayer(prayer)
                }
            }
        } message: {
            Text("Are you sure you want to delete this featured prayer?")
        }
    }

    private var instructionsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("Manage Landing Page Carousel", systemImage: "rectangle.stack")
                    .font(.headline)
                Text("Add, edit, or remove featured prayers that appear on the app landing page. Toggle visibility to show/hide prayers.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var activePrayersSection: some View {
        Section {
            let activePrayers = appState.adminSettings.featuredPrayers.filter { $0.isActive }
            if activePrayers.isEmpty {
                Text("No active prayers")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(activePrayers) { prayer in
                    PrayerRow(
                        prayer: prayer,
                        onEdit: { prayerToEdit = prayer },
                        onToggle: { togglePrayer(prayer) },
                        onDelete: {
                            prayerToDelete = prayer
                            showDeleteConfirmation = true
                        }
                    )
                }
                .onMove(perform: movePrayers)
            }
        } header: {
            HStack {
                Text("Active Prayers")
                Spacer()
                Text("\(appState.adminSettings.featuredPrayers.filter { $0.isActive }.count)")
                    .foregroundColor(.secondary)
            }
        } footer: {
            Text("Drag to reorder. Active prayers appear in the landing page carousel.")
        }
    }

    private var inactivePrayersSection: some View {
        Section {
            let inactivePrayers = appState.adminSettings.featuredPrayers.filter { !$0.isActive }
            if inactivePrayers.isEmpty {
                Text("No inactive prayers")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(inactivePrayers) { prayer in
                    PrayerRow(
                        prayer: prayer,
                        onEdit: { prayerToEdit = prayer },
                        onToggle: { togglePrayer(prayer) },
                        onDelete: {
                            prayerToDelete = prayer
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
        } header: {
            Text("Inactive Prayers")
        } footer: {
            Text("Inactive prayers are hidden from the landing page but can be reactivated.")
        }
    }

    private func togglePrayer(_ prayer: FeaturedPrayer) {
        if let index = appState.adminSettings.featuredPrayers.firstIndex(where: { $0.id == prayer.id }) {
            appState.adminSettings.featuredPrayers[index].isActive.toggle()
            appState.saveAdminSettings()
        }
    }

    private func deletePrayer(_ prayer: FeaturedPrayer) {
        appState.adminSettings.featuredPrayers.removeAll { $0.id == prayer.id }
        appState.saveAdminSettings()
    }

    private func movePrayers(from source: IndexSet, to destination: Int) {
        var activePrayers = appState.adminSettings.featuredPrayers.filter { $0.isActive }
        activePrayers.move(fromOffsets: source, toOffset: destination)

        let inactivePrayers = appState.adminSettings.featuredPrayers.filter { !$0.isActive }
        appState.adminSettings.featuredPrayers = activePrayers + inactivePrayers
        appState.saveAdminSettings()
    }
}

// MARK: - Prayer Row
struct PrayerRow: View {
    let prayer: FeaturedPrayer
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            iconView
            contentView
            Spacer()
            actionButtons
        }
        .padding(.vertical, 4)
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: prayer.gradientColors.map { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)

            Image(systemName: prayer.iconName)
                .foregroundColor(.white)
                .font(.system(size: 18))
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(prayer.title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(prayer.denomination)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: prayer.isActive ? "eye.fill" : "eye.slash")
                    .foregroundColor(prayer.isActive ? AppColors.success : .secondary)
            }

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(AppColors.primary)
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.error)
            }
        }
        .buttonStyle(.borderless)
    }
}

// MARK: - Add/Edit Prayer View
struct AddEditPrayerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let prayer: FeaturedPrayer?

    @State private var title = ""
    @State private var prayerText = ""
    @State private var denomination = ""
    @State private var iconName = "hands.sparkles.fill"
    @State private var color1 = "#6B4EFF"
    @State private var color2 = "#8B73FF"
    @State private var isActive = true

    let iconOptions = ["hands.sparkles.fill", "cross.fill", "star.fill", "heart.fill", "sun.max.fill", "leaf.fill", "book.fill", "flame.fill"]

    var body: some View {
        NavigationView {
            Form {
                Section("Prayer Details") {
                    TextField("Title", text: $title)
                    TextField("Denomination", text: $denomination)
                    TextEditor(text: $prayerText)
                        .frame(minHeight: 100)
                }

                Section("Appearance") {
                    Picker("Icon", selection: $iconName) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Label(icon, systemImage: icon).tag(icon)
                        }
                    }

                    ColorPicker("Primary Color", selection: Binding(
                        get: { Color(hex: color1) },
                        set: { color1 = $0.toHex() ?? "#6B4EFF" }
                    ))

                    ColorPicker("Secondary Color", selection: Binding(
                        get: { Color(hex: color2) },
                        set: { color2 = $0.toHex() ?? "#8B73FF" }
                    ))
                }

                Section {
                    Toggle("Active", isOn: $isActive)
                }
            }
            .navigationTitle(prayer == nil ? "Add Prayer" : "Edit Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { savePrayer() }
                        .disabled(title.isEmpty || prayerText.isEmpty)
                }
            }
            .onAppear { loadPrayer() }
        }
    }

    private func loadPrayer() {
        guard let prayer = prayer else { return }
        title = prayer.title
        prayerText = prayer.prayerText
        denomination = prayer.denomination
        iconName = prayer.iconName
        color1 = prayer.gradientColors.first ?? "#6B4EFF"
        color2 = prayer.gradientColors.last ?? "#8B73FF"
        isActive = prayer.isActive
    }

    private func savePrayer() {
        let newPrayer = FeaturedPrayer(
            id: prayer?.id ?? UUID(),
            title: title,
            prayerText: prayerText,
            denomination: denomination.isEmpty ? "Universal" : denomination,
            iconName: iconName,
            gradientColors: [color1, color2],
            isActive: isActive
        )

        if let existingPrayer = prayer,
           let index = appState.adminSettings.featuredPrayers.firstIndex(where: { $0.id == existingPrayer.id }) {
            appState.adminSettings.featuredPrayers[index] = newPrayer
        } else {
            appState.adminSettings.featuredPrayers.append(newPrayer)
        }

        appState.saveAdminSettings()
        dismiss()
    }
}

// MARK: - Color Extension for Hex
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    NavigationView {
        FeaturedPrayersAdminView()
            .environmentObject(AppState())
    }
}
