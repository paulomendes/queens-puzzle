import Foundation
import QueensCore

final class InMemoryBestScoresRepository: BestScoresRepository, @unchecked Sendable {
    private var times: [Int: TimeInterval] = [:]
    private var moves: [Int: Int] = [:]
    private let lock = NSLock()

    init(seedTimes: [Int: TimeInterval] = [:], seedMoves: [Int: Int] = [:]) {
        self.times = seedTimes
        self.moves = seedMoves
    }

    func bestTime(for size: BoardSize) -> TimeInterval? {
        lock.withLock { times[size.n] }
    }

    func bestMoves(for size: BoardSize) -> Int? {
        lock.withLock { moves[size.n] }
    }

    func record(time: TimeInterval, moves newMoves: Int, size: BoardSize) {
        lock.withLock {
            if let existing = times[size.n] {
                times[size.n] = min(existing, time)
            } else {
                times[size.n] = time
            }
            if let existing = moves[size.n] {
                moves[size.n] = min(existing, newMoves)
            } else {
                moves[size.n] = newMoves
            }
        }
    }
}
