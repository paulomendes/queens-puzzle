import Testing
import SnapshotTesting
@testable import QueensUI

@MainActor
@Suite(.snapshots)
struct WinOverlayViewSnapshotTests {
    private let frame = (width: 393.0, height: 600.0)

    @Test func noBests() {
        let view = WinOverlayView(
            elapsed: 84,
            moveCount: 23,
            isNewBestTime: false,
            isNewBestMoves: false,
            onRetry: {},
            onLeave: {}
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }

    @Test func newBestTime() {
        let view = WinOverlayView(
            elapsed: 42,
            moveCount: 7,
            isNewBestTime: true,
            isNewBestMoves: false,
            onRetry: {},
            onLeave: {}
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }

    @Test func newBestMoves() {
        let view = WinOverlayView(
            elapsed: 84,
            moveCount: 4,
            isNewBestTime: false,
            isNewBestMoves: true,
            onRetry: {},
            onLeave: {}
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }

    @Test func bothBests() {
        let view = WinOverlayView(
            elapsed: 42,
            moveCount: 4,
            isNewBestTime: true,
            isNewBestMoves: true,
            onRetry: {},
            onLeave: {}
        )
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }
}
