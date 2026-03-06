//
//  SlidePuzzleViewModel.swift
//  Sovomarbe Delpru
//

import Foundation
import Combine

final class SlidePuzzleViewModel: ObservableObject {
    struct Tile: Identifiable, Equatable {
        let id: Int      // 0..(count-1), last is empty
        var currentIndex: Int
        
        var isEmpty: Bool { id == 0 }
    }
    
    @Published private(set) var tiles: [Tile] = []
    @Published private(set) var gridSize: Int
    @Published private(set) var moves: Int = 0
    @Published private(set) var isSolved: Bool = false
    
    init(difficulty: Difficulty) {
        switch difficulty {
        case .easy: gridSize = 3
        case .normal: gridSize = 4
        case .hard: gridSize = 5
        }
        setup()
    }
    
    private func setup() {
        let count = gridSize * gridSize
        tiles = (0..<count).map { idx in
            Tile(id: idx, currentIndex: idx)
        }
        shuffle()
        moves = 0
        isSolved = false
    }
    
    func reset() {
        setup()
    }
    
    private func shuffle() {
        // start from solved, then perform legal random moves so puzzle stays solvable
        let totalMoves = gridSize * gridSize * 10
        for _ in 0..<totalMoves {
            let emptyIndex = tiles.first(where: { $0.isEmpty })!.currentIndex
            let neighbors = neighborIndices(of: emptyIndex)
            guard let random = neighbors.randomElement(),
                  let tileIdx = tiles.firstIndex(where: { $0.currentIndex == random }) else { continue }
            swapTile(atDisplayIndex: tileIdx)
        }
        if checkSolved() {
            // if randomly stayed solved, shuffle again lightly
            shuffle()
        }
    }
    
    private func neighborIndices(of index: Int) -> [Int] {
        let row = index / gridSize
        let col = index % gridSize
        var result: [Int] = []
        if row > 0 { result.append((row - 1) * gridSize + col) }
        if row < gridSize - 1 { result.append((row + 1) * gridSize + col) }
        if col > 0 { result.append(row * gridSize + (col - 1)) }
        if col < gridSize - 1 { result.append(row * gridSize + (col + 1)) }
        return result
    }
    
    func tapTile(_ tile: Tile) {
        guard !isSolved, !tile.isEmpty else { return }
        guard let idx = tiles.firstIndex(where: { $0.id == tile.id }) else { return }
        let emptyIndex = tiles.first(where: { $0.isEmpty })!.currentIndex
        let neighbors = neighborIndices(of: emptyIndex)
        guard neighbors.contains(tiles[idx].currentIndex) else { return }
        swapTile(atDisplayIndex: idx)
        moves += 1
        isSolved = checkSolved()
    }
    
    private func swapTile(atDisplayIndex idx: Int) {
        guard let emptyIdx = tiles.firstIndex(where: { $0.isEmpty }) else { return }
        let emptyDisplayIndex = tiles[emptyIdx].currentIndex
        let tileDisplayIndex = tiles[idx].currentIndex
        tiles[idx].currentIndex = emptyDisplayIndex
        tiles[emptyIdx].currentIndex = tileDisplayIndex
    }
    
    private func checkSolved() -> Bool {
        for tile in tiles {
            if tile.currentIndex != tile.id { return false }
        }
        return true
    }
    
    func starRating() -> Int {
        let optimal = gridSize * gridSize * 2
        if moves <= optimal { return 3 }
        if moves <= optimal * 2 { return 2 }
        return 1
    }
}

