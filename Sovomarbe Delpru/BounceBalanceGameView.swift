//
//  BounceBalanceGameView.swift
//  Sovomarbe Delpru
//

import SwiftUI
import Combine

struct BounceBalanceGameView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @Environment(\.dismiss) private var dismiss
    
    let route: LevelRoute
    
    @StateObject private var viewModel: BounceBalanceViewModel
    @State private var startDate: Date = Date()
    @State private var showResult: Bool = false
    @State private var newlyUnlockedAchievementTitle: String?
    
    init(route: LevelRoute) {
        self.route = route
        _viewModel = StateObject(wrappedValue: BounceBalanceViewModel(difficulty: route.difficulty))
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
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
                let radius = min(size.width, size.height) * 0.5
                let rect = CGRect(x: center.x - radius,
                                  y: center.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        .init(colors: [Color.appAccent.opacity(0.25), .clear]),
                        center: .init(x: center.x / size.width, y: center.y / size.height),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                header
                gameArea
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.tapBounce()
        }
        .onAppear {
            startDate = Date()
        }
        .onReceive(Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()) { _ in
            if !viewModel.isGameOver {
                viewModel.update(deltaTime: 1.0 / 60.0)
            } else if !showResult {
                handleFinish()
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            LevelResultView(
                activity: route.activity,
                difficulty: route.difficulty,
                levelIndex: route.levelIndex,
                stars: viewModel.starRating(),
                primaryStatText: "Score: \(viewModel.score)",
                secondaryStatText: "Tap to bounce and stay on platforms.",
                isLastLevel: route.levelIndex >= ActivityId.levelsPerActivity - 1,
                newlyUnlockedAchievementTitle: newlyUnlockedAchievementTitle,
                onNextLevel: {
                    showResult = false
                    startNextLevel()
                },
                onRetry: {
                    showResult = false
                    restart()
                },
                onBackToLevels: {
                    showResult = false
                    dismiss()
                }
            )
            .environmentObject(appStorage)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.activity.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text(route.difficulty.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.appSurface)
                    .cornerRadius(12)
            }
            Text("Tap to push the ball up and keep it landing on moving platforms.")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private var gameArea: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                ForEach(viewModel.platforms) { platform in
                    let platformWidth = CGFloat(platform.width) * width
                    let x = CGFloat(platform.x) * width
                    let y = CGFloat(platform.y) * height
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appPrimary)
                        .frame(width: platformWidth, height: 16)
                        .position(x: x, y: y)
                }
                
                let ballX = CGFloat(viewModel.ballX) * width
                let ballY = CGFloat(viewModel.ballY) * height
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 26, height: 26)
                    .position(x: ballX, y: ballY)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func handleFinish() {
        guard !showResult else { return }
        appStorage.recordActivityPlayed()
        let elapsed = max(0, Int(Date().timeIntervalSince(startDate)))
        appStorage.addPlayTime(seconds: elapsed)
        
        if !route.isPractice {
            let beforeIds = Set(appStorage.achievements().filter { $0.isUnlocked }.map { $0.id })
            let stars = viewModel.starRating()
            appStorage.setStars(stars, for: route.activity, levelIndex: route.levelIndex)
            let after = appStorage.achievements()
            let newOne = after.first { $0.isUnlocked && !beforeIds.contains($0.id) }
            newlyUnlockedAchievementTitle = newOne?.title
            appStorage.markDailyChallengeCompletedIfNeeded(activity: route.activity, difficulty: route.difficulty, levelIndex: route.levelIndex)
            if viewModel.score >= 12 {
                appStorage.recordHighBounceScore()
            }
        } else {
            newlyUnlockedAchievementTitle = nil
        }
        showResult = true
    }
    
    private func restart() {
        viewModel.reset()
        startDate = Date()
    }
    
    private func startNextLevel() {
        // Для упрощения: следующая попытка с теми же параметрами,
        // уровень фактически следующий будет выбран на экране уровней.
        viewModel.reset()
        startDate = Date()
    }
}

#Preview {
    BounceBalanceGameView(
        route: LevelRoute(activity: .bounceBalance, difficulty: .easy, levelIndex: 0)
    )
    .environmentObject(AppStorageManager.shared)
}

