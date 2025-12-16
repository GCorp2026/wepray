//
//  FeaturedPrayersCarousel.swift
//  WePray - Prayer Tutoring App
//
//  Carousel component for featured prayers - Mobile optimized

import SwiftUI

struct FeaturedPrayersCarousel: View {
    let prayers: [FeaturedPrayer]
    @Binding var currentIndex: Int
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            carouselContent
            navigationControls
        }
    }

    private var carouselContent: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.85
            let spacing: CGFloat = 16

            HStack(spacing: spacing) {
                ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                    PrayerCard(prayer: prayer, isActive: index == currentIndex)
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
                            if value.predictedEndTranslation.width < -threshold && currentIndex < prayers.count - 1 {
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
        .onAppear { startAutoScroll() }
        .onDisappear { timer?.invalidate() }
    }

    private var navigationControls: some View {
        HStack(spacing: 16) {
            // Left arrow
            Button(action: goToPrevious) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(currentIndex > 0 ? AppColors.primary : AppColors.border)
            }
            .disabled(currentIndex == 0)

            // Tappable indicators
            HStack(spacing: 8) {
                ForEach(0..<prayers.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? AppColors.primary : AppColors.border)
                        .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                        .animation(.spring(response: 0.3), value: currentIndex)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentIndex = index
                                hapticFeedback()
                            }
                        }
                }
            }

            // Right arrow
            Button(action: goToNext) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(currentIndex < prayers.count - 1 ? AppColors.primary : AppColors.border)
            }
            .disabled(currentIndex >= prayers.count - 1)
        }
        .padding(.horizontal, 20)
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentIndex -= 1
            hapticFeedback()
        }
    }

    private func goToNext() {
        guard currentIndex < prayers.count - 1 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentIndex += 1
            hapticFeedback()
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func startAutoScroll() {
        guard prayers.count > 1 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentIndex = (currentIndex + 1) % prayers.count
            }
        }
    }
}

// MARK: - Prayer Card
struct PrayerCard: View {
    let prayer: FeaturedPrayer
    let isActive: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            Divider().background(Color.white.opacity(0.3))
            prayerTextSection
            denominationBadge
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

                Image(systemName: prayer.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(prayer.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(prayer.denomination)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }

    private var prayerTextSection: some View {
        Text(prayer.prayerText)
            .font(.body)
            .foregroundColor(.white.opacity(0.95))
            .lineLimit(4)
            .multilineTextAlignment(.leading)
    }

    private var denominationBadge: some View {
        HStack {
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("Tap to practice")
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.15))
            .cornerRadius(20)
        }
    }

    private var cardBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var gradientColors: [Color] {
        prayer.gradientColors.map { Color(hex: $0) }
    }

    private var shadowColor: Color {
        Color(hex: prayer.gradientColors.first ?? "#6B4EFF").opacity(0.4)
    }
}

// MARK: - Carousel Indicator
struct CarouselIndicator: View {
    let count: Int
    @Binding var currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? AppColors.primary : AppColors.border)
                    .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            currentIndex = index
                        }
                    }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        FeaturedPrayersCarousel(
            prayers: FeaturedPrayer.defaultPrayers,
            currentIndex: .constant(0)
        )
        .frame(height: 280)
        .padding()
    }
}
