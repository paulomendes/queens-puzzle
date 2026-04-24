public struct BoardSize: Equatable, Hashable, Codable, Sendable {
    public let n: Int

    public static let minimum = 4
    public static let maximum = 10
    public static let range = minimum...maximum

    public init?(_ n: Int) {
        guard BoardSize.range.contains(n) else { return nil }
        self.n = n
    }
}
