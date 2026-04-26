import AudioToolbox
import Foundation
import QueensCore

final class SystemSoundService: SoundService, @unchecked Sendable {
    private let soundIDs: [SoundEffect: SystemSoundID]

    init() {
        var loaded: [SoundEffect: SystemSoundID] = [:]
        for (effect, resource) in Self.resources {
            guard let url = Bundle.main.url(forResource: resource, withExtension: "wav") else {
                continue
            }
            var id: SystemSoundID = 0
            guard AudioServicesCreateSystemSoundID(url as CFURL, &id) == kAudioServicesNoError else {
                continue
            }
            loaded[effect] = id
        }
        self.soundIDs = loaded
    }

    deinit {
        for id in soundIDs.values {
            AudioServicesDisposeSystemSoundID(id)
        }
    }

    func play(_ effect: SoundEffect) {
        guard let id = soundIDs[effect] else { return }
        AudioServicesPlaySystemSound(id)
    }

    private static let resources: [(SoundEffect, String)] = [
        (.placeQueen, "add"),
        (.removeQueen, "remove"),
        (.conflict, "conflict"),
        (.win, "won"),
    ]
}
