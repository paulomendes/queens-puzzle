import Foundation
import Testing
import QueensCore
@testable import QueensPuzzle

@MainActor
@Suite("GameStore")
struct GameStoreTests {

    // MARK: - Tap effects

    @Test("placing a queen on an empty cell plays place haptic + sound")
    func placingQueenPlaysPlaceEffects() {
        let env = makeEnv()
        let store = makeStore(env: env, size: BoardSize(8)!)

        store.tap(Position(row: 0, col: 0))

        #expect(env.haptics.events == [.placeQueen])
        #expect(env.sound.effects == [.placeQueen])
    }

    @Test("removing a queen plays remove haptic + sound")
    func removingQueenPlaysRemoveEffects() {
        let env = makeEnv()
        let store = makeStore(env: env, size: BoardSize(8)!)
        store.tap(Position(row: 0, col: 0))
        env.reset()

        store.tap(Position(row: 0, col: 0))

        #expect(env.haptics.events == [.removeQueen])
        #expect(env.sound.effects == [.removeQueen])
    }

    @Test("placing a queen that creates a conflict plays place + conflict effects")
    func placingConflictPlaysConflictEffects() {
        let env = makeEnv()
        let store = makeStore(env: env, size: BoardSize(8)!)
        store.tap(Position(row: 0, col: 0))
        env.reset()

        store.tap(Position(row: 0, col: 1))   // same row → conflict

        #expect(env.haptics.events == [.placeQueen, .conflict])
        #expect(env.sound.effects == [.placeQueen, .conflict])
    }

    // MARK: - Win flow

    @Test("completing a valid solution plays win effects and records the score")
    func winningRecordsScoreAndPlaysWinEffects() {
        let env = makeEnv()
        let store = makeStore(env: env, size: BoardSize(4)!)
        for p in Self.solution4.dropLast() { store.tap(p) }
        store.send(.tick(7))
        env.reset()

        store.tap(Self.solution4.last!)

        #expect(store.state.status == .won)
        #expect(env.haptics.events == [.placeQueen, .win])
        #expect(env.sound.effects == [.placeQueen, .win])
        #expect(env.scores.bestTime(for: BoardSize(4)!) == 7)
        #expect(env.scores.bestMoves(for: BoardSize(4)!) == 4)
        #expect(store.isNewBestTime == true)
        #expect(store.isNewBestMoves == true)
    }

    @Test("isNewBestTime / isNewBestMoves are computed against the prior repository values")
    func winningWithSeededRepoSetsNewBestFlagsAccordingly() {
        let scores = InMemoryBestScoresRepository(
            seedTimes: [4: 5.0],
            seedMoves: [4: 8]
        )
        let env = makeEnv(scores: scores)
        let store = makeStore(env: env, size: BoardSize(4)!)
        for p in Self.solution4.dropLast() { store.tap(p) }
        store.send(.tick(10))   // 10s is worse than seeded 5s

        store.tap(Self.solution4.last!)   // 4 moves is better than seeded 8

        #expect(store.isNewBestTime == false)
        #expect(store.isNewBestMoves == true)
        #expect(env.scores.bestTime(for: BoardSize(4)!) == 5.0)
        #expect(env.scores.bestMoves(for: BoardSize(4)!) == 4)
    }

    // MARK: - Reset / retry

    @Test("resetBoard does not fire haptics or sound")
    func resetBoardIsSilent() {
        let env = makeEnv()
        let store = makeStore(env: env, size: BoardSize(8)!)
        store.tap(Position(row: 0, col: 0))
        env.reset()

        store.resetBoard()

        #expect(env.haptics.events.isEmpty)
        #expect(env.sound.effects.isEmpty)
        #expect(store.state.placements.isEmpty)
        #expect(store.state.moveCount == 0)
    }

    @Test("retry resets state and clears the new-best flags")
    func retryClearsStateAndNewBestFlags() {
        let env = makeEnv()
        let store = makeStore(env: env, size: BoardSize(4)!)
        for p in Self.solution4 { store.tap(p) }
        #expect(store.isNewBestTime == true)

        store.retry()

        #expect(store.state.placements.isEmpty)
        #expect(store.state.elapsed == 0)
        #expect(store.state.moveCount == 0)
        #expect(store.state.status == .playing)
        #expect(store.isNewBestTime == false)
        #expect(store.isNewBestMoves == false)
    }

