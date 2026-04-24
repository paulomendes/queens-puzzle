import Foundation

public enum GameAction: Equatable, Sendable {
    case tap(Position)
    case tick(TimeInterval)
    case reset
    case newGame(BoardSize)
}
