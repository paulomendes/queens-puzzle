import Testing
import SnapshotTesting
import QueensCore
@testable import QueensUI

@MainActor
@Suite(.snapshots)
struct CellViewSnapshotTests {
    private static let size: Double = 80
    private let position = Position(row: 0, col: 0)

    @Test func light_empty() {
        assertSnapshot(of: makeCell(dark: false), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func dark_empty() {
        assertSnapshot(of: makeCell(dark: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func light_queen() {
        assertSnapshot(of: makeCell(dark: false, hasQueen: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func dark_queen() {
        assertSnapshot(of: makeCell(dark: true, hasQueen: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func light_queenInConflict() {
        assertSnapshot(of: makeCell(dark: false, hasQueen: true, isInConflict: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func dark_queenInConflict() {
        assertSnapshot(of: makeCell(dark: true, hasQueen: true, isInConflict: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func light_attacked() {
        assertSnapshot(of: makeCell(dark: false, isAttacked: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func dark_attacked() {
        assertSnapshot(of: makeCell(dark: true, isAttacked: true), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    @Test func dark_queen_nonInteractive() {
        assertSnapshot(of: makeCell(dark: true, hasQueen: true, isInteractive: false), as: .image(layout: .fixed(width: Self.size, height: Self.size)))
    }

    private func makeCell(
        dark: Bool,
        hasQueen: Bool = false,
        isInConflict: Bool = false,
        isAttacked: Bool = false,
        isInteractive: Bool = true
    ) -> CellView {
        CellView(
            position: position,
            isDarkSquare: dark,
            hasQueen: hasQueen,
            isInConflict: isInConflict,
            isAttacked: isAttacked,
            isInteractive: isInteractive,
            onTap: {}
        )
    }
}
