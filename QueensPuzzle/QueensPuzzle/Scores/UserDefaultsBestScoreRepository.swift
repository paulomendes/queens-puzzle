import Foundation
import QueensCore

final class UserDefaultsBestScoreRepository: BestScoresRepository, @unchecked Sendable {
    enum Constants {
        static let bestTimeKey: String = "bestTimes[%@]"
        static let bestMovesKey: String = "bestMoves[%@]"
    }

    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func bestTime(for size: QueensCore.BoardSize) -> TimeInterval? {
        userDefaults.object(forKey: String(format: Constants.bestTimeKey, "\(size)")) as? TimeInterval
    }
    
    func bestMoves(for size: QueensCore.BoardSize) -> Int? {
        userDefaults.object(forKey: String(format: Constants.bestMovesKey, "\(size)")) as? Int
    }
    
    func record(time: TimeInterval, moves: Int, size: QueensCore.BoardSize) {
        if let existingTime = bestTime(for: size) {
            userDefaults.set(min(time, existingTime), forKey: String(format: Constants.bestTimeKey, "\(size)"))
        } else {
            userDefaults.set(time, forKey: String(format: Constants.bestTimeKey, "\(size)"))
        }

        if let existingMoves = bestMoves(for: size) {
            userDefaults.set(min(moves, existingMoves), forKey: String(format: Constants.bestMovesKey, "\(size)"))
        } else {
            userDefaults.set(moves, forKey: String(format: Constants.bestMovesKey, "\(size)"))
        }
    }

}
