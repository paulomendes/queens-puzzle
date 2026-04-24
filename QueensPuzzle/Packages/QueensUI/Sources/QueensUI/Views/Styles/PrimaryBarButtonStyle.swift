import SwiftUI

struct PrimaryBarButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(theme.onAccent)
            .background(
                configuration.isPressed ? theme.accentPressed : theme.accent,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
    }
}
