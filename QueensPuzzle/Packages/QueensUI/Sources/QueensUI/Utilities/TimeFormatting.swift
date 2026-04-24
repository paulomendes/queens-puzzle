import Foundation

enum TimeFormatting {
    static func minutesSeconds(_ t: TimeInterval) -> String {
        let totalSeconds = Int(t)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
