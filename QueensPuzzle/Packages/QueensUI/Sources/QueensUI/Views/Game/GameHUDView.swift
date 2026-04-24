import SwiftUI
import QueensCore

struct GameHUDView: View {
    @Environment(\.theme) private var theme
    let queensRemaining: Int
    let elapsedText: String
    let moveCount: Int

    var body: some View {
        HStack(spacing: 12) {
            pill {
                Image("white-queen", bundle: .module)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(theme.textPrimary)
                Text("\(queensRemaining)")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(theme.textPrimary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Queens remaining: \(queensRemaining)")

            pill {
                Image(systemName: "clock")
                    .foregroundStyle(theme.textSecondary)
                Text(elapsedText)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(theme.textPrimary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Elapsed time: \(elapsedText)")

            pill {
                Image(systemName: "hand.tap")
                    .foregroundStyle(theme.textSecondary)
                Text("\(moveCount)")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(theme.textPrimary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Moves: \(moveCount)")
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func pill<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 6) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
