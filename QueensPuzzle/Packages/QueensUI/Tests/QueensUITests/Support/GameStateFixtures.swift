import Foundation
import QueensCore

enum GameStateFixtures {
    static func fresh(n: Int) -> GameState {
        GameState(size: BoardSize(n)!)
    }

    static func midGameWithConflicts() -> GameState {
        let size = BoardSize(8)!
        let placements: Set<Position> = [
            Position(row: 0, col: 0),
            Position(row: 1, col: 1),
            Position(row: 3, col: 5)
        ]
        return GameState(
            size: size,
            placements: placements,
            conflicts: Rules.conflicts(in: placements),
            attackedSquares: Rules.attackedSquares(by: placements, size: size),
            moveCount: 5,
            elapsed: 37
        )
    }

    static func won4x4(elapsed: TimeInterval = 42, moveCount: Int = 7) -> GameState {
        let placements: Set<Position> = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 0),
            Position(row: 3, col: 2)
        ]
        return GameState(
            size: BoardSize(4)!,
            placements: placements,
            conflicts: [],
            attackedSquares: [],
            moveCount: moveCount,
            elapsed: elapsed,
            status: .won
        )
    }

    static let seededBestTimes: [Int: TimeInterval] = [4: 60, 5: 170, 8: 245]
    static let seededBestMoves: [Int: Int] = [4: 6, 5: 11, 8: 24]
}
