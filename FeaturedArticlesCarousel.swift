import SwiftUI

struct FeaturedArticlesCarousel: View {
    let articles: [Article]
    @Binding var currentIndex: Int
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    @Environment(\.colorScheme) var colorScheme

    init(articles: [Article], currentIndex: Binding<Int>) {
        self.articles = articles
        self._currentIndex = currentIndex
    }

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width * 0.85
                let spacing: CGFloat = 16

                HStack(spacing: spacing) {
                    ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                        ArticleCard(article: article, isActive: index == currentIndex)
                            .frame(width: cardWidth)
                            .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                            .opacity(index == currentIndex ? 1.0 : 0.6)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                    }
                }
                .padding(.horizontal, (geometry.size.width - cardWidth) / 2)
                .offset(x: -CGFloat(currentIndex) * (cardWidth + spacing) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if value.predictedEndTranslation.width < -threshold && currentIndex < articles.count - 1 {
                                    currentIndex += 1
                                    hapticFeedback()
                                } else if value.predictedEndTranslation.width > threshold && currentIndex > 0 {
                                    currentIndex -= 1
                                    hapticFeedback()
                                }
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(height: 220)

            // Carousel indicators - tappable
            HStack(spacing: 8) {
                ForEach(0..<articles.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? AppColors.primary : AppColors.border)
                        .frame(width: index == currentIndex ? 10 : 6, height: index == currentIndex ? 10 : 6)
                        .animation(.spring(response: 0.3), value: currentIndex)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentIndex = index
                                hapticFeedback()
                            }
                        }
                }
            }
            .padding(.top, 8)

            // Navigation arrows for mobile
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentIndex = max(0, currentIndex - 1)
                        hapticFeedback()
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentIndex > 0 ? AppColors.primary : AppColors.border)
                }
                .disabled(currentIndex == 0)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentIndex = min(articles.count - 1, currentIndex + 1)
                        hapticFeedback()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentIndex < articles.count - 1 ? AppColors.primary : AppColors.border)
                }
                .disabled(currentIndex == articles.count - 1)
            }
            .padding(.horizontal, 30)
        }
        .onAppear { startAutoScroll() }
        .onDisappear { timer?.invalidate() }
    }

    private func startAutoScroll() {
        guard articles.count > 1 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentIndex = (currentIndex + 1) % articles.count
            }
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct ArticleCard: View {
    let article: Article
    let isActive: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            Divider().background(Color.white.opacity(0.3))
            descriptionSection
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(20)
        .shadow(color: shadowColor, radius: isActive ? 20 : 10, x: 0, y: 10)
    }

    private var headerSection: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: article.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()
        }
    }

    private var descriptionSection: some View {
        Text(article.description)
            .font(.body)
            .foregroundColor(.white.opacity(0.95))
            .lineLimit(4)
            .multilineTextAlignment(.leading)
    }

    private var cardBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var gradientColors: [Color] {
        article.gradientColors.map { Color(hex: $0) }
    }

    private var shadowColor: Color {
        Color(hex: article.gradientColors.first ?? "#6B4EFF").opacity(0.4)
    }
}

// Article model is defined in SharedTypes.swift

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        FeaturedArticlesCarousel(articles: Article.defaultArticles, currentIndex: .constant(0))
            .padding()
    }
}