    // MARK: - Timer

    @Test("clock ticks advance elapsed while playing")
    func clockTicksAdvanceElapsed() async {
        let clock = FakeClock()
        let env = makeEnv(clock: clock)
        let store = makeStore(env: env, size: BoardSize(8)!)
        await waitUntil { clock.activeSubscribers == 1 }

        clock.tick(1.0)
        await waitUntil { store.state.elapsed >= 1.0 }

        #expect(store.state.elapsed == 1.0)
    }

    @Test("stopTimer cancels the timer subscription")
    func stopTimerCancelsSubscription() async {
        let clock = FakeClock()
        let env = makeEnv(clock: clock)
        let store = makeStore(env: env, size: BoardSize(8)!)
        await waitUntil { clock.activeSubscribers == 1 }

        store.stopTimer()

        await waitUntil { clock.activeSubscribers == 0 }
        #expect(clock.activeSubscribers == 0)
    }

    // MARK: - Fixtures

    private static let solution4: [Position] = [
        Position(row: 0, col: 1),
        Position(row: 1, col: 3),
        Position(row: 2, col: 0),
        Position(row: 3, col: 2)
    ]
}

// MARK: - Test environment

@MainActor
private struct Env {
    let scores: InMemoryBestScoresRepository
    let clock: Clock
    let haptics: SpyHapticsService
    let sound: SpySoundService

    func reset() {
        haptics.reset()
        sound.reset()
    }
}

@MainActor
private func makeEnv(
    scores: InMemoryBestScoresRepository = InMemoryBestScoresRepository(),
    clock: Clock = StubClock()
) -> Env {
    Env(
        scores: scores,
        clock: clock,
        haptics: SpyHapticsService(),
        sound: SpySoundService()
    )
}

@MainActor
private func makeStore(env: Env, size: BoardSize) -> GameStore {
    GameStore(
        size: size,
        clock: env.clock,
        haptics: env.haptics,
        sound: env.sound,
        scores: env.scores
    )
}

@MainActor
private func waitUntil(timeout: Duration = .seconds(1), _ predicate: () -> Bool) async {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !predicate() {
        if clock.now >= deadline { return }
        await Task.yield()
    }
}

// MARK: - Test doubles

private final class SpyHapticsService: HapticsService, @unchecked Sendable {
    private let lock = NSLock()
    private var _events: [HapticEvent] = []
    var events: [HapticEvent] { lock.withLock { _events } }
    func play(_ event: HapticEvent) { lock.withLock { _events.append(event) } }
    func reset() { lock.withLock { _events.removeAll() } }
}

private final class SpySoundService: SoundService, @unchecked Sendable {
    private let lock = NSLock()
    private var _effects: [SoundEffect] = []
    var effects: [SoundEffect] { lock.withLock { _effects } }
    func play(_ effect: SoundEffect) { lock.withLock { _effects.append(effect) } }
    func reset() { lock.withLock { _effects.removeAll() } }
}

private struct StubClock: Clock {
    func ticks(interval: TimeInterval) -> AsyncStream<TimeInterval> {
        AsyncStream { _ in /* never emits */ }
    }
}

private final class FakeClock: Clock, @unchecked Sendable {
    private let lock = NSLock()
    private var _continuations: [AsyncStream<TimeInterval>.Continuation] = []
    private var _activeCount = 0

    var activeSubscribers: Int { lock.withLock { _activeCount } }

    func ticks(interval: TimeInterval) -> AsyncStream<TimeInterval> {
        AsyncStream { continuation in
            self.lock.withLock {
                self._continuations.append(continuation)
                self._activeCount += 1
            }
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { self?._activeCount -= 1 }
            }
        }
    }

    func tick(_ dt: TimeInterval) {
        let conts = lock.withLock { _continuations }
        for c in conts { c.yield(dt) }
    }
}
