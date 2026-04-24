import SwiftUI
import QueensCore

public struct GameView: View {
    @Environment(\.theme) private var theme

    let state: GameState
    let isNewBestTime: Bool
    let isNewBestMoves: Bool
    let onTap: (Position) -> Void
    let onReset: () -> Void
    let onAbort: () -> Void
    let onRetry: () -> Void
    let onLeave: () -> Void

    public init(
        state: GameState,
        isNewBestTime: Bool = false,
        isNewBestMoves: Bool = false,
        onTap: @escaping (Position) -> Void = { _ in },
        onReset: @escaping () -> Void = {},
        onAbort: @escaping () -> Void = {},
        onRetry: @escaping () -> Void = {},
        onLeave: @escaping () -> Void = {}
    ) {
        self.state = state
        self.isNewBestTime = isNewBestTime
        self.isNewBestMoves = isNewBestMoves
        self.onTap = onTap
        self.onReset = onReset
        self.onAbort = onAbort
        self.onRetry = onRetry
        self.onLeave = onLeave
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 24) {
                GameHUDView(
                    queensRemaining: state.queensRemaining,
                    elapsedText: TimeFormatting.minutesSeconds(state.elapsed),
                    moveCount: state.moveCount
                )
                BoardView(
                    size: state.size,
                    placements: state.placements,
                    conflicts: state.conflicts,
                    attackedSquares: Rules.attackedSquares(by: state.placements, size: state.size),
                    isInteractive: state.status == .playing,
                    onTap: onTap
                )
                .padding(.horizontal)
                Spacer(minLength: 0)
                HStack(spacing: 12) {
                    Button("Abort", role: .destructive, action: onAbort)
                        .buttonStyle(SecondaryBarButtonStyle())
                    Button("Reset", action: onReset)
                        .buttonStyle(PrimaryBarButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background.ignoresSafeArea())
            .disabled(state.status == .won)

            if state.status == .won {
                WinOverlayView(
                    elapsed: state.elapsed,
                    moveCount: state.moveCount,
                    isNewBestTime: isNewBestTime,
                    isNewBestMoves: isNewBestMoves,
                    onRetry: onRetry,
                    onLeave: onLeave
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: state.status)
    }
}

#Preview("Fresh 8x8") {
    GameView(state: GameState(size: BoardSize(8)!))
}

#Preview("Mid-game with conflicts") {
    let placements: Set<Position> = [
        Position(row: 0, col: 0),
        Position(row: 1, col: 1),
        Position(row: 3, col: 5)
    ]
    var state = GameState(size: BoardSize(8)!, placements: placements, moveCount: 5, elapsed: 37)
    state.conflicts = Rules.conflicts(in: placements)
    return GameView(state: state)
}

#Preview("Win overlay") {
    let placements: Set<Position> = [
        Position(row: 0, col: 1),
        Position(row: 1, col: 3),
        Position(row: 2, col: 0),
        Position(row: 3, col: 2)
    ]
    var state = GameState(
        size: BoardSize(4)!,
        placements: placements,
        moveCount: 7,
        elapsed: 42,
        status: .won
    )
    state.conflicts = []
    return GameView(state: state, isNewBestTime: true, isNewBestMoves: false)
}
