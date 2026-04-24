import UIKit
import QueensCore

struct SystemHapticsService: HapticsService {
    func play(_ event: HapticEvent) {
        Task { @MainActor in
            switch event {
            case .placeQueen:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .removeQueen:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            case .conflict:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .win:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}
