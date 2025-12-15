//
//  FeaturedArticlesAdminView.swift
//  WePray - Prayer Tutoring App
//
//  Admin view for managing featured articles on landing page carousel

import SwiftUI

struct FeaturedArticlesAdminView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddArticle = false
    @State private var articleToEdit: Article?
    @State private var showDeleteConfirmation = false
    @State private var articleToDelete: Article?

    var body: some View {
        List {
            instructionsSection
            activeArticlesSection
            inactiveArticlesSection
        }
        .navigationTitle("Featured Articles")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddArticle = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddArticle) {
            AddEditArticleView(article: nil)
        }
        .sheet(item: $articleToEdit) { article in
            AddEditArticleView(article: article)
        }
        .alert("Delete Article", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let article = articleToDelete {
                    deleteArticle(article)
                }
            }
        } message: {
            Text("Are you sure you want to delete this featured article?")
        }
    }

    private var instructionsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("Manage Articles Carousel", systemImage: "newspaper.fill")
                    .font(.headline)
                Text("Add, edit, or remove featured articles that appear on the home page. Toggle visibility to show/hide articles.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var activeArticlesSection: some View {
        Section {
            let activeArticles = appState.adminSettings.featuredArticles.filter { $0.isActive }
            if activeArticles.isEmpty {
                Text("No active articles")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(activeArticles) { article in
                    ArticleRow(
                        article: article,
                        onEdit: { articleToEdit = article },
                        onToggle: { toggleArticle(article) },
                        onDelete: {
                            articleToDelete = article
                            showDeleteConfirmation = true
                        }
                    )
                }
                .onMove(perform: moveArticles)
            }
        } header: {
            HStack {
                Text("Active Articles")
                Spacer()
                Text("\(appState.adminSettings.featuredArticles.filter { $0.isActive }.count)")
                    .foregroundColor(.secondary)
            }
        } footer: {
            Text("Drag to reorder. Active articles appear in the home page carousel.")
        }
    }

    private var inactiveArticlesSection: some View {
        Section {
            let inactiveArticles = appState.adminSettings.featuredArticles.filter { !$0.isActive }
            if inactiveArticles.isEmpty {
                Text("No inactive articles")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(inactiveArticles) { article in
                    ArticleRow(
                        article: article,
                        onEdit: { articleToEdit = article },
                        onToggle: { toggleArticle(article) },
                        onDelete: {
                            articleToDelete = article
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
        } header: {
            Text("Inactive Articles")
        } footer: {
            Text("Inactive articles are hidden from the home page but can be reactivated.")
        }
    }

    private func toggleArticle(_ article: Article) {
        if let index = appState.adminSettings.featuredArticles.firstIndex(where: { $0.id == article.id }) {
            appState.adminSettings.featuredArticles[index].isActive.toggle()
            appState.saveAdminSettings()
        }
    }

    private func deleteArticle(_ article: Article) {
        appState.adminSettings.featuredArticles.removeAll { $0.id == article.id }
        appState.saveAdminSettings()
    }

    private func moveArticles(from source: IndexSet, to destination: Int) {
        var activeArticles = appState.adminSettings.featuredArticles.filter { $0.isActive }
        activeArticles.move(fromOffsets: source, toOffset: destination)

        let inactiveArticles = appState.adminSettings.featuredArticles.filter { !$0.isActive }
        appState.adminSettings.featuredArticles = activeArticles + inactiveArticles
        appState.saveAdminSettings()
    }
}

// MARK: - Article Row
struct ArticleRow: View {
    let article: Article
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
                        colors: article.gradientColors.map { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)

            Image(systemName: article.iconName)
                .foregroundColor(.white)
                .font(.system(size: 18))
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.medium)
            if !article.link.isEmpty {
                Text(article.link)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: article.isActive ? "eye.fill" : "eye.slash")
                    .foregroundColor(article.isActive ? AppColors.success : .secondary)
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

// MARK: - Add/Edit Article View
struct AddEditArticleView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let article: Article?

    @State private var title = ""
    @State private var description = ""
    @State private var link = ""
    @State private var iconName = "book.fill"
    @State private var color1 = "#6B4EFF"
    @State private var color2 = "#8B73FF"
    @State private var isActive = true

    let iconOptions = [
        "book.fill", "newspaper.fill", "doc.text.fill", "heart.fill",
        "star.fill", "leaf.fill", "sun.max.fill", "moon.stars.fill",
        "hands.sparkles.fill", "brain.head.profile", "figure.mind.and.body"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section("Article Details") {
                    TextField("Title", text: $title)
                    TextField("Link URL (optional)", text: $link)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                    TextEditor(text: $description)
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

                previewSection
            }
            .navigationTitle(article == nil ? "Add Article" : "Edit Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveArticle() }
                        .disabled(title.isEmpty || description.isEmpty)
                }
            }
            .onAppear { loadArticle() }
        }
    }

    private var previewSection: some View {
        Section("Preview") {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color(hex: color1), Color(hex: color2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 100)
                HStack {
                    Image(systemName: iconName).font(.title).foregroundColor(.white)
                    VStack(alignment: .leading) {
                        Text(title.isEmpty ? "Article Title" : title).font(.headline).foregroundColor(.white)
                        Text(description.isEmpty ? "Description" : description).font(.caption).foregroundColor(.white.opacity(0.8)).lineLimit(2)
                    }
                    Spacer()
                }.padding()
            }
        }
    }

    private func loadArticle() {
        guard let article = article else { return }
        title = article.title; description = article.description; link = article.link
        iconName = article.iconName; isActive = article.isActive
        color1 = article.gradientColors.first ?? "#6B4EFF"; color2 = article.gradientColors.last ?? "#8B73FF"
    }

    private func saveArticle() {
        let newArticle = Article(id: article?.id ?? UUID(), title: title, description: description, iconName: iconName, gradientColors: [color1, color2], link: link, isActive: isActive, order: article?.order ?? (appState.adminSettings.featuredArticles.count + 1))
        if let existingArticle = article, let index = appState.adminSettings.featuredArticles.firstIndex(where: { $0.id == existingArticle.id }) {
            appState.adminSettings.featuredArticles[index] = newArticle
        } else { appState.adminSettings.featuredArticles.append(newArticle) }
        appState.saveAdminSettings(); dismiss()
    }
}

#Preview {
    NavigationView {
        FeaturedArticlesAdminView()
            .environmentObject(AppState())
    }
}
