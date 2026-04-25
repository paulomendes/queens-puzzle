public enum SoundEffect: Equatable, Sendable {
    case placeQueen
    case removeQueen
    case conflict
    case win
}

public protocol SoundService: Sendable {
    func play(_ effect: SoundEffect)
}
