//
//  TweetComposeView.swift
//  WePray - Compose New Tweet
//

import SwiftUI

struct TweetComposeView: View {
    @Binding var isPresented: Bool
    let onPost: (String) -> Void
    @State private var tweetContent: String = ""
    @FocusState private var isFocused: Bool

    private let maxCharacters = 280

    var remainingCharacters: Int {
        maxCharacters - tweetContent.count
    }

    var isValid: Bool {
        !tweetContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        remainingCharacters >= 0
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Text Editor
                    ZStack(alignment: .topLeading) {
                        if tweetContent.isEmpty {
                            Text("Share a prayer, thought, or encouragement...")
                                .foregroundColor(AppColors.subtext.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }

                        TextEditor(text: $tweetContent)
                            .focused($isFocused)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .onChange(of: tweetContent) { _, newValue in
                                if newValue.count > maxCharacters {
                                    tweetContent = String(newValue.prefix(maxCharacters))
                                }
                            }
                    }
                    .frame(height: 150)
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // Character Counter
                    HStack {
                        Spacer()
                        Text("\(remainingCharacters)")
                            .font(.caption.bold())
                            .foregroundColor(
                                remainingCharacters < 0 ? .red :
                                remainingCharacters < 20 ? .orange :
                                AppColors.subtext
                            )
                        Text("/ \(maxCharacters)")
                            .font(.caption)
                            .foregroundColor(AppColors.subtext)
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    HStack(spacing: 16) {
                        Button {
                            tweetContent = ""
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }

                        Button {
                            onPost(tweetContent.trimmingCharacters(in: .whitespacesAndNewlines))
                            tweetContent = ""
                            isPresented = false
                        } label: {
                            Text("Post")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    isValid
                                        ? LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.gray, Color.gray], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                        }
                        .disabled(!isValid)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Tweet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.text)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    TweetComposeView(isPresented: .constant(true)) { content in
        print("Posted: \(content)")
    }
}
