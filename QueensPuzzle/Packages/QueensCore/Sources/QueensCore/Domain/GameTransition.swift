import Foundation

/// A pure description of what changed between two `GameState`s.
///
/// Construct once per state transition and let the side-effecting layer
/// (e.g. `GameStore`) read these fields instead of re-deriving deltas
/// from `previous` and `current` ad hoc.
public struct GameTransition: Equatable, Sendable {
    /// The position of the queen placed by this transition, if any.
    /// Mutually exclusive with `queenRemoved`.
    public let queenPlaced: Position?

    /// The position of the queen removed by this transition, if any.
    /// Mutually exclusive with `queenPlaced`.
    public let queenRemoved: Position?

    /// True iff the conflict set changed AND is non-empty after the transition.
    /// False when the transition cleared all conflicts, or left them unchanged —
    /// i.e. the predicate that gates the conflict haptic.
    public let conflictsChanged: Bool

    /// True iff `status` moved from `.playing` to `.won` in this transition.
    public let didWin: Bool

    public init(from previous: GameState, to current: GameState) {
        let added = current.placements.subtracting(previous.placements)
        let removed = previous.placements.subtracting(current.placements)
        // A single tap toggles at most one cell, so at most one is non-empty.
        self.queenPlaced = added.first
        self.queenRemoved = removed.first
        self.conflictsChanged = current.conflicts != previous.conflicts && !current.conflicts.isEmpty
        self.didWin = previous.status != .won && current.status == .won
    }
}
