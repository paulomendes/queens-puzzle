import Foundation

/// Pure state transition. Side effects (haptics, sound, timer, persistence) are the
/// store's responsibility — never perform I/O from here.
public func reduce(_ state: inout GameState, _ action: GameAction) {
    switch action {
    case .tap(let position):
        guard state.status == .playing else { return }
        if state.placements.contains(position) {
            state.placements.remove(position)
        } else {
            state.placements.insert(position)
        }
        state.moveCount += 1
        state.conflicts = Rules.conflicts(in: state.placements)
        if Rules.isSolved(placements: state.placements, size: state.size) {
            state.status = .won
        }

    case .tick(let delta):
        guard state.status == .playing else { return }
        state.elapsed += delta

    case .reset:
        // Reset clears the board but preserves size and elapsed — the timer only
        // stops on win or abort. Full restart (including timer) is `.newGame`.
        state.placements = []
        state.conflicts = []
        state.moveCount = 0
        state.status = .playing

    case .newGame(let size):
        state = GameState(size: size)
    }
}
