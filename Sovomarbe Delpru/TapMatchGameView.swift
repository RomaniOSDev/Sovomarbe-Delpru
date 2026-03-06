//
//  TapMatchGameView.swift
//  Sovomarbe Delpru
//

import SwiftUI
import Combine

struct TapMatchGameView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @Environment(\.dismiss) private var dismiss
    
    let route: LevelRoute
    
    @StateObject private var viewModel: TapMatchViewModel
    @State private var startDate: Date = Date()
    @State private var showResult: Bool = false
    @State private var newlyUnlockedAchievementTitle: String?
    
    init(route: LevelRoute) {
        self.route = route
        _viewModel = StateObject(wrappedValue: TapMatchViewModel(difficulty: route.difficulty, levelIndex: route.levelIndex))
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
                let center = CGPoint(x: size.width * 0.3, y: size.height * 0.12)
                let radius = min(size.width, size.height) * 0.35
                let rect = CGRect(x: center.x - radius,
                                  y: center.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        .init(colors: [Color.appAccent.opacity(0.28), .clear]),
                        center: .init(x: center.x / size.width, y: center.y / size.height),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                header
                grid
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .onAppear {
            startDate = Date()
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            if viewModel.state == .running {
                viewModel.tick()
                if viewModel.state == .finished {
                    handleFinish()
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            LevelResultView(
                activity: route.activity,
                difficulty: route.difficulty,
                levelIndex: route.levelIndex,
                stars: viewModel.finalStars,
                primaryStatText: "Pairs: \(viewModel.pairsFound)",
                secondaryStatText: "Moves: \(viewModel.moves)",
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
        VStack(spacing: 8) {
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
            
            HStack {
                Text("Time")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text("\(viewModel.timeRemaining)s")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appTextSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appSurface)
                    let progress = max(0.0, min(1.0, Double(viewModel.timeRemaining) / 60.0))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appAccent)
                        .frame(width: geo.size.width * progress)
                }
                .frame(height: 8)
            }
            .frame(height: 8)
        }
    }
    
    private var grid: some View {
        let columns = [GridItem(.adaptive(minimum: 64), spacing: 8)]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.cards) { card in
                CardView(card: card)
                    .onTapGesture {
                        viewModel.tapCard(card)
                        if viewModel.state == .finished {
                            handleFinish()
                        }
                    }
            }
        }
        .padding(.top, 16)
    }
    
    private func handleFinish() {
        guard !showResult else { return }
        appStorage.recordActivityPlayed()
        let elapsed = max(0, Int(Date().timeIntervalSince(startDate)))
        appStorage.addPlayTime(seconds: elapsed)
        
        if !route.isPractice {
            let beforeIds = Set(appStorage.achievements().filter { $0.isUnlocked }.map { $0.id })
            appStorage.setStars(viewModel.finalStars, for: route.activity, levelIndex: route.levelIndex)
            let after = appStorage.achievements()
            let newOne = after.first { $0.isUnlocked && !beforeIds.contains($0.id) }
            newlyUnlockedAchievementTitle = newOne?.title
            appStorage.markDailyChallengeCompletedIfNeeded(activity: route.activity, difficulty: route.difficulty, levelIndex: route.levelIndex)
            if viewModel.mistakes == 0 {
                appStorage.recordPerfectTapMatchGame()
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
        // Для упрощения: повторяем уровень заново, следующий выбирается на экране уровней.
        viewModel.reset()
        startDate = Date()
    }
}

private struct CardView: View {
    let card: TapMatchViewModel.Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(card.isFaceUp || card.isMatched ? Color.appSurface : Color.appPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appPrimary, lineWidth: card.isFaceUp ? 2 : 0)
                )
            if card.isFaceUp || card.isMatched {
                Image(systemName: card.symbol)
                    .font(.system(size: 24))
                    .foregroundColor(.appAccent)
            }
        }
        .frame(height: 72)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.18), value: card.isFaceUp)
    }
}

#Preview {
    TapMatchGameView(
        route: LevelRoute(activity: .tapMatch, difficulty: .easy, levelIndex: 0)
    )
    .environmentObject(AppStorageManager.shared)
}

