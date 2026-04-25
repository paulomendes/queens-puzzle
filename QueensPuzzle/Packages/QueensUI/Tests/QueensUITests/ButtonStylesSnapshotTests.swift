import SwiftUI
import Testing
import SnapshotTesting
@testable import QueensUI

@MainActor
@Suite struct ButtonStylesSnapshotTests {
    private let frame = (width: 280.0, height: 80.0)

    @Test func primary() {
        let view = Button("Start", action: {})
            .buttonStyle(PrimaryBarButtonStyle())
            .padding()
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }

    @Test func secondary() {
        let view = Button("Cancel", action: {})
            .buttonStyle(SecondaryBarButtonStyle())
            .padding()
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }

    @Test func secondary_destructiveRole() {
        let view = Button(role: .destructive, action: {}) {
            Text("Abort")
        }
        .buttonStyle(SecondaryBarButtonStyle())
        .padding()
        assertSnapshot(of: view, as: .image(layout: .fixed(width: frame.width, height: frame.height)))
    }
}
