import SwiftUI

struct BenefitsSection: View {
    let benefits: [Benefit] = [
        Benefit(title: "Prayer Guidance", description: "Personalized guidance to deepen your prayer life.", iconName: "hands.sparkles.fill", gradientColors: ["#6B4EFF", "#8B73FF"]),
        Benefit(title: "Community", description: "Connect with a supportive community of fellow believers.", iconName: "person.3.fill", gradientColors: ["#00C9A7", "#00B894"]),
        Benefit(title: "Daily Reminders", description: "Stay consistent with prayer through daily reminders.", iconName: "bell.fill", gradientColors: ["#FFB800", "#FFD700"]),
        Benefit(title: "Spiritual Growth", description: "Experience spiritual growth through regular prayer and reflection.", iconName: "leaf.fill", gradientColors: ["#9B59B6", "#8E44AD"])
    ]

    @State private var cardVisibility: [Bool] = [false, false, false, false]
    @State private var tappedIndex: Int? = nil
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            // Cinematic Title with Gradient
            VStack(spacing: 8) {
                Text("Unlock the Benefits")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [.white, AppColors.primaryLight]
                                : [AppColors.text, AppColors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 5, x: 0, y: 3)

                Text("of WePray")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }

            // Horizontal scrolling cards for mobile
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(benefits.indices, id: \.self) { index in
                        BenefitCard(
                            benefit: benefits[index],
                            isVisible: cardVisibility[index],
                            isTapped: tappedIndex == index
                        )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    cardVisibility[index] = true
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                tappedIndex = index
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation { tappedIndex = nil }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical)
        .onAppear {
            cardVisibility = Array(repeating: false, count: benefits.count)
        }
    }
}

struct BenefitCard: View {
    let benefit: Benefit
    let isVisible: Bool
    let isTapped: Bool
    @Environment(\.colorScheme) var colorScheme

    var gradientColors: [Color] {
        benefit.gradientColors.map { Color(hex: $0) }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .blur(radius: 10)

                Image(systemName: benefit.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.5), radius: 5)
            }

            Text(benefit.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(benefit.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(16)
        .frame(width: 160, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: gradientColors.first?.opacity(0.4) ?? .clear, radius: isTapped ? 15 : 8, x: 0, y: 5)
        .scaleEffect(isTapped ? 1.05 : 1.0)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
    }
}

struct Benefit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let gradientColors: [String]
}

#Preview {
    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        BenefitsSection()
    }
}
