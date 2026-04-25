import AVFoundation
import os

final class AppAudioSession {
    private let audioSession: AVAudioSession
    private let logger = Logger(subsystem: "lilystar.QueensPuzzle", category: "audio")

    init(audioSession: AVAudioSession) {
        self.audioSession = audioSession
    }

    func configure() {
        do {
            // Avoid pausing any playing media when playing game sounds
            try audioSession.setCategory(.ambient, options: [.mixWithOthers])
        } catch {
            logger.error(
                "Failed to configure audio session: \(error.localizedDescription)"
            )
        }
    }
}
