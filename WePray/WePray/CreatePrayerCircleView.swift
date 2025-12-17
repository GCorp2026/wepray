import SwiftUI

struct CreatePrayerCircleView: View {
    @ObservedObject var viewModel: PrayerCircleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory: CircleCategory = .faith
    @State private var isPrivate = false
    @State private var selectedIcon = "hands.sparkles.fill"

    private let icons = [
        "hands.sparkles.fill", "heart.circle.fill", "cross.circle.fill",
        "person.3.fill", "book.circle.fill", "sun.max.fill",
        "moon.stars.fill", "star.circle.fill", "leaf.circle.fill"
    ]

    private var canCreate: Bool {
        !name.isEmpty && !description.isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        iconSelector
                        nameSection
                        descriptionSection
                        categorySection
                        privacySection
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { createCircle() }
                        .foregroundColor(canCreate ? AppColors.accent : AppColors.subtext)
                        .disabled(!canCreate)
                }
            }
        }
    }

    // MARK: - Icon Selector

    private var iconSelector: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(selectedCategory.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                Image(systemName: selectedIcon)
                    .font(.largeTitle)
                    .foregroundColor(selectedCategory.color)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(selectedIcon == icon ? .white : AppColors.subtext)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? selectedCategory.color : AppColors.cardBackground)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Circle Name")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextField("e.g., Moms Praying for Kids", text: $name)
                .padding()
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextEditor(text: $description)
                .frame(minHeight: 100)
                .padding(8)
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
                .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .foregroundColor(AppColors.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CircleCategory.allCases, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .font(.subheadline)
                            .foregroundColor(selectedCategory == category ? .white : category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? category.color : category.color.opacity(0.15))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy")
                .font(.headline)
                .foregroundColor(AppColors.text)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isPrivate ? "Private Circle" : "Public Circle")
                        .font(.subheadline)
                        .foregroundColor(AppColors.text)
                    Text(isPrivate ? "Only invited members can join" : "Anyone can discover and join")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                Toggle("", isOn: $isPrivate)
                    .tint(AppColors.accent)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }

    // MARK: - Actions

    private func createCircle() {
        let newCircle = PrayerCircle(
            name: name,
            description: description,
            category: selectedCategory,
            memberCount: 1,
            iconName: selectedIcon,
            gradientColors: [selectedCategory.color.toHex(), AppColors.primary.toHex()],
            isJoined: true,
            isPrivate: isPrivate,
            createdBy: "You",
            createdAt: Date(),
            nextMeeting: nil,
            prayerRequests: [],
            members: [
                CircleMember(name: "You", initials: "Y", role: .leader, joinedAt: Date(), prayerCount: 0)
            ]
        )
        viewModel.createCircle(newCircle)
        dismiss()
    }
}

// MARK: - Color Extension

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

#Preview {
    CreatePrayerCircleView(viewModel: PrayerCircleViewModel())
}
