//
//  ActivitiesTabView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct ActivitiesTabView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @State private var path: [LevelRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(
                    colors: [.appBackground, .appSurface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Canvas { context, size in
                    let center = CGPoint(x: size.width * 0.8, y: size.height * 0.05)
                    let radius = min(size.width, size.height) * 0.45
                    let rect = CGRect(x: center.x - radius,
                                      y: center.y - radius,
                                      width: radius * 2,
                                      height: radius * 2)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .radialGradient(
                            .init(colors: [Color.appAccent.opacity(0.22), .clear]),
                            center: .init(x: center.x / size.width, y: center.y / size.height),
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        DailyChallengeCard()
                        header
                        ForEach(ActivityId.allCases) { activity in
                            ActivityCardView(activity: activity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .frame(maxWidth: 390)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationDestination(for: LevelRoute.self) { route in
                switch route.activity {
                case .tapMatch:
                    TapMatchGameView(route: route)
                case .slidePuzzle:
                    SlidePuzzleGameView(route: route)
                case .bounceBalance:
                    BounceBalanceGameView(route: route)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose your activity")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appTextSecondary)
            Text("Pick a difficulty and level to start a focused mini challenge.")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
        .padding(.bottom, 4)
    }
}

private struct DailyChallengeCard: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    var body: some View {
        let challenge = appStorage.todayDailyChallenge()
        let completed = appStorage.isTodayDailyChallengeCompleted
        
        NavigationLink(
            value: LevelRoute(activity: challenge.activity, difficulty: challenge.difficulty, levelIndex: challenge.levelIndex)
        ) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Challenge")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    Text("\(challenge.activity.title) • \(challenge.difficulty.rawValue) • Level \(challenge.levelIndex + 1)")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                Text(completed ? "Done" : "Play")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(completed ? .appTextSecondary : .appTextPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(completed ? Color.appSurface : Color.appPrimary)
                    .cornerRadius(12)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct LevelRoute: Hashable {
    let activity: ActivityId
    let difficulty: Difficulty
    let levelIndex: Int
    let isPractice: Bool
    
    init(activity: ActivityId, difficulty: Difficulty, levelIndex: Int, isPractice: Bool = false) {
        self.activity = activity
        self.difficulty = difficulty
        self.levelIndex = levelIndex
        self.isPractice = isPractice
    }
}

private struct ActivityCardView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    let activity: ActivityId
    @State private var selectedDifficulty: Difficulty = .easy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    Text(activity.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
            }
            
            difficultySelector
            
            levelGrid
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var difficultySelector: some View {
        HStack(spacing: 8) {
            ForEach(Difficulty.allCases) { difficulty in
                Button {
                    selectedDifficulty = difficulty
                } label: {
                    HStack(spacing: 6) {
                        ForEach(0..<dots(for: difficulty), id: \.self) { _ in
                            Circle()
                                .fill(difficulty == selectedDifficulty ? Color.appTextPrimary : Color.appTextSecondary.opacity(0.3))
                                .frame(width: 5, height: 5)
                        }
                        Text(difficulty.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(difficulty == selectedDifficulty ? .appTextPrimary : .appTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(difficulty == selectedDifficulty ? Color.appPrimary : Color.appSurface)
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    private func dots(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy: return 1
        case .normal: return 2
        case .hard: return 3
        }
    }
    
    private var levelGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 8)], spacing: 8) {
                ForEach(0..<ActivityId.levelsPerActivity, id: \.self) { index in
                    LevelCell(activity: activity, difficulty: selectedDifficulty, levelIndex: index)
                }
            }
            NavigationLink(
                value: LevelRoute(activity: activity, difficulty: selectedDifficulty, levelIndex: 0, isPractice: true)
            ) {
                Text("Practice mode")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appPrimary.opacity(0.7), lineWidth: 1)
                    )
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

private struct LevelCell: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    let activity: ActivityId
    let difficulty: Difficulty
    let levelIndex: Int
    
    var isUnlocked: Bool {
        appStorage.isLevelUnlocked(activity: activity, levelIndex: levelIndex)
    }
    
    var stars: Int {
        appStorage.stars(for: activity, levelIndex: levelIndex)
    }
    
    var body: some View {
        NavigationLink(value: LevelRoute(activity: activity, difficulty: difficulty, levelIndex: levelIndex)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? Color.appSurface : Color.appSurface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isUnlocked ? Color.appPrimary.opacity(0.5) : Color.appTextSecondary.opacity(0.3), lineWidth: 1)
                    )
                VStack(spacing: 4) {
                    if isUnlocked {
                        Text("\(levelIndex + 1)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { idx in
                                Image(systemName: idx < stars ? "star.fill" : "star")
                                    .font(.system(size: 9))
                                    .foregroundColor(.appAccent)
                            }
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .frame(minWidth: 64, minHeight: 64)
            }
        }
        .disabled(!isUnlocked)
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ActivitiesTabView()
        .environmentObject(AppStorageManager.shared)
}

