//
//  AppStorage.swift
//  Sovomarbe Delpru
//

import Foundation
import Combine

enum ActivityId: String, CaseIterable, Identifiable {
    case tapMatch
    case slidePuzzle
    case bounceBalance
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .tapMatch: return "Tap & Match Frenzy"
        case .slidePuzzle: return "Swift Slide Puzzle"
        case .bounceBalance: return "Bounce & Balance"
        }
    }
    
    var subtitle: String {
        switch self {
        case .tapMatch: return "Match pairs before time runs out."
        case .slidePuzzle: return "Slide tiles to restore the pattern."
        case .bounceBalance: return "Keep the ball on moving platforms."
        }
    }
    
    static let levelsPerActivity = 10
}

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var id: String { rawValue }
}

extension Notification.Name {
    static let appStorageDidReset = Notification.Name("appStorageDidReset")
}

final class AppStorageManager: ObservableObject {
    static let shared = AppStorageManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let starsPerLevel = "starsPerLevel"
        static let unlockedLevels = "unlockedLevels"
        static let totalPlayTime = "totalPlayTimeSeconds"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let bestLevelPerActivity = "bestLevelPerActivity"
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let dailyChallengeLastDate = "dailyChallengeLastDate"
        static let dailyChallengeStreak = "dailyChallengeStreak"
        static let totalDailyChallenges = "totalDailyChallenges"
        static let perfectTapMatchGames = "perfectTapMatchGames"
        static let fastSlidePuzzleClears = "fastSlidePuzzleClears"
        static let highBounceScores = "highBounceScores"
    }
    
    @Published var starsPerLevel: [String: [Int]] = [:]
    @Published var unlockedLevels: [String: Int] = [:]
    @Published var totalPlayTimeSeconds: Int = 0
    @Published var totalActivitiesPlayed: Int = 0
    @Published var bestLevelPerActivity: [String: Int] = [:]
    @Published var hasSeenOnboarding: Bool = false
    
    @Published var dailyChallengeLastDateString: String? = nil
    @Published var dailyChallengeStreak: Int = 0
    @Published var totalDailyChallengesCompleted: Int = 0
    
    @Published var perfectTapMatchGames: Int = 0
    @Published var fastSlidePuzzleClears: Int = 0
    @Published var highBounceScores: Int = 0
    
    private init() {
        load()
    }
    
    private func load() {
        if let data = defaults.data(forKey: Keys.starsPerLevel),
           let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            starsPerLevel = decoded
        }
        if let data = defaults.data(forKey: Keys.unlockedLevels),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            unlockedLevels = decoded
        }
        if let data = defaults.data(forKey: Keys.bestLevelPerActivity),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            bestLevelPerActivity = decoded
        }
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTime)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        dailyChallengeLastDateString = defaults.string(forKey: Keys.dailyChallengeLastDate)
        dailyChallengeStreak = defaults.integer(forKey: Keys.dailyChallengeStreak)
        totalDailyChallengesCompleted = defaults.integer(forKey: Keys.totalDailyChallenges)
        perfectTapMatchGames = defaults.integer(forKey: Keys.perfectTapMatchGames)
        fastSlidePuzzleClears = defaults.integer(forKey: Keys.fastSlidePuzzleClears)
        highBounceScores = defaults.integer(forKey: Keys.highBounceScores)
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(starsPerLevel) {
            defaults.set(data, forKey: Keys.starsPerLevel)
        }
        if let data = try? JSONEncoder().encode(unlockedLevels) {
            defaults.set(data, forKey: Keys.unlockedLevels)
        }
        if let data = try? JSONEncoder().encode(bestLevelPerActivity) {
            defaults.set(data, forKey: Keys.bestLevelPerActivity)
        }
        defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTime)
        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
        defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding)
        defaults.set(dailyChallengeLastDateString, forKey: Keys.dailyChallengeLastDate)
        defaults.set(dailyChallengeStreak, forKey: Keys.dailyChallengeStreak)
        defaults.set(totalDailyChallengesCompleted, forKey: Keys.totalDailyChallenges)
        defaults.set(perfectTapMatchGames, forKey: Keys.perfectTapMatchGames)
        defaults.set(fastSlidePuzzleClears, forKey: Keys.fastSlidePuzzleClears)
        defaults.set(highBounceScores, forKey: Keys.highBounceScores)
    }
    
    // MARK: - Public API
    
    func markOnboardingSeen() {
        hasSeenOnboarding = true
        save()
    }
    
    func stars(for activity: ActivityId, levelIndex: Int) -> Int {
        let arr = starsPerLevel[activity.rawValue] ?? []
        guard levelIndex < arr.count else { return 0 }
        return arr[levelIndex]
    }
    
    func setStars(_ stars: Int, for activity: ActivityId, levelIndex: Int) {
        var arr = starsPerLevel[activity.rawValue] ?? []
        while arr.count <= levelIndex {
            arr.append(0)
        }
        let old = arr[levelIndex]
        let newValue = max(old, stars)
        arr[levelIndex] = newValue
        starsPerLevel[activity.rawValue] = arr
        
        if levelIndex > (bestLevelPerActivity[activity.rawValue] ?? -1) {
            bestLevelPerActivity[activity.rawValue] = levelIndex
        }
        unlockNextLevelIfNeeded(activity: activity, completedLevel: levelIndex)
        save()
    }
    
    private func unlockNextLevelIfNeeded(activity: ActivityId, completedLevel: Int) {
        let current = unlockedLevels[activity.rawValue] ?? 0
        if completedLevel >= current && completedLevel + 1 < ActivityId.levelsPerActivity {
            unlockedLevels[activity.rawValue] = completedLevel + 1
        }
    }
    
    func isLevelUnlocked(activity: ActivityId, levelIndex: Int) -> Bool {
        if levelIndex == 0 { return true }
        let maxUnlocked = unlockedLevels[activity.rawValue] ?? 0
        return levelIndex <= maxUnlocked
    }
    
    func recordActivityPlayed() {
        totalActivitiesPlayed += 1
        save()
    }
    
    func addPlayTime(seconds: Int) {
        guard seconds > 0 else { return }
        totalPlayTimeSeconds += seconds
        save()
    }
    
    func resetAll() {
        starsPerLevel = [:]
        unlockedLevels = [:]
        totalPlayTimeSeconds = 0
        totalActivitiesPlayed = 0
        bestLevelPerActivity = [:]
        hasSeenOnboarding = false
        dailyChallengeLastDateString = nil
        dailyChallengeStreak = 0
        totalDailyChallengesCompleted = 0
        perfectTapMatchGames = 0
        fastSlidePuzzleClears = 0
        highBounceScores = 0
        
        defaults.removeObject(forKey: Keys.starsPerLevel)
        defaults.removeObject(forKey: Keys.unlockedLevels)
        defaults.removeObject(forKey: Keys.totalPlayTime)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.bestLevelPerActivity)
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.dailyChallengeLastDate)
        defaults.removeObject(forKey: Keys.dailyChallengeStreak)
        defaults.removeObject(forKey: Keys.totalDailyChallenges)
        defaults.removeObject(forKey: Keys.perfectTapMatchGames)
        defaults.removeObject(forKey: Keys.fastSlidePuzzleClears)
        defaults.removeObject(forKey: Keys.highBounceScores)
        save()
        
        NotificationCenter.default.post(name: .appStorageDidReset, object: nil)
    }
    
    // MARK: - Achievements
    
    struct Achievement: Identifiable {
        let id: String
        let title: String
        let description: String
        let iconName: String
        let progress: Double
        let isUnlocked: Bool
    }
    
    struct DailyChallenge {
        let activity: ActivityId
        let difficulty: Difficulty
        let levelIndex: Int
    }
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    func achievements() -> [Achievement] {
        var result: [Achievement] = []
        
        // 1. Play 10 activities
        let play10Progress = min(1.0, Double(totalActivitiesPlayed) / 10.0)
        result.append(
            Achievement(
                id: "play10",
                title: "Getting Started",
                description: "Play 10 activities.",
                iconName: "gamecontroller.fill",
                progress: play10Progress,
                isUnlocked: play10Progress >= 1.0
            )
        )
        
        // 2. Play 50 activities
        let play50Progress = min(1.0, Double(totalActivitiesPlayed) / 50.0)
        result.append(
            Achievement(
                id: "play50",
                title: "Mini Game Marathon",
                description: "Play 50 activities.",
                iconName: "flame.fill",
                progress: play50Progress,
                isUnlocked: play50Progress >= 1.0
            )
        )
        
        // 3–5. Reach level 5 in each activity
        for activity in ActivityId.allCases {
            let best = bestLevelPerActivity[activity.rawValue] ?? -1
            let reached = best >= 5
            let id = "reach5_\(activity.rawValue)"
            let (title, desc, icon): (String, String, String) = {
                switch activity {
                case .tapMatch:
                    return ("Swift Matcher", "Reach level 6 in Tap & Match Frenzy.", "square.grid.3x3.fill")
                case .slidePuzzle:
                    return ("Puzzle Pro", "Reach level 6 in Swift Slide Puzzle.", "square.grid.3x3.square")
                case .bounceBalance:
                    return ("Balance Master", "Reach level 6 in Bounce & Balance.", "gyroscope")
                }
            }()
            result.append(
                Achievement(
                    id: id,
                    title: title,
                    description: desc,
                    iconName: icon,
                    progress: reached ? 1.0 : 0.0,
                    isUnlocked: reached
                )
            )
        }
        
        // 6. Play for 1 hour
        let hourProgress = min(1.0, Double(totalPlayTimeSeconds) / 3600.0)
        result.append(
            Achievement(
                id: "time1h",
                title: "One Focused Hour",
                description: "Play for 1 hour in total.",
                iconName: "clock.fill",
                progress: hourProgress,
                isUnlocked: hourProgress >= 1.0
            )
        )
        
        // 7. Collect 60 stars overall
        let totalStars = starsPerLevel.values.flatMap { $0 }.reduce(0, +)
        let starsProgress = min(1.0, Double(totalStars) / 60.0)
        result.append(
            Achievement(
                id: "stars60",
                title: "Star Collector",
                description: "Earn 60 stars across all activities.",
                iconName: "star.circle.fill",
                progress: starsProgress,
                isUnlocked: starsProgress >= 1.0
            )
        )
        
        // 8. Finish all levels of any activity with at least 2 stars each
        let allLevelsCompleted: Bool = ActivityId.allCases.contains { activity in
            let arr = starsPerLevel[activity.rawValue] ?? []
            guard arr.count >= ActivityId.levelsPerActivity else { return false }
            return (0..<ActivityId.levelsPerActivity).allSatisfy { idx in
                idx < arr.count && arr[idx] >= 2
            }
        }
        result.append(
            Achievement(
                id: "mastery",
                title: "Mini Game Master",
                description: "Earn at least 2 stars on every level of any activity.",
                iconName: "crown.fill",
                progress: allLevelsCompleted ? 1.0 : 0.0,
                isUnlocked: allLevelsCompleted
            )
        )
        
        // 9. Complete daily challenges
        let daily5Progress = min(1.0, Double(totalDailyChallengesCompleted) / 5.0)
        result.append(
            Achievement(
                id: "daily5",
                title: "Daily Warmup",
                description: "Complete 5 daily challenges.",
                iconName: "sun.max.fill",
                progress: daily5Progress,
                isUnlocked: daily5Progress >= 1.0
            )
        )
        
        // 10. Weekly focus (7-day streak)
        let weeklyProgress = min(1.0, Double(dailyChallengeStreak) / 7.0)
        result.append(
            Achievement(
                id: "weekly7",
                title: "Weekly Focus",
                description: "Maintain a 7-day daily challenge streak.",
                iconName: "calendar",
                progress: weeklyProgress,
                isUnlocked: weeklyProgress >= 1.0
            )
        )
        
        // 11. Perfect Tap & Match runs
        let perfectProgress = min(1.0, Double(perfectTapMatchGames) / 5.0)
        result.append(
            Achievement(
                id: "perfectTap",
                title: "Perfect Matcher",
                description: "Finish 5 Tap & Match games without mistakes.",
                iconName: "checkmark.seal.fill",
                progress: perfectProgress,
                isUnlocked: perfectProgress >= 1.0
            )
        )
        
        // 12. Fast puzzle clears
        let fastPuzzleProgress = min(1.0, Double(fastSlidePuzzleClears) / 5.0)
        result.append(
            Achievement(
                id: "fastPuzzle",
                title: "Fast Solver",
                description: "Complete 5 slide puzzles with a 3-star rating.",
                iconName: "bolt.fill",
                progress: fastPuzzleProgress,
                isUnlocked: fastPuzzleProgress >= 1.0
            )
        )
        
        // 13. High bounce scores
        let highBounceProgress = min(1.0, Double(highBounceScores) / 5.0)
        result.append(
            Achievement(
                id: "highBounce",
                title: "Sky High",
                description: "Reach a high score in Bounce & Balance 5 times.",
                iconName: "arrow.up.circle.fill",
                progress: highBounceProgress,
                isUnlocked: highBounceProgress >= 1.0
            )
        )
        
        return result
    }
    
    // MARK: - Daily challenge helpers
    
    func todayDailyChallenge(for date: Date = Date()) -> DailyChallenge {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let activityIndex = dayOfYear % ActivityId.allCases.count
        let difficultyIndex = dayOfYear % Difficulty.allCases.count
        let levelIndex = (dayOfYear * 3) % ActivityId.levelsPerActivity
        let activity = ActivityId.allCases[activityIndex]
        let difficulty = Difficulty.allCases[difficultyIndex]
        return DailyChallenge(activity: activity, difficulty: difficulty, levelIndex: levelIndex)
    }
    
    var isTodayDailyChallengeCompleted: Bool {
        let todayString = Self.dateFormatter.string(from: Date())
        return dailyChallengeLastDateString == todayString
    }
    
    func markDailyChallengeCompletedIfNeeded(activity: ActivityId, difficulty: Difficulty, levelIndex: Int, date: Date = Date()) {
        let challenge = todayDailyChallenge(for: date)
        guard challenge.activity == activity,
              challenge.difficulty == difficulty,
              challenge.levelIndex == levelIndex else { return }
        
        let todayString = Self.dateFormatter.string(from: date)
        if dailyChallengeLastDateString == todayString {
            return
        }
        
        if let last = dailyChallengeLastDateString,
           let lastDate = Self.dateFormatter.date(from: last) {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                dailyChallengeStreak += 1
            } else {
                dailyChallengeStreak = 1
            }
        } else {
            dailyChallengeStreak = 1
        }
        
        dailyChallengeLastDateString = todayString
        totalDailyChallengesCompleted += 1
        save()
    }
    
    // MARK: - Extra stats recorders
    
    func recordPerfectTapMatchGame() {
        perfectTapMatchGames += 1
        save()
    }
    
    func recordFastSlidePuzzleClear() {
        fastSlidePuzzleClears += 1
        save()
    }
    
    func recordHighBounceScore() {
        highBounceScores += 1
        save()
    }
}

