//
//  DevotionalDetailView.swift
//  WePray - Daily Devotional Detail View
//

import SwiftUI

struct DevotionalDetailView: View {
    @ObservedObject var viewModel: DevotionalViewModel
    let devotional: DailyDevotional
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String = ""
    @State private var showingNotes = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection

                        // Scripture Card
                        scriptureCard

                        // Reflection Section
                        sectionCard(title: "Reflection", icon: "text.quote", content: devotional.reflection)

                        // Prayer Section
                        sectionCard(title: "Prayer", icon: "hands.sparkles", content: devotional.prayer)

                        // Application Section
                        sectionCard(title: "Apply Today", icon: "checkmark.circle", content: devotional.application)

                        // Notes Section
                        notesSection

                        // Action Buttons
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.subtext)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button { viewModel.toggleFavorite(devotional) } label: {
                            Image(systemName: devotional.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(devotional.isFavorite ? .red : AppColors.subtext)
                        }
                        shareButton
                    }
                }
            }
            .onAppear {
                notes = devotional.notes
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(devotional.category.rawValue, systemImage: devotional.category.icon)
                    .font(.caption)
                    .foregroundColor(devotional.category.color)
                Spacer()
                Text(devotional.formattedDate)
                    .font(.caption)
                    .foregroundColor(AppColors.subtext)
            }

            Text(devotional.title)
                .font(.title.bold())
                .foregroundColor(AppColors.text)

            Text("By \(devotional.author)")
                .font(.subheadline)
                .foregroundColor(AppColors.subtext)
        }
    }

    // MARK: - Scripture Card
    private var scriptureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(devotional.category.color)
                Text(devotional.scripture.reference)
                    .font(.headline)
                    .foregroundColor(devotional.category.color)
            }

            Text(devotional.scripture.text)
                .font(.body)
                .italic()
                .foregroundColor(AppColors.text)
                .lineSpacing(6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [devotional.category.color.opacity(0.15), AppColors.cardBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - Section Card
    private func sectionCard(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.accent)
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }

            Text(content)
                .font(.body)
                .foregroundColor(AppColors.text)
                .lineSpacing(6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(AppColors.accent)
                Text("My Notes")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Button { showingNotes.toggle() } label: {
                    Image(systemName: showingNotes ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.subtext)
                }
            }

            if showingNotes {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(AppColors.background)
                    .cornerRadius(8)
                    .onChange(of: notes) { _, newValue in
                        viewModel.updateNotes(devotional, notes: newValue)
                    }
            } else if !devotional.notes.isEmpty {
                Text(devotional.notes)
                    .font(.body)
                    .foregroundColor(AppColors.subtext)
                    .lineLimit(3)
            } else {
                Text("Tap to add your reflections...")
                    .font(.body)
                    .foregroundColor(AppColors.subtext)
                    .italic()
                    .onTapGesture { showingNotes = true }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            if !devotional.isRead {
                Button {
                    viewModel.markAsRead(devotional)
                } label: {
                    Label("Mark as Read", systemImage: "checkmark.circle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .cornerRadius(12)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Share Button
    private var shareButton: some View {
        ShareLink(
            item: shareText,
            subject: Text(devotional.title),
            message: Text("Daily Devotional from WePray")
        ) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(AppColors.subtext)
        }
    }

    private var shareText: String {
        """
        \(devotional.title)

        \(devotional.scripture.reference)
        "\(devotional.scripture.text)"

        \(devotional.reflection)

        Prayer: \(devotional.prayer)

        - Shared from WePray
        """
    }
}
