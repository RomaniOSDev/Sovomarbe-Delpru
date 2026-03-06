//
//  HomeTabView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    var body: some View {
        ZStack {
            // Futuristic layered background
            LinearGradient(
                colors: [.appBackground, .appSurface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.1)
                let colors: [Color] = [.appPrimary.opacity(0.30), .appAccent.opacity(0.22), .appPrimary.opacity(0.12)]
                for (index, color) in colors.enumerated() {
                    let radius = min(size.width, size.height) * (0.45 - CGFloat(index) * 0.12)
                    let rect = CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    heroCard
                    gamesStrip
                    instructions
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .frame(maxWidth: 390)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mini game control hub")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.appTextSecondary)
            Text("Drop in, solve, bounce out. Fast sessions tuned for focus.")
                .font(.system(size: 15))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var heroCard: some View {
        let totalStars = appStorage.starsPerLevel.values.flatMap { $0 }.reduce(0, +)
        let totalMinutes = appStorage.totalPlayTimeSeconds / 60
        let dailyStreak = appStorage.dailyChallengeStreak
        
        return ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.appPrimary, .appAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
            
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.appSurface.opacity(0.25), lineWidth: 1)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Shape your best run")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text("Pick any mini game, stack stars, and keep your streak alive.")
                    .font(.system(size: 13))
                    .foregroundColor(.appTextPrimary.opacity(0.9))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                
                HStack(spacing: 12) {
                    statChip(icon: "star.fill", label: "Stars", value: "\(totalStars)")
                    statChip(icon: "clock.fill", label: "Playtime", value: "\(totalMinutes)m")
                    statChip(icon: "flame.fill", label: "Streak", value: "\(dailyStreak)d")
                }
            }
            .padding(18)
        }
        .frame(height: 150)
    }
    
    private func statChip(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.appTextPrimary.opacity(0.85))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appTextPrimary)
        }
        .padding(10)
        .background(Color.appSurface.opacity(0.18))
        .cornerRadius(12)
    }
    
    private var gamesStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mini games")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            HStack(spacing: 10) {
                gameChip(title: "Tap & Match", description: "Quick pattern bursts.", icon: "square.grid.3x3.fill")
                gameChip(title: "Slide Puzzle", description: "Clean ordered grids.", icon: "square.grid.4x3.fill")
                gameChip(title: "Bounce & Balance", description: "Reactive timing.", icon: "gyroscope")
            }
        }
    }
    
    private func gameChip(title: String, description: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.appPrimary)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(10)
        .background(Color.appSurface)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
    
    private var instructions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Play styles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            VStack(alignment: .leading, spacing: 12) {
                instructionRow(
                    title: "Tap & Match Frenzy",
                    text: "Tap tiles to reveal icons and match pairs before the timer runs out."
                )
                instructionRow(
                    title: "Swift Slide Puzzle",
                    text: "Slide tiles into the empty space until the grid forms a complete pattern."
                )
                instructionRow(
                    title: "Bounce & Balance",
                    text: "Tap to bounce the ball and keep it landing on moving platforms."
                )
            }
            .padding(16)
            .background(Color.appSurface)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func instructionRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
    }
}

#Preview {
    HomeTabView()
        .environmentObject(AppStorageManager.shared)
}

