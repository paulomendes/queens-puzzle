import Testing
@testable import QueensCore

@Suite("GameTransition")
struct GameTransitionTests {

    private let size = BoardSize(8)!
    private let a = Position(row: 0, col: 0)
    private let b = Position(row: 1, col: 1)
    private let c = Position(row: 2, col: 2)

    // MARK: - Placement / removal

    @Test("placing a queen sets queenPlaced")
    func placingQueenIsDetected() {
        let previous = GameState(size: size)
        let current = GameState(size: size, placements: [a])

        let transition = GameTransition(from: previous, to: current)

        #expect(transition.queenPlaced == a)
        #expect(transition.queenRemoved == nil)
    }

    @Test("removing a queen sets queenRemoved")
    func removingQueenIsDetected() {
        let previous = GameState(size: size, placements: [a])
        let current = GameState(size: size)

        let transition = GameTransition(from: previous, to: current)

        #expect(transition.queenPlaced == nil)
        #expect(transition.queenRemoved == a)
    }

    @Test("identical placements produce no place or remove")
    func unchangedPlacementsProduceNoPlaceOrRemove() {
        let state = GameState(size: size, placements: [a, b])

        let transition = GameTransition(from: state, to: state)

        #expect(transition.queenPlaced == nil)
        #expect(transition.queenRemoved == nil)
    }

    // MARK: - conflictsChanged

    @Test("conflicts appearing (empty → non-empty) is a change")
    func conflictsAppearingIsDetected() {
        let previous = GameState(size: size)
        let current = GameState(size: size, conflicts: [a, b])

        let transition = GameTransition(from: previous, to: current)

        #expect(transition.conflictsChanged == true)
    }

    @Test("conflicts cleared (non-empty → empty) is NOT a change")
    func conflictsClearedIsNotChange() {
        let previous = GameState(size: size, conflicts: [a, b])
        let current = GameState(size: size)

        let transition = GameTransition(from: previous, to: current)

        #expect(transition.conflictsChanged == false)
    }

    @Test("conflicts mutating but staying non-empty is a change")
    func conflictsMutatingButStillNonEmptyIsChange() {
        let previous = GameState(size: size, conflicts: [a, b])
        let current = GameState(size: size, conflicts: [a, c])

        let transition = GameTransition(from: previous, to: current)

        #expect(transition.conflictsChanged == true)
    }

    @Test("unchanged non-empty conflicts is NOT a change")
    func unchangedConflictsIsNotChange() {
        let state = GameState(size: size, conflicts: [a, b])

        let transition = GameTransition(from: state, to: state)

        #expect(transition.conflictsChanged == false)
    }

    // MARK: - didWin

    @Test("playing → won sets didWin")
    func winTransitionIsDetected() {
        let previous = GameState(size: size, status: .playing)
        let current = GameState(size: size, status: .won)

        let transition = GameTransition(from: previous, to: current)

        #expect(transition.didWin == true)
    }

    @Test("won → won does not set didWin")
    func alreadyWonIsNotWin() {
        let state = GameState(size: size, status: .won)

        let transition = GameTransition(from: state, to: state)

        #expect(transition.didWin == false)
    }

    @Test("playing → playing does not set didWin")
    func playingToPlayingIsNotWin() {
        let state = GameState(size: size, status: .playing)

        let transition = GameTransition(from: state, to: state)

        #expect(transition.didWin == false)
    }
}
