import Testing
import SnapshotTesting
@testable import QueensUI

@MainActor
@Suite struct ScoreRowSnapshotTests {
    @Test func empty() {
        let view = ScoreRow(size: 8, bestTime: "-", bestMoves: "-")
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 360, height: 60)))
    }

    @Test func populated() {
        let view = ScoreRow(size: 8, bestTime: "4:05", bestMoves: "24")
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 360, height: 60)))
    }

    @Test func populated_largeN() {
        let view = ScoreRow(size: 10, bestTime: "12:34", bestMoves: "187")
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 360, height: 60)))
    }
}
