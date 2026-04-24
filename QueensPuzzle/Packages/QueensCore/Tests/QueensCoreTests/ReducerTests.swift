import Testing
@testable import QueensCore

@Suite("Reducer")
struct ReducerTests {

    // MARK: .tap

    @Test("tap on an empty cell places a queen and increments moves")
    func tapPlacesQueen() {
        var state = GameState(size: BoardSize(8)!)
        reduce(&state, .tap(Position(row: 2, col: 3)))

        #expect(state.placements == [Position(row: 2, col: 3)])
        #expect(state.moveCount == 1)
        #expect(state.conflicts.isEmpty)
        #expect(state.status == .playing)
    }

    @Test("tap on an occupied cell removes the queen and still counts as a move")
    func tapRemovesQueen() {
        let pos = Position(row: 1, col: 1)
        var state = GameState(
            size: BoardSize(8)!,
            placements: [pos],
            moveCount: 1
        )
        reduce(&state, .tap(pos))

        #expect(state.placements.isEmpty)
        #expect(state.moveCount == 2)
    }

    @Test("tap recomputes the conflicts cache")
    func tapRecomputesConflicts() {
        var state = GameState(
            size: BoardSize(8)!,
            placements: [Position(row: 0, col: 0)]
        )
        reduce(&state, .tap(Position(row: 3, col: 3)))

        #expect(state.conflicts == [
            Position(row: 0, col: 0),
            Position(row: 3, col: 3)
        ])
    }

    @Test("tap that completes a valid solution transitions to .won")
    func tapCompletingSolutionWins() {
        let solution: [Position] = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 0),
            Position(row: 3, col: 2)
        ]
        var state = GameState(
            size: BoardSize(4)!,
            placements: Set(solution.dropLast())
        )
        reduce(&state, .tap(solution.last!))

        #expect(state.status == .won)
        #expect(state.placements.count == 4)
        #expect(state.conflicts.isEmpty)
    }

    @Test("tap on a won board is a no-op")
    func tapOnWonBoardIsNoOp() {
        var state = GameState(
            size: BoardSize(4)!,
            placements: [Position(row: 0, col: 0)],
            conflicts: [],
            moveCount: 7,
            elapsed: 12.0,
            status: .won
        )
        let before = state
        reduce(&state, .tap(Position(row: 1, col: 2)))
        #expect(state == before)
    }

    // MARK: .tick

    @Test("tick advances elapsed while playing")
    func tickAdvancesElapsedWhilePlaying() {
        var state = GameState(size: BoardSize(8)!, elapsed: 5)
        reduce(&state, .tick(0.5))
        #expect(state.elapsed == 5.5)
    }

    @Test("tick is a no-op once the game is won")
    func tickIsNoOpWhenWon() {
        var state = GameState(
            size: BoardSize(8)!,
            elapsed: 42.0,
            status: .won
        )
        reduce(&state, .tick(1.0))
        #expect(state.elapsed == 42.0)
    }

    // MARK: .reset

    @Test("reset clears placements, conflicts, and move count — preserves size AND elapsed")
    func resetClearsBoardButKeepsTimer() {
        var state = GameState(
            size: BoardSize(8)!,
            placements: [Position(row: 0, col: 0), Position(row: 1, col: 1)],
            conflicts: [Position(row: 0, col: 0), Position(row: 1, col: 1)],
            moveCount: 9,
            elapsed: 17.5,
            status: .playing
        )
        reduce(&state, .reset)

        #expect(state.size == BoardSize(8)!)
        #expect(state.placements.isEmpty)
        #expect(state.conflicts.isEmpty)
        #expect(state.moveCount == 0)
        #expect(state.elapsed == 17.5)
        #expect(state.status == .playing)
    }

    // MARK: .newGame

    @Test("newGame resets everything and replaces the board size")
    func newGameReplacesSizeAndResets() {
        var state = GameState(
            size: BoardSize(4)!,
            placements: [Position(row: 0, col: 1)],
            conflicts: [],
            moveCount: 3,
            elapsed: 5,
            status: .playing
        )
        reduce(&state, .newGame(BoardSize(10)!))

        #expect(state.size == BoardSize(10)!)
        #expect(state.placements.isEmpty)
        #expect(state.conflicts.isEmpty)
        #expect(state.moveCount == 0)
        #expect(state.elapsed == 0)
        #expect(state.status == .playing)
    }

    // MARK: queensRemaining

    @Test("queensRemaining is size minus placements")
    func queensRemainingIsDerived() {
        let state = GameState(
            size: BoardSize(8)!,
            placements: [
                Position(row: 0, col: 0),
                Position(row: 1, col: 2),
                Position(row: 2, col: 4)
            ]
        )
        #expect(state.queensRemaining == 5)
    }
}
