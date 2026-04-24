import Foundation
import QueensCore

struct SystemClock: Clock {
    func ticks(interval: TimeInterval) -> AsyncStream<TimeInterval> {
        let (stream, continuation) = AsyncStream.makeStream(of: TimeInterval.self)
        let task = Task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(interval))
                } catch {
                    break
                }
                continuation.yield(interval)
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in task.cancel() }
        return stream
    }
}
