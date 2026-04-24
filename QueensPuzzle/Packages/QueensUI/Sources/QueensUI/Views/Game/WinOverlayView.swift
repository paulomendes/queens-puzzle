import SwiftUI
import QueensCore

struct WinOverlayView: View {
    @Environment(\.theme) private var theme

    let elapsed: TimeInterval
    let moveCount: Int
    let isNewBestTime: Bool
    let isNewBestMoves: Bool
    let onRetry: () -> Void
    let onLeave: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                Text("You won!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 24) {
                    stat(label: "Time", value: TimeFormatting.minutesSeconds(elapsed))
                    stat(label: "Moves", value: "\(moveCount)")
                }

                if isNewBestTime || isNewBestMoves {
                    Text(newRecordMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.winBadge)
                        .padding(.top, 4)
                }

                HStack(spacing: 12) {
                    Button("Leave", role: .destructive, action: onLeave)
                        .buttonStyle(SecondaryBarButtonStyle())
                    Button("Retry", action: onRetry)
                        .buttonStyle(PrimaryBarButtonStyle())
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(24)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private var newRecordMessage: String {
        if isNewBestTime && isNewBestMoves { return "New best time and move count!" }
        if isNewBestTime { return "New best time!" }
        return "New fewest moves!"
    }

    @ViewBuilder
    private func stat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.textSecondary)
            Text(value)
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(theme.textPrimary)
        }
    }
}
