import AVFoundation
import QueensCore

final class SystemSoundService: SoundService, @unchecked Sendable {
    private let players: [SoundEffect: AVAudioPlayer]

    init() {
        // Pre-load SFX
        var loaded: [SoundEffect: AVAudioPlayer] = [:]
        for (effect, resource) in Self.resources {
            guard let url = Bundle.main.url(forResource: resource, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else {
                continue
            }
            player.prepareToPlay()
            loaded[effect] = player
        }
        self.players = loaded
    }

    func play(_ effect: SoundEffect) {
        guard let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }

    private static let resources: [(SoundEffect, String)] = [
        (.placeQueen, "add"),
        (.removeQueen, "remove"),
        (.conflict, "conflict"),
        (.win, "won"),
    ]
}
