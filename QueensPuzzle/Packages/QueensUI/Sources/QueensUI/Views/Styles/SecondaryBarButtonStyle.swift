import SwiftUI

struct SecondaryBarButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(theme.textPrimary)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(theme.card)
                    .stroke(theme.divider, lineWidth: 1)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            }
    }
}
