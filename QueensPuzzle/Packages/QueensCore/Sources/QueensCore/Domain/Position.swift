public struct Position: Equatable, Hashable, Codable, Sendable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    public func algebraic(boardSize: BoardSize) -> String {
        let aScalar = ("a" as Unicode.Scalar).value
        let file = Character(Unicode.Scalar(aScalar + UInt32(col))!)
        let rank = boardSize.n - row
        return "\(file)\(rank)"
    }
}
