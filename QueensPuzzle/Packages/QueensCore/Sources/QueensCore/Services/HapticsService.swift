public enum HapticEvent: Equatable, Sendable {
    case placeQueen
    case removeQueen
    case conflict
    case win
}

public protocol HapticsService: Sendable {
    func play(_ event: HapticEvent)
}
