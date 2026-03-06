//
//  AchievementsTabView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct AchievementsTabView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @State private var showResetAlert: Bool = false
    
    private var achievements: [AppStorageManager.Achievement] {
        appStorage.achievements()
    }
    
    private var totalStars: Int {
        appStorage.starsPerLevel.values.flatMap { $0 }.reduce(0, +)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.appBackground, .appSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Canvas { context, size in
                let radius = min(size.width, size.height) * 0.5
                let center = CGPoint(x: size.width * 0.2, y: size.height * 0.1)
                let rect = CGRect(x: center.x - radius,
                                  y: center.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        .init(colors: [Color.appPrimary.opacity(0.25), .clear]),
                        center: .init(x: center.x / size.width, y: center.y / size.height),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statsCard
                    achievementsGrid
                    resetSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .frame(maxWidth: 390)
                .frame(maxWidth: .infinity)
            }
        }
        .alert("Reset All Progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appStorage.resetAll()
            }
        } message: {
            Text("This will clear all stars, levels, statistics, and achievements. This action cannot be undone.")
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Achievements")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appTextSecondary)
            Text("Track your milestones and overall progress across all mini games.")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            statRow(label: "Total activities played", value: "\(appStorage.totalActivitiesPlayed)")
            statRow(label: "Total stars earned", value: "\(totalStars)")
            statRow(label: "Total time played", value: formattedTime(appStorage.totalPlayTimeSeconds))
            statRow(label: "Daily streak", value: "\(appStorage.dailyChallengeStreak)d")
            statRow(label: "Perfect Tap & Match games", value: "\(appStorage.perfectTapMatchGames)")
            statRow(label: "Fast slide puzzle clears", value: "\(appStorage.fastSlidePuzzleClears)")
            statRow(label: "High bounce scores", value: "\(appStorage.highBounceScores)")
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var achievementsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementCell(achievement: achievement)
                }
            }
        }
    }
    
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            Button {
                showResetAlert = true
            } label: {
                Text("Reset All Progress")
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
        .padding(.top, 12)
    }
}

private struct AchievementCell: View {
    let achievement: AppStorageManager.Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.appPrimary.opacity(0.18) : Color.appSurface)
                    .frame(width: 52, height: 52)
                Image(systemName: achievement.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(achievement.isUnlocked ? .appPrimary : .appTextSecondary)
                    .saturation(achievement.isUnlocked ? 1.0 : 0.0)
            }
            
            Text(achievement.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.system(size: 11))
                .foregroundColor(.appTextSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            
            ProgressView(value: achievement.progress)
                .progressViewStyle(.linear)
                .tint(.appAccent)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .opacity(achievement.isUnlocked ? 1.0 : 0.85)
    }
}

#Preview {
    AchievementsTabView()
        .environmentObject(AppStorageManager.shared)
}

