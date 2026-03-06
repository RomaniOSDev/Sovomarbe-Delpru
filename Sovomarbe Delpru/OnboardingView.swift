//
//  OnboardingView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.appBackground, .appSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Canvas { context, size in
                let colors: [Color] = [.appPrimary.opacity(0.14), .appAccent.opacity(0.10)]
                for (idx, color) in colors.enumerated() {
                    let radius = min(size.width, size.height) * (0.5 - CGFloat(idx) * 0.18)
                    let center = CGPoint(x: size.width * 0.2 + CGFloat(idx) * size.width * 0.4,
                                         y: size.height * (idx == 0 ? 0.1 : 0.85))
                    let rect = CGRect(x: center.x - radius,
                                      y: center.y - radius,
                                      width: radius * 2,
                                      height: radius * 2)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .radialGradient(
                            .init(colors: [color, .clear]),
                            center: .init(x: center.x / size.width, y: center.y / size.height),
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        illustration: GravityIllustration(),
                        title: "Quick mini challenges",
                        subtitle: "Play focused mini games designed for short bursts of fun."
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        illustration: PuzzleIllustration(),
                        title: "Three unique ways to play",
                        subtitle: "Tap & Match, Slide Puzzles, and bouncing balance challenges."
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        illustration: StarsIllustration(),
                        title: "Chase stars and milestones",
                        subtitle: "Earn stars, unlock achievements, and track your progress."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 20) {
                    PageDots(current: currentPage, total: 3)
                        .padding(.top, 12)
                    
                    Button(action: advance) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.appPrimary)
                            .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .background(
                    Color.appSurface
                        .opacity(0.96)
                        .overlay(
                            LinearGradient(
                                colors: [.appPrimary.opacity(0.15), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blendMode(.softLight)
                        )
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
    
    private func advance() {
        if currentPage < 2 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            appStorage.markOnboardingSeen()
        }
    }
}

private struct OnboardingPage<Illustration: View>: View {
    let illustration: Illustration
    let title: String
    let subtitle: String
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                illustration
                    .frame(height: 240)
                    .scaleEffect(appeared ? 1.0 : 0.8)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7),
                        value: appeared
                    )
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.appTextSecondary)
                        .padding(.horizontal, 24)
                    Text(subtitle)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.appTextSecondary)
                        .padding(.horizontal, 24)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
        }
        .onAppear {
            appeared = true
        }
    }
}

private struct PageDots: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.appPrimary : Color.appTextSecondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == current ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: current)
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// Simple SwiftUI-only illustrations

private struct GravityIllustration: View {
    @State private var offset: CGFloat = -40
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appAccent.opacity(0.35), lineWidth: 4)
                .frame(width: 180, height: 180)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appSurface)
                .frame(width: 140, height: 14)
                .offset(y: 60)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            Circle()
                .fill(Color.appPrimary)
                .frame(width: 26, height: 26)
                .offset(y: offset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        offset = 20
                    }
                }
        }
    }
}

private struct PuzzleIllustration: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let tileSize = size / 3.2
            let colors: [Color] = [.appPrimary, .appAccent, .appSurface]
            
            ZStack {
                ForEach(0..<3, id: \.self) { row in
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colors[index % colors.count].opacity(index == 8 ? 0.0 : 1.0))
                            .frame(width: tileSize, height: tileSize)
                            .offset(
                                x: (CGFloat(col) - 1) * (tileSize + 6),
                                y: (CGFloat(row) - 1) * (tileSize + 6)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct StarsIllustration: View {
    @State private var activeIndex: Int = 0
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(index <= activeIndex ? .appAccent : .appTextSecondary.opacity(0.4))
                    .scaleEffect(index <= activeIndex ? 1.1 : 0.9)
                    .shadow(color: index <= activeIndex ? Color.appAccent.opacity(0.7) : .clear, radius: 10)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                activeIndex = (activeIndex + 1) % 3
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppStorageManager.shared)
}

