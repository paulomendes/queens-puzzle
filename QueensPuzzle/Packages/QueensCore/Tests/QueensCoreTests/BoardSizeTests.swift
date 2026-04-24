import Testing
@testable import QueensCore

@Suite("BoardSize")
struct BoardSizeTests {
    @Test("accepts values inside 4...10")
    func acceptsInRangeValues() {
        for n in 4...10 {
            #expect(BoardSize(n)?.n == n)
        }
    }

    @Test("rejects values below the minimum")
    func rejectsBelowMinimum() {
        #expect(BoardSize(0) == nil)
        #expect(BoardSize(3) == nil)
        #expect(BoardSize(-1) == nil)
    }

    @Test("rejects values above the maximum")
    func rejectsAboveMaximum() {
        #expect(BoardSize(11) == nil)
        #expect(BoardSize(16) == nil)
        #expect(BoardSize(100) == nil)
    }

    @Test("exposes the configured bounds")
    func exposesBounds() {
        #expect(BoardSize.minimum == 4)
        #expect(BoardSize.maximum == 10)
    }
}
