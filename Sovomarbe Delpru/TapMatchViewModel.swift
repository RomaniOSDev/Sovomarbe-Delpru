//
//  TapMatchViewModel.swift
//  Sovomarbe Delpru
//

import Foundation
import Combine

final class TapMatchViewModel: ObservableObject {
    struct Card: Identifiable {
        let id: UUID
        let symbol: String
        var isFaceUp: Bool
        var isMatched: Bool
    }
    
    enum GameState {
        case idle
        case running
        case finished
    }
    
    @Published private(set) var cards: [Card] = []
    @Published private(set) var timeRemaining: Int
    @Published private(set) var pairsFound: Int = 0
    @Published private(set) var moves: Int = 0
    @Published private(set) var mistakes: Int = 0
    @Published private(set) var state: GameState = .idle
    @Published private(set) var finalStars: Int = 1
    
    private let difficulty: Difficulty
    private let levelIndex: Int
    
    private var totalPairs: Int
    private var timerTick: (() -> Void)?
    private var firstSelectedIndex: Int?
    
    init(difficulty: Difficulty, levelIndex: Int) {
        self.difficulty = difficulty
        self.levelIndex = levelIndex
        self.timeRemaining = 0
        self.totalPairs = 0
        configure()
    }
    
    private func configure() {
        let basePairs: Int
        let baseTime: Int
        switch difficulty {
        case .easy:
            basePairs = 4
            baseTime = 40
        case .normal:
            basePairs = 6
            baseTime = 35
        case .hard:
            basePairs = 8
            baseTime = 30
        }
        let extra = min(4, levelIndex / 2)
        totalPairs = basePairs + extra
        timeRemaining = baseTime + max(0, 8 - levelIndex * 2)
        pairsFound = 0
        moves = 0
        mistakes = 0
        firstSelectedIndex = nil
        state = .idle
        setupCards()
    }
    
    private func setupCards() {
        let symbolsPool = ["circle.fill", "triangle.fill", "square.fill", "diamond.fill", "star.fill", "heart.fill", "hexagon.fill", "seal.fill", "capsule.fill", "cloud.fill"]
        let selected = Array(symbolsPool.shuffled().prefix(totalPairs))
        var temp: [Card] = []
        for symbol in selected {
            temp.append(Card(id: UUID(), symbol: symbol, isFaceUp: false, isMatched: false))
            temp.append(Card(id: UUID(), symbol: symbol, isFaceUp: false, isMatched: false))
        }
        cards = temp.shuffled()
        state = .running
    }
    
    func reset() {
        configure()
    }
    
    func attachTimer(tick: @escaping () -> Void) {
        timerTick = tick
    }
    
    func tick() {
        guard state == .running else { return }
        guard timeRemaining > 0 else {
            timeRemaining = 0
            finishGame()
            return
        }
        timeRemaining -= 1
    }
    
    func tapCard(_ card: Card) {
        guard state == .running else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[index].isFaceUp, !cards[index].isMatched else { return }
        
        cards[index].isFaceUp = true
        moves += 1
        
        if let firstIndex = firstSelectedIndex {
            if firstIndex == index {
                return
            }
            if cards[firstIndex].symbol == cards[index].symbol {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                pairsFound += 1
                firstSelectedIndex = nil
                if pairsFound == totalPairs {
                    finishGame()
                }
            } else {
                mistakes += 1
                let first = firstIndex
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                    guard let self = self else { return }
                    if self.state != .running { return }
                    if first < self.cards.count {
                        self.cards[first].isFaceUp = false
                    }
                    if let currentIndex = self.cards.firstIndex(where: { $0.id == card.id }),
                       currentIndex < self.cards.count {
                        self.cards[currentIndex].isFaceUp = false
                    }
                }
                firstSelectedIndex = nil
            }
        } else {
            firstSelectedIndex = index
        }
    }
    
    private func finishGame() {
        guard state == .running else { return }
        state = .finished
        let completionRatio = Double(pairsFound) / Double(totalPairs)
        var score: Int = 1
        if completionRatio >= 1.0 && timeRemaining > 0 {
            if mistakes <= totalPairs / 2 && timeRemaining > 5 {
                score = 3
            } else {
                score = 2
            }
        } else if completionRatio >= 0.6 {
            score = 2
        }
        finalStars = max(1, min(3, score))
    }
}

