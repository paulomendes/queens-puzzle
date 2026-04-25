import SwiftUI
import QueensCore

public struct GameView: View {
    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass

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

    private var isPad: Bool {
        hSizeClass == .regular && vSizeClass == .regular
    }

    private var isCompactHeight: Bool {
        vSizeClass == .compact
    }

    public var body: some View {
        ZStack {
            Group {
                if isPad {
                    iPadLayout
                } else if isCompactHeight {
                    iPhoneLandscapeLayout
                } else {
                    portraitLayout
                }
            }
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

    private var iPadLayout: some View {
        GeometryReader { geo in
            portraitLayout
                .frame(maxWidth: min(geo.size.width, geo.size.height))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var portraitLayout: some View {
        VStack(spacing: 24) {
            hud(axis: .horizontal)
            board
                .padding(.horizontal)
            Spacer(minLength: 0)
            actionButtons
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }

    private var iPhoneLandscapeLayout: some View {
        HStack(alignment: .center, spacing: 16) {
            board
                .frame(maxHeight: .infinity)

            VStack(spacing: 12) {
                hud(axis: .vertical)
                Spacer(minLength: 0)
                actionButtons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(16)
    }

    private var board: some View {
        BoardView(
            size: state.size,
            placements: state.placements,
            conflicts: state.conflicts,
            attackedSquares: state.attackedSquares,
            isInteractive: state.status == .playing,
            onTap: onTap
        )
    }

    private func hud(axis: Axis) -> some View {
        GameHUDView(
            queensRemaining: state.queensRemaining,
            elapsedText: TimeFormatting.minutesSeconds(state.elapsed),
            moveCount: state.moveCount,
            axis: axis
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(role: .destructive, action: onAbort) {
                Text(.gameButtonAbort)
            }
            .buttonStyle(SecondaryBarButtonStyle())
            Button(action: onReset) {
                Text(.gameButtonReset)
            }
            .buttonStyle(PrimaryBarButtonStyle())
        }
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
    state.attackedSquares = Rules.attackedSquares(by: placements, size: state.size)
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
