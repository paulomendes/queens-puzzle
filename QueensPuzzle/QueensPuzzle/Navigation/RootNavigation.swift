import QueensCore
import QueensUI
import SwiftUI

struct RootNavigation: View {
    @State private var path: [AppDestination] = []
    @State private var scores: ScoresStore
    private let clock: Clock
    private let haptics: HapticsService
    private let sound: SoundService

    init(
        scores: BestScoresRepository = UserDefaultsBestScoreRepository(userDefaults: .standard),
        clock: Clock = SystemClock(),
        haptics: HapticsService = SystemHapticsService(),
        sound: SoundService = SystemSoundService()
    ) {
        self._scores = State(initialValue: ScoresStore(repository: scores))
        self.clock = clock
        self.haptics = haptics
        self.sound = sound
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                bestTime: { scores.bestTime(for: $0) },
                bestMoves: { scores.bestMoves(for: $0) },
                onStartGame: { path.append(.game($0)) }
            )
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .game(let size):
                    GameScreen(
                        size: size,
                        scores: scores,
                        clock: clock,
                        haptics: haptics,
                        sound: sound,
                        onLeave: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
    }
}
