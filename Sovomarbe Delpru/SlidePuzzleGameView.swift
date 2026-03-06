//
//  SlidePuzzleGameView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct SlidePuzzleGameView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @Environment(\.dismiss) private var dismiss
    
    let route: LevelRoute
    
    @StateObject private var viewModel: SlidePuzzleViewModel
    @State private var startDate: Date = Date()
    @State private var showResult: Bool = false
    @State private var newlyUnlockedAchievementTitle: String?
    
    init(route: LevelRoute) {
        self.route = route
        _viewModel = StateObject(wrappedValue: SlidePuzzleViewModel(difficulty: route.difficulty))
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
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
                let radius = min(size.width, size.height) * 0.45
                let rect = CGRect(x: center.x - radius,
                                  y: center.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        .init(colors: [Color.appPrimary.opacity(0.22), .clear]),
                        center: .init(x: center.x / size.width, y: center.y / size.height),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                puzzleGrid
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .onAppear {
            startDate = Date()
        }
        .onChange(of: viewModel.isSolved) { solved in
            if solved {
                handleFinish()
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            LevelResultView(
                activity: route.activity,
                difficulty: route.difficulty,
                levelIndex: route.levelIndex,
                stars: viewModel.starRating(),
                primaryStatText: "Moves: \(viewModel.moves)",
                secondaryStatText: nil,
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
            
            Text("Slide tiles into the empty space until the pattern is complete.")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private var puzzleGrid: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height - 40)
            let tileSize = size / CGFloat(viewModel.gridSize)
            
            ZStack {
                ForEach(viewModel.tiles) { tile in
                    if !tile.isEmpty {
                        let row = tile.currentIndex / viewModel.gridSize
                        let col = tile.currentIndex % viewModel.gridSize
                        let x = (CGFloat(col) + 0.5) * tileSize
                        let y = (CGFloat(row) + 0.5) * tileSize
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appPrimary)
                            .frame(width: tileSize - 6, height: tileSize - 6)
                            .overlay(
                                Text("\(tile.id)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                            )
                            .position(x: x, y: y)
                            .onTapGesture {
                                viewModel.tapTile(tile)
                            }
                            .animation(.easeInOut(duration: 0.15), value: tile.currentIndex)
                    }
                }
            }
            .frame(width: size, height: size)
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
            if stars == 3 {
                appStorage.recordFastSlidePuzzleClear()
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
        // Упрощённо: перезапуск той же конфигурации, следующий уровень выбирается на экране уровней.
        viewModel.reset()
        startDate = Date()
    }
}

#Preview {
    SlidePuzzleGameView(
        route: LevelRoute(activity: .slidePuzzle, difficulty: .easy, levelIndex: 0)
    )
    .environmentObject(AppStorageManager.shared)
}

