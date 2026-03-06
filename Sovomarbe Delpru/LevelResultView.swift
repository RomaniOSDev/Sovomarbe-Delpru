//
//  LevelResultView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct LevelResultView: View {
    let activity: ActivityId
    let difficulty: Difficulty
    let levelIndex: Int
    let stars: Int
    let primaryStatText: String
    let secondaryStatText: String?
    let isLastLevel: Bool
    let newlyUnlockedAchievementTitle: String?
    
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void
    
    @State private var starVisible: [Bool] = [false, false, false]
    @State private var showBanner: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.appBackground, .appSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.25)
                let radius = min(size.width, size.height) * 0.45
                let rect = CGRect(x: center.x - radius,
                                  y: center.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        .init(colors: [Color.appAccent.opacity(0.35), .clear]),
                        center: .init(x: center.x / size.width, y: center.y / size.height),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                
                Text("Level complete")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appTextSecondary)
                
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(index < stars ? .appAccent : .appTextSecondary.opacity(0.4))
                            .shadow(color: index < stars ? Color.appAccent.opacity(0.7) : .clear, radius: 10)
                            .scaleEffect(starVisible[index] ? 1.0 : 0.2)
                            .opacity(starVisible[index] ? 1.0 : 0.0)
                    }
                }
                .padding(.vertical, 8)
                
                VStack(spacing: 4) {
                    Text(primaryStatText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    if let secondary = secondaryStatText {
                        Text(secondary)
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                if let title = newlyUnlockedAchievementTitle, showBanner {
                    Text("Achievement unlocked: \(title)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.appPrimary)
                        .cornerRadius(14)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    if !isLastLevel {
                        Button(action: onNextLevel) {
                            Text("Next Level")
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
                    }
                    
                    Button(action: onRetry) {
                        Text("Retry")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.appPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.appSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.appPrimary, lineWidth: 2)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: onBackToLevels) {
                        Text("Back to Levels")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            for index in 0..<min(3, stars) {
                let delay = Double(index) * 0.15
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        starVisible[index] = true
                    }
                }
            }
            if newlyUnlockedAchievementTitle != nil {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBanner = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showBanner = false
                    }
                }
            }
        }
    }
}

#Preview {
    LevelResultView(
        activity: .tapMatch,
        difficulty: .easy,
        levelIndex: 0,
        stars: 3,
        primaryStatText: "Time: 18s",
        secondaryStatText: "Moves: 12 taps",
        isLastLevel: false,
        newlyUnlockedAchievementTitle: "Getting Started",
        onNextLevel: {},
        onRetry: {},
        onBackToLevels: {}
    )
    .environmentObject(AppStorageManager.shared)
}

