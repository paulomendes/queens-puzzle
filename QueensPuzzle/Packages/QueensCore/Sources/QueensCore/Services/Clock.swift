import Foundation

public protocol Clock: Sendable {
    /// Emits the number of seconds since the last tick on the given cadence until the
    /// caller cancels the stream's task. Implementations decide whether to account for
    /// drift; callers must treat the delta as authoritative.
    func ticks(interval: TimeInterval) -> AsyncStream<TimeInterval>
}
