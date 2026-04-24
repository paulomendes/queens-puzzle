import Foundation
import Observation
import QueensCore

// The app target has `-default-isolation=MainActor`, so no explicit `@MainActor`
// is needed — every member (including `deinit`) is on the main actor.
@Observable
final class GameStore {
    private(set) var state: GameState
    private(set) var isNewBestTime: Bool = false
    private(set) var isNewBestMoves: Bool = false

    private let clock: Clock
    private let haptics: HapticsService
    private let sound: SoundService
    private let scores: BestScoresRepository

    @ObservationIgnored
    private var timerTask: Task<Void, Never>?

    init(
        size: BoardSize,
        clock: Clock,
        haptics: HapticsService,
        sound: SoundService,
        scores: BestScoresRepository
    ) {
        self.state = GameState(size: size)
        self.clock = clock
        self.haptics = haptics
        self.sound = sound
        self.scores = scores
        startTimer()
    }

    deinit {
        timerTask?.cancel()
    }

    func send(_ action: GameAction) {
        let previous = state
        reduce(&state, action)
        applyEffects(previous: previous, action: action)
    }

    // Convenience callers so the view layer stays ignorant of GameAction.
    func tap(_ position: Position) {
        send(.tap(position))
    }

    func resetBoard() {
        send(.reset)
    }

    func retry() {
        // Full restart: resets the board AND the timer for the same board size.
        send(.newGame(state.size))
        isNewBestTime = false
        isNewBestMoves = false
        startTimer()
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func startTimer() {
        timerTask?.cancel()
        let stream = clock.ticks(interval: 1.0)
        // The task inherits this function's main-actor isolation, so
        // `self.send(.tick)` runs on the main actor without an explicit hop.
        timerTask = Task { [weak self] in
            for await dt in stream {
                guard let self else { return }
                self.send(.tick(dt))
            }
        }
    }

    private func applyEffects(previous: GameState, action: GameAction) {
        switch action {
        case .tap(let position):
            let placed = state.placements.contains(position)
            let removed = previous.placements.contains(position) && !placed
            if placed {
                haptics.play(.placeQueen)
                sound.play(.placeQueen)
            } else if removed {
                haptics.play(.removeQueen)
                sound.play(.removeQueen)
            }
            if !state.conflicts.isEmpty, state.conflicts != previous.conflicts {
                haptics.play(.conflict)
            }
            if previous.status != .won, state.status == .won {
                handleWin()
            }
        case .tick, .reset, .newGame:
            break
        }
    }

    private func handleWin() {
        stopTimer()
        haptics.play(.win)
        sound.play(.win)

        let size = state.size
        let time = state.elapsed
        let moves = state.moveCount

        let previousBestTime = scores.bestTime(for: size)
        let previousBestMoves = scores.bestMoves(for: size)
        isNewBestTime = previousBestTime.map { time < $0 } ?? true
        isNewBestMoves = previousBestMoves.map { moves < $0 } ?? true

        scores.record(time: time, moves: moves, size: size)
    }
}
