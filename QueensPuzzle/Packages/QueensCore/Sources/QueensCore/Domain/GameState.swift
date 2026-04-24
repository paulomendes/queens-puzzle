import Foundation

public struct GameState: Equatable, Sendable {
    public var size: BoardSize
    public var placements: Set<Position>
    public var conflicts: Set<Position>
    public var moveCount: Int
    public var elapsed: TimeInterval
    public var status: GameStatus

    public init(
        size: BoardSize,
        placements: Set<Position> = [],
        conflicts: Set<Position> = [],
        moveCount: Int = 0,
        elapsed: TimeInterval = 0,
        status: GameStatus = .playing
    ) {
        self.size = size
        self.placements = placements
        self.conflicts = conflicts
        self.moveCount = moveCount
        self.elapsed = elapsed
        self.status = status
    }

    public var queensRemaining: Int { size.n - placements.count }
}
