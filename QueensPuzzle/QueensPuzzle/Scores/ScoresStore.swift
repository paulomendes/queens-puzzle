import Foundation
import Observation
import QueensCore

@Observable
final class ScoresStore: BestScoresRepository, @unchecked Sendable {
    private var times: [Int: TimeInterval] = [:]
    private var moves: [Int: Int] = [:]

    @ObservationIgnored
    private let repository: BestScoresRepository

    init(repository: BestScoresRepository) {
        self.repository = repository
        for n in BoardSize.range {
            guard let size = BoardSize(n) else { continue }
            times[n] = repository.bestTime(for: size)
            moves[n] = repository.bestMoves(for: size)
        }
    }

    func bestTime(for size: BoardSize) -> TimeInterval? {
        times[size.n]
    }

    func bestMoves(for size: BoardSize) -> Int? {
        moves[size.n]
    }

    func record(time: TimeInterval, moves: Int, size: BoardSize) {
        repository.record(time: time, moves: moves, size: size)
        // Re-read so the snapshot reflects the repository's min(existing, new) semantics.
        times[size.n] = repository.bestTime(for: size)
        self.moves[size.n] = repository.bestMoves(for: size)
    }
}
