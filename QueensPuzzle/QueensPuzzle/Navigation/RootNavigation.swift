import SwiftUI
import QueensCore
import QueensUI

struct RootNavigation: View {
    @State private var path = NavigationPath()
    @State private var scoresVersion: Int = 0
    private let scores: BestScoresRepository
    private let clock: Clock
    private let haptics: HapticsService
    private let sound: SoundService

    init(
        scores: BestScoresRepository = UserDefaultsBestScoreRepository(userDefaults: .standard),
        clock: Clock = SystemClock(),
        haptics: HapticsService = SystemHapticsService(),
        sound: SoundService = NoOpSoundService()
    ) {
        self.scores = scores
        self.clock = clock
        self.haptics = haptics
        self.sound = sound
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                bestTime: { scores.bestTime(for: $0) },
                bestMoves: { scores.bestMoves(for: $0) },
                onStartGame: { path.append($0) }
            )
            .id(scoresVersion)
            .navigationDestination(for: BoardSize.self) { size in
                GameScreen(
                    size: size,
                    scores: scores,
                    clock: clock,
                    haptics: haptics,
                    sound: sound,
                    onLeave: {
                        scoresVersion &+= 1
                        path.removeLast()
                    }
                )
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

/// Owns a `GameStore` scoped to the lifetime of a single game session, and
/// bridges its observable state into `GameView`.
private struct GameScreen: View {
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
