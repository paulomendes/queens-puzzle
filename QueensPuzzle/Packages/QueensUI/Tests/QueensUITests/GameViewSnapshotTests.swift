import Testing
import SnapshotTesting
import QueensCore
@testable import QueensUI

@MainActor
@Suite(.snapshots)
struct GameViewSnapshotTests {
    @Test func fresh8x8_iPhonePortrait() {
        let view = GameView(state: GameStateFixtures.fresh(n: 8))
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProPortrait)))
    }

    @Test func fresh8x8_iPhoneLandscape() {
        let view = GameView(state: GameStateFixtures.fresh(n: 8))
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProLandscape)))
    }

    @Test func fresh8x8_iPadPortrait() {
        let view = GameView(state: GameStateFixtures.fresh(n: 8))
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPadPro13Portrait)))
    }

    @Test func midGameWithConflicts_iPhonePortrait() {
        let view = GameView(state: GameStateFixtures.midGameWithConflicts())
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProPortrait)))
    }

    @Test func midGameWithConflicts_iPhoneLandscape() {
        let view = GameView(state: GameStateFixtures.midGameWithConflicts())
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProLandscape)))
    }

    @Test func midGameWithConflicts_iPadPortrait() {
        let view = GameView(state: GameStateFixtures.midGameWithConflicts())
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPadPro13Portrait)))
    }

    @Test func wonNewBestTime_iPhonePortrait() {
        let view = GameView(
            state: GameStateFixtures.won4x4(),
            isNewBestTime: true,
            isNewBestMoves: false
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProPortrait)))
    }

    @Test func wonNewBestTime_iPhoneLandscape() {
        let view = GameView(
            state: GameStateFixtures.won4x4(),
            isNewBestTime: true,
            isNewBestMoves: false
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProLandscape)))
    }

    @Test func wonNewBestTime_iPadPortrait() {
        let view = GameView(
            state: GameStateFixtures.won4x4(),
            isNewBestTime: true,
            isNewBestMoves: false
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPadPro13Portrait)))
    }

    @Test func wonBothBests_iPhonePortrait() {
        let view = GameView(
            state: GameStateFixtures.won4x4(),
            isNewBestTime: true,
            isNewBestMoves: true
        )
        assertSnapshot(of: view, as: .image(layout: .device(config: SnapshotDevices.iPhone17ProPortrait)))
    }
}
