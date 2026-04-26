import Foundation

enum LaunchArguments {
    /// When present, the app boots with an in-memory `BestScoresRepository`
    /// so UI tests start from a clean slate every run.
    static let inMemoryScores = "-uitesting-in-memory-scores"

    static var hasInMemoryScores: Bool {
        ProcessInfo.processInfo.arguments.contains(inMemoryScores)
    }
}
