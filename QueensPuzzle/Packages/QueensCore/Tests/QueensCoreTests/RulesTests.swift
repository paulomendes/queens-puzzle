import Testing
@testable import QueensCore

@Suite("Rules")
struct RulesTests {

    // MARK: Known-valid solutions

    @Test("flags no conflicts for a valid 4x4 solution")
    func validFourByFour() {
        let placements: Set<Position> = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 0),
            Position(row: 3, col: 2)
        ]
        #expect(Rules.conflicts(in: placements).isEmpty)
        #expect(Rules.isSolved(placements: placements, size: BoardSize(4)!))
    }

    @Test("flags no conflicts for a valid 5x5 solution")
    func validFiveByFive() {
        let placements: Set<Position> = [
            Position(row: 0, col: 0),
            Position(row: 1, col: 2),
            Position(row: 2, col: 4),
            Position(row: 3, col: 1),
            Position(row: 4, col: 3)
        ]
        #expect(Rules.conflicts(in: placements).isEmpty)
        #expect(Rules.isSolved(placements: placements, size: BoardSize(5)!))
    }

    @Test("flags no conflicts for a valid 6x6 solution")
    func validSixBySix() {
        let placements: Set<Position> = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 5),
            Position(row: 3, col: 0),
            Position(row: 4, col: 2),
            Position(row: 5, col: 4)
        ]
        #expect(Rules.conflicts(in: placements).isEmpty)
        #expect(Rules.isSolved(placements: placements, size: BoardSize(6)!))
    }

    @Test("flags no conflicts for a valid 8x8 solution")
    func validEightByEight() {
        let placements: Set<Position> = [
            Position(row: 0, col: 0),
            Position(row: 1, col: 4),
            Position(row: 2, col: 7),
            Position(row: 3, col: 5),
            Position(row: 4, col: 2),
            Position(row: 5, col: 6),
            Position(row: 6, col: 1),
            Position(row: 7, col: 3)
        ]
        #expect(Rules.conflicts(in: placements).isEmpty)
        #expect(Rules.isSolved(placements: placements, size: BoardSize(8)!))
    }

    // MARK: Crafted conflict cases

    @Test("flags queens sharing a row")
    func sameRowConflict() {
        let a = Position(row: 0, col: 0)
        let b = Position(row: 0, col: 5)
        #expect(Rules.conflicts(in: [a, b]) == [a, b])
    }

    @Test("flags queens sharing a column")
    func sameColumnConflict() {
        let a = Position(row: 0, col: 3)
        let b = Position(row: 7, col: 3)
        #expect(Rules.conflicts(in: [a, b]) == [a, b])
    }

    @Test("flags queens on the same backslash diagonal")
    func backslashDiagonalConflict() {
        let a = Position(row: 0, col: 0)
        let b = Position(row: 3, col: 3)
        #expect(Rules.conflicts(in: [a, b]) == [a, b])
    }

    @Test("flags queens on the same forward slash diagonal")
    func forwardSlashDiagonalConflict() {
        let a = Position(row: 0, col: 3)
        let b = Position(row: 3, col: 0)
        #expect(Rules.conflicts(in: [a, b]) == [a, b])
    }

    @Test("only flags the queens that are actually in conflict")
    func onlyConflictingQueensAreFlagged() {
        let inConflictA = Position(row: 0, col: 0)
        let inConflictB = Position(row: 4, col: 4) // same \ diagonal as A
        let isolated = Position(row: 1, col: 6) // no row/col/diagonal overlap with A or B
        let placements: Set<Position> = [inConflictA, inConflictB, isolated]
        #expect(Rules.conflicts(in: placements) == [inConflictA, inConflictB])
    }

    @Test("flags every queen touched by any conflict pair")
    func allQueensInOverlappingConflictsAreFlagged() {
        let rowMates = [
            Position(row: 0, col: 0),
            Position(row: 0, col: 3)
        ]
        let colMateOfFirst = Position(row: 5, col: 0)
        let placements: Set<Position> = Set(rowMates + [colMateOfFirst])
        #expect(Rules.conflicts(in: placements) == placements)
    }

    // MARK: isSolved negative cases

    @Test("empty board is not solved")
    func emptyBoardIsNotSolved() {
        #expect(!Rules.isSolved(placements: [], size: BoardSize(4)!))
    }

    @Test("too few queens is not solved even with no conflicts")
    func tooFewQueensIsNotSolved() {
        let placements: Set<Position> = [Position(row: 0, col: 0)]
        #expect(Rules.conflicts(in: placements).isEmpty)
        #expect(!Rules.isSolved(placements: placements, size: BoardSize(4)!))
    }

    @Test("too many queens is not solved")
    func tooManyQueensIsNotSolved() {
        var placements: Set<Position> = []
        for i in 0..<5 {
            placements.insert(Position(row: i, col: (2 * i) % 4))
        }
        #expect(!Rules.isSolved(placements: placements, size: BoardSize(4)!))
    }

    @Test("right count with at least one conflict is not solved")
    func rightCountWithConflictIsNotSolved() {
        let placements: Set<Position> = [
            Position(row: 0, col: 0),
            Position(row: 1, col: 1), // conflicts with (0,0) on the \ diagonal
            Position(row: 2, col: 3),
            Position(row: 3, col: 2)
        ]
        #expect(!Rules.isSolved(placements: placements, size: BoardSize(4)!))
    }

    // MARK: attackedSquares

    @Test("no queens means no attacked squares")
    func attackedSquaresEmptyWhenNoQueens() {
        #expect(Rules.attackedSquares(by: [], size: BoardSize(4)!).isEmpty)
    }

    @Test("a single queen attacks its full row, column, and both diagonals — but not its own square")
    func attackedSquaresForSingleQueen() {
        let q = Position(row: 1, col: 1)
        let attacked = Rules.attackedSquares(by: [q], size: BoardSize(4)!)

        #expect(!attacked.contains(q))
        // row
        #expect(attacked.contains(Position(row: 1, col: 0)))
        #expect(attacked.contains(Position(row: 1, col: 2)))
        #expect(attacked.contains(Position(row: 1, col: 3)))
        // column
        #expect(attacked.contains(Position(row: 0, col: 1)))
        #expect(attacked.contains(Position(row: 2, col: 1)))
        #expect(attacked.contains(Position(row: 3, col: 1)))
        // \ diagonal
        #expect(attacked.contains(Position(row: 0, col: 0)))
        #expect(attacked.contains(Position(row: 2, col: 2)))
        #expect(attacked.contains(Position(row: 3, col: 3)))
        // / diagonal
        #expect(attacked.contains(Position(row: 0, col: 2)))
        #expect(attacked.contains(Position(row: 2, col: 0)))

        // A square unreachable from (1,1) is NOT attacked
        #expect(!attacked.contains(Position(row: 3, col: 0)))
        #expect(!attacked.contains(Position(row: 0, col: 3)))
    }

    @Test("queen squares themselves are never marked as attacked")
    func attackedSquaresExcludeQueenSquares() {
        let a = Position(row: 0, col: 0)
        let b = Position(row: 3, col: 3) // on a's \ diagonal
        let attacked = Rules.attackedSquares(by: [a, b], size: BoardSize(4)!)
        #expect(!attacked.contains(a))
        #expect(!attacked.contains(b))
    }
}
