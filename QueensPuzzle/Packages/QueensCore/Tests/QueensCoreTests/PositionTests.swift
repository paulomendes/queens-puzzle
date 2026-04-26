import Testing
@testable import QueensCore

@Suite("Position")
struct PositionTests {
    @Suite("algebraic(boardSize:)")
    struct Algebraic {
        @Test("bottom-left corner is a1 on every board size")
        func bottomLeftIsA1() {
            for n in BoardSize.range {
                let size = BoardSize(n)!
                #expect(Position(row: n - 1, col: 0).algebraic(boardSize: size) == "a1")
            }
        }

        @Test("top-left corner reflects the rank inversion")
        func topLeftRankInverts() {
            #expect(Position(row: 0, col: 0).algebraic(boardSize: BoardSize(4)!) == "a4")
            #expect(Position(row: 0, col: 0).algebraic(boardSize: BoardSize(8)!) == "a8")
            #expect(Position(row: 0, col: 0).algebraic(boardSize: BoardSize(10)!) == "a10")
        }

        @Test("top-right corner uses the file letter at the max column")
        func topRightFile() {
            #expect(Position(row: 0, col: 3).algebraic(boardSize: BoardSize(4)!) == "d4")
            #expect(Position(row: 0, col: 7).algebraic(boardSize: BoardSize(8)!) == "h8")
            #expect(Position(row: 0, col: 9).algebraic(boardSize: BoardSize(10)!) == "j10")
        }

        @Test("bottom-right corner")
        func bottomRight() {
            #expect(Position(row: 3, col: 3).algebraic(boardSize: BoardSize(4)!) == "d1")
            #expect(Position(row: 7, col: 7).algebraic(boardSize: BoardSize(8)!) == "h1")
            #expect(Position(row: 9, col: 9).algebraic(boardSize: BoardSize(10)!) == "j1")
        }

        @Test("a non-corner cell — (row:4,col:4) on 8x8 is e4")
        func eFourOnEightByEight() {
            #expect(Position(row: 4, col: 4).algebraic(boardSize: BoardSize(8)!) == "e4")
        }
    }
}
