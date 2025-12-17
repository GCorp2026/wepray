import SwiftUI

struct AddPrayerRequestView: View {
    let circleId: UUID
    @ObservedObject var viewModel: PrayerCircleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var isUrgent = false
    @State private var authorName = "Anonymous"

    private var canSubmit: Bool {
        !content.isEmpty && content.count >= 10
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        infoCard
                        contentSection
                        urgentSection
                        tipsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") { submitRequest() }
                        .foregroundColor(canSubmit ? AppColors.accent : AppColors.subtext)
                        .disabled(!canSubmit)
                }
            }
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "hands.sparkles.fill")
                .font(.title2)
                .foregroundColor(AppColors.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text("Share Your Prayer Need")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Text("Your circle members will pray with you")
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prayer Request")
                .font(.headline)
                .foregroundColor(AppColors.text)

            TextEditor(text: $content)
                .frame(minHeight: 150)
                .padding(12)
                .background(AppColors.border.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(AppColors.text)
                .scrollContentBackground(.hidden)

            HStack {
                Text("\(content.count) characters")
                    .font(.caption)
                    .foregroundColor(content.count >= 10 ? AppColors.subtext : .red)
                Spacer()
                if content.count < 10 {
                    Text("Minimum 10 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Urgent Section

    private var urgentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Mark as Urgent")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    Text("Urgent requests are highlighted for immediate attention")
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }

                Spacer()

                Toggle("", isOn: $isUrgent)
                    .tint(.orange)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUrgent ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips for Prayer Requests")
                .font(.headline)
                .foregroundColor(AppColors.text)

            VStack(alignment: .leading, spacing: 8) {
                TipRow(icon: "checkmark.circle", text: "Be specific about what you need prayer for")
                TipRow(icon: "checkmark.circle", text: "Share how others can follow up")
                TipRow(icon: "checkmark.circle", text: "Update your request when prayers are answered")
                TipRow(icon: "heart", text: "Remember to pray for others in the circle too")
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Actions

    private func submitRequest() {
        let initials = authorName.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0).uppercased() }
            .joined()

        let request = CirclePrayerRequest(
            authorName: authorName,
            authorInitials: initials.isEmpty ? "AN" : initials,
            content: content,
            submittedAt: Date(),
            status: .active,
            prayerCount: 0,
            hasPrayed: false,
            isUrgent: isUrgent,
            responses: []
        )
        viewModel.addPrayerRequest(to: circleId, request: request)
        dismiss()
    }
}

// MARK: - Supporting Views

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppColors.accent)
            Text(text)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
    }
}

#Preview {
    AddPrayerRequestView(circleId: UUID(), viewModel: PrayerCircleViewModel())
}
