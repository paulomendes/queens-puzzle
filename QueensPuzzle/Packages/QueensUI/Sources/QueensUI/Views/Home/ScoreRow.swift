import SwiftUI

struct ScoreRow: View {
    @Environment(\.theme) private var theme
    let size: Int
    let bestTime: String
    let bestMoves: String

    var body: some View {
        HStack(spacing: 0) {
            Text("\(size)")
                .font(.body.monospacedDigit())
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(bestTime)
                .font(.body.monospacedDigit())
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(bestMoves)
                .font(.body.monospacedDigit())
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Board size \(size)")
        .accessibilityValue("Best time \(bestTime), best moves \(bestMoves)")
    }
}
