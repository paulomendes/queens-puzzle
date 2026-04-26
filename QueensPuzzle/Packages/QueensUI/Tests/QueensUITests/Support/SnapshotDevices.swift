import UIKit
import SnapshotTesting

// Canonical simulators for snapshot recording / comparison:
//   - iPhone 17 Pro (iOS 26.4)
//   - iPad Pro 13-inch (M5) 16GB (iOS 26.4)
//
// Snapshots are simulator-specific; running on a different simulator will
// produce false-positive diffs. If Apple changes the screen geometry of these
// devices, re-record on the new sim and update the size/safeArea constants below.
@MainActor
enum SnapshotDevices {
    static let iPhone17ProPortrait = ViewImageConfig(
        safeArea: .init(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 402, height: 874),
        traits: UITraitCollection { traits in
            traits.horizontalSizeClass = .compact
            traits.verticalSizeClass = .regular
            traits.userInterfaceIdiom = .phone
            traits.displayScale = 3
        }
    )

    static let iPhone17ProLandscape = ViewImageConfig(
        safeArea: .init(top: 0, left: 59, bottom: 21, right: 59),
        size: CGSize(width: 874, height: 402),
        traits: UITraitCollection { traits in
            traits.horizontalSizeClass = .compact
            traits.verticalSizeClass = .compact
            traits.userInterfaceIdiom = .phone
            traits.displayScale = 3
        }
    )

    static let iPadPro13Portrait = ViewImageConfig(
        safeArea: .init(top: 24, left: 0, bottom: 20, right: 0),
        size: CGSize(width: 1032, height: 1376),
        traits: UITraitCollection { traits in
            traits.horizontalSizeClass = .regular
            traits.verticalSizeClass = .regular
            traits.userInterfaceIdiom = .pad
            traits.displayScale = 2
        }
    )
}
