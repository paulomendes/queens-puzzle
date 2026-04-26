import QueensCore
@testable import QueensUI
import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots)
struct BoardViewSnapshotTests {
    private static let frame = (width: 360.0, height: 360.0)

    @Test func empty4x4() {
        let view = BoardView(size: BoardSize(4)!)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: Self.frame.width, height: Self.frame.height)))
    }

    @Test func empty8x8() {
        let view = BoardView(size: BoardSize(8)!)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: Self.frame.width, height: Self.frame.height)))
    }

    @Test func empty10x10() {
        let view = BoardView(size: BoardSize(10)!)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: Self.frame.width, height: Self.frame.height)))
    }

    @Test func placementsConflictsAttacked_8x8() {
        let placements: Set<Position> = [
            Position(row: 0, col: 0),
            Position(row: 1, col: 1),
            Position(row: 3, col: 5)
        ]
        let size = BoardSize(8)!
        let view = BoardView(
            size: size,
            placements: placements,
            conflicts: Rules.conflicts(in: placements),
            attackedSquares: Rules.attackedSquares(by: placements, size: size)
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: Self.frame.width, height: Self.frame.height)))
    }

    @Test func solved4x4_nonInteractive() {
        let placements: Set<Position> = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 0),
            Position(row: 3, col: 2)
        ]
        let view = BoardView(
            size: BoardSize(4)!,
            placements: placements,
            isInteractive: false
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: Self.frame.width, height: Self.frame.height)))
    }
}
