import SwiftUI
import QueensCore
import QueensUI

/// Owns a `GameStore` scoped to the lifetime of a single game session, and
/// bridges its observable state into `GameView`.
struct GameScreen: View {
    @State private var store: GameStore
    private let onLeave: () -> Void

    init(
        size: BoardSize,
        scores: BestScoresRepository,
        clock: Clock,
        haptics: HapticsService,
        sound: SoundService,
        onLeave: @escaping () -> Void
    ) {
        self._store = State(initialValue: GameStore(
            size: size,
            clock: clock,
            haptics: haptics,
            sound: sound,
            scores: scores
        ))
        self.onLeave = onLeave
    }

    var body: some View {
        GameView(
            state: store.state,
            isNewBestTime: store.isNewBestTime,
            isNewBestMoves: store.isNewBestMoves,
            onTap: { store.tap($0) },
            onReset: { store.resetBoard() },
            onAbort: {
                store.stopTimer()
                onLeave()
            },
            onRetry: { store.retry() },
            onLeave: onLeave
        )
    }
}
