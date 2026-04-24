import QueensCore

/// Placeholder sound service. Real AVAudioPlayer-backed implementation lands
/// with the sound assets; until then we no-op so the composition root compiles.
struct NoOpSoundService: SoundService {
    func play(_ effect: SoundEffect) {}
}
