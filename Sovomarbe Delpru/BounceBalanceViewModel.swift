//
//  BounceBalanceViewModel.swift
//  Sovomarbe Delpru
//

import Foundation
import Combine

final class BounceBalanceViewModel: ObservableObject {
    struct Platform: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var width: Double
        var velocity: Double
    }
    
    @Published private(set) var platforms: [Platform] = []
    @Published private(set) var ballX: Double = 0.5
    @Published private(set) var ballY: Double = 0.2
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var score: Int = 0
    
    private var vx: Double = 0.0
    private var vy: Double = 0.0
    private let gravity: Double
    private let speedScale: Double
    
    init(difficulty: Difficulty) {
        switch difficulty {
        case .easy:
            gravity = 0.0025
            speedScale = 0.4
        case .normal:
            gravity = 0.0032
            speedScale = 0.7
        case .hard:
            gravity = 0.0038
            speedScale = 1.0
        }
        resetPlatforms()
    }
    
    private func resetPlatforms() {
        platforms = []
        let baseWidths: [Double]
        switch speedScale {
        case ..<0.5:
            baseWidths = [0.3, 0.3, 0.28, 0.26]
        case ..<0.8:
            baseWidths = [0.26, 0.24, 0.22, 0.20]
        default:
            baseWidths = [0.22, 0.20, 0.18, 0.16]
        }
        for i in 0..<4 {
            let y = 0.4 + Double(i) * 0.12
            let width = baseWidths[min(i, baseWidths.count - 1)]
            let dir: Double = i % 2 == 0 ? 1 : -1
            let vx = dir * speedScale * (0.0015 + Double(i) * 0.0004)
            platforms.append(
                Platform(
                    x: 0.5,
                    y: y,
                    width: width,
                    velocity: vx
                )
            )
        }
        ballX = 0.5
        ballY = 0.2
        vx = 0.0
        vy = 0.0
        isGameOver = false
        score = 0
    }
    
    func update(deltaTime: Double) {
        guard !isGameOver else { return }
        
        // update platforms
        for i in platforms.indices {
            platforms[i].x += platforms[i].velocity * deltaTime * 60.0
            if platforms[i].x < platforms[i].width / 2 {
                platforms[i].x = platforms[i].width / 2
                platforms[i].velocity *= -1
            }
            if platforms[i].x > 1.0 - platforms[i].width / 2 {
                platforms[i].x = 1.0 - platforms[i].width / 2
                platforms[i].velocity *= -1
            }
        }
        
        // update ball physics
        vy += gravity * deltaTime * 60.0
        ballY += vy * deltaTime * 60.0
        
        // horizontal drift very light
        ballX += vx * deltaTime * 60.0
        ballX = min(0.98, max(0.02, ballX))
        
        // collision with platforms
        for platform in platforms {
            // consider platform as horizontal segment at y with width
            let halfWidth = platform.width / 2
            if ballY > platform.y - 0.02 && ballY < platform.y + 0.005 &&
                ballX > platform.x - halfWidth && ballX < platform.x + halfWidth &&
                vy > 0 {
                ballY = platform.y - 0.02
                vy = -abs(vy) * 0.75
                score += 1
            }
        }
        
        if ballY > 1.1 {
            isGameOver = true
        }
    }
    
    func tapBounce() {
        guard !isGameOver else { return }
        vy = -0.06
    }
    
    func reset() {
        resetPlatforms()
    }
    
    func starRating() -> Int {
        if score >= 18 { return 3 }
        if score >= 10 { return 2 }
        return 1
    }
}

