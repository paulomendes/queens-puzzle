import Foundation

/// Mirrors the app target's `LaunchArguments`. The two definitions live in
/// separate targets and must keep their raw string values in sync.
enum LaunchArguments {
    static let inMemoryScores = "-uitesting-in-memory-scores"
}
