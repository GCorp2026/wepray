//
//  PrayerRequestDetailView.swift
//  WePray - Prayer Request Detail & Responses
//

import SwiftUI

struct PrayerRequestDetailView: View {
    @ObservedObject var viewModel: PrayerRequestViewModel
    let request: PrayerRequest
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @State private var newResponse = ""
    @State private var showingTestimony = false
    @State private var testimonyText = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Request Header
                        requestHeader

                        // Request Content
                        requestContent

                        // Testimony (if answered)
                        if request.isAnswered, let testimony = request.testimonyText {
                            testimonySection(testimony)
                        }

                        // Prayer Action
                        prayerAction

                        // Responses Section
                        responsesSection

                        // Add Response
                        addResponseSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Prayer Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingTestimony) {
                TestimonySheet(testimonyText: $testimonyText) {
                    viewModel.markAsAnswered(request, testimony: testimonyText)
                    dismiss()
                }
            }
        }
    }

    // MARK: - Request Header
    private var requestHeader: some View {
        HStack {
            Circle()
                .fill(request.category.color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: request.category.icon).foregroundColor(request.category.color))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(request.displayName)
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    if !request.isAnonymous {
                        RoleBadgeView(role: request.authorRole, size: .small)
                    }
                }
                HStack(spacing: 8) {
                    Text(request.category.rawValue)
                        .font(.caption)
                        .foregroundColor(request.category.color)
                    Text("•")
                        .foregroundColor(AppColors.subtext)
                    Text(request.formattedDate)
                        .font(.caption)
                        .foregroundColor(AppColors.subtext)
                }
            }

            Spacer()

            if request.isAnswered {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                VStack(spacing: 2) {
                    Image(systemName: request.urgency.icon)
                    Text(request.urgency.rawValue)
                        .font(.caption2)
                }
                .foregroundColor(request.urgency.color)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Request Content
    private var requestContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(request.title)
                .font(.title3.bold())
                .foregroundColor(AppColors.text)

            Text(request.description)
                .font(.body)
                .foregroundColor(AppColors.text)
                .lineSpacing(4)

            HStack(spacing: 16) {
                Label("\(request.prayerCount) prayers", systemImage: "hands.sparkles")
                Label("\(request.commentCount) responses", systemImage: "bubble.left")
            }
            .font(.caption)
            .foregroundColor(AppColors.subtext)

            if request.authorId == appState.currentUser?.id.uuidString && !request.isAnswered {
                Button { showingTestimony = true } label: {
                    Label("Mark as Answered", systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Testimony Section
    private func testimonySection(_ testimony: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Testimony", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(.green)

            Text(testimony)
                .font(.body)
                .foregroundColor(AppColors.text)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - Prayer Action
    private var prayerAction: some View {
        Button {
            viewModel.prayForRequest(request)
        } label: {
            HStack {
                Image(systemName: viewModel.hasPrayedFor(request) ? "checkmark.circle.fill" : "hands.sparkles.fill")
                Text(viewModel.hasPrayedFor(request) ? "You Prayed for This" : "I Prayed for This")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.hasPrayedFor(request) ? Color.green : AppColors.accent)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.hasPrayedFor(request))
    }

    // MARK: - Responses Section
    private var responsesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Responses")
                .font(.headline)
                .foregroundColor(AppColors.text)

            let responses = viewModel.getResponses(for: request)
            if responses.isEmpty {
                Text("Be the first to offer encouragement")
                    .font(.subheadline)
                    .foregroundColor(AppColors.subtext)
                    .padding()
            } else {
                ForEach(responses) { response in
                    ResponseCard(response: response)
                }
            }
        }
    }

    // MARK: - Add Response Section
    private var addResponseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Send Encouragement")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.text)

            HStack {
                TextField("Write a message...", text: $newResponse)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button {
                    guard !newResponse.isEmpty else { return }
                    viewModel.addResponse(
                        to: request,
                        message: newResponse,
                        authorId: appState.currentUser?.id.uuidString ?? "guest",
                        authorName: appState.currentUser?.displayName ?? "Guest",
                        authorRole: appState.currentUser?.role ?? .user
                    )
                    newResponse = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .padding(10)
                        .background(AppColors.accent)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(newResponse.isEmpty)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}
