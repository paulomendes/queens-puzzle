public enum Rules {
    /// Returns the subset of `placements` that are in conflict with at least one other
    /// placed queen. Two queens conflict if they share a row, a column, or a diagonal.
    public static func conflicts(in placements: Set<Position>) -> Set<Position> {
        guard placements.count > 1 else { return [] }

        let queens = Array(placements)
        var flagged: Set<Position> = []

        for i in 0..<queens.count {
            let a = queens[i]
            for j in (i + 1)..<queens.count {
                let b = queens[j]
                if attack(a, b) {
                    flagged.insert(a)
                    flagged.insert(b)
                }
            }
        }
        return flagged
    }

    /// True iff the number of placements equals the board size and no queen is in conflict.
    public static func isSolved(placements: Set<Position>, size: BoardSize) -> Bool {
        placements.count == size.n && conflicts(in: placements).isEmpty
    }

    /// All empty squares threatened by at least one queen in `placements`. Used by the
    /// board to highlight attack lanes. Excludes the queen squares themselves.
    public static func attackedSquares(by placements: Set<Position>, size: BoardSize) -> Set<Position> {
        guard !placements.isEmpty else { return [] }
        var attacked: Set<Position> = []
        for row in 0..<size.n {
            for col in 0..<size.n {
                let p = Position(row: row, col: col)
                if placements.contains(p) { continue }
                for q in placements where attack(q, p) {
                    attacked.insert(p)
                    break
                }
            }
        }
        return attacked
    }

    private static func attack(_ a: Position, _ b: Position) -> Bool {
        if a.row == b.row { return true }
        if a.col == b.col { return true }
        return abs(a.row - b.row) == abs(a.col - b.col)
    }
}
