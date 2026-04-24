import Foundation

public protocol BestScoresRepository: Sendable {
    func bestTime(for size: BoardSize) -> TimeInterval?
    func bestMoves(for size: BoardSize) -> Int?
    func record(time: TimeInterval, moves: Int, size: BoardSize)
}
