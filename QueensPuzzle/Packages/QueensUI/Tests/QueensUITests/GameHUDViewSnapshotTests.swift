import Testing
import SnapshotTesting
@testable import QueensUI

@MainActor
@Suite(.snapshots)
struct GameHUDViewSnapshotTests {
    @Test func horizontal_freshGame() {
        let view = GameHUDView(
            queensRemaining: 8,
            elapsedText: "0:00",
            moveCount: 0,
            axis: .horizontal
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 393, height: 80)))
    }

    @Test func horizontal_midGame() {
        let view = GameHUDView(
            queensRemaining: 5,
            elapsedText: "0:37",
            moveCount: 5,
            axis: .horizontal
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 393, height: 80)))
    }

    @Test func vertical_landscape() {
        let view = GameHUDView(
            queensRemaining: 5,
            elapsedText: "1:23",
            moveCount: 12,
            axis: .vertical
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 200, height: 280)))
    }
}
