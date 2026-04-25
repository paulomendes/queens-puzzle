import Foundation
import Testing
import SnapshotTesting
import QueensCore
@testable import QueensUI

@MainActor
@Suite struct HomeViewSnapshotTests {
    @Test func emptyScores_iPhonePortrait() {
        let view = HomeView()
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProPortrait)))
    }

    @Test func emptyScores_iPhoneLandscape() {
        let view = HomeView()
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProLandscape)))
    }

    @Test func emptyScores_iPadPortrait() {
        let view = HomeView()
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPadPro13Portrait)))
    }

    @Test func seededScores_iPhonePortrait() {
        let view = seededHomeView()
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProPortrait)))
    }

    @Test func seededScores_iPhoneLandscape() {
        let view = seededHomeView()
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProLandscape)))
    }

    @Test func seededScores_iPadPortrait() {
        let view = seededHomeView()
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPadPro13Portrait)))
    }

    private func seededHomeView() -> HomeView {
        HomeView(
            bestTime: { GameStateFixtures.seededBestTimes[$0.n] },
            bestMoves: { GameStateFixtures.seededBestMoves[$0.n] }
        )
    }
}
