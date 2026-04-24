import SwiftUI
import QueensCore

public struct HomeView: View {
    @Environment(\.theme) private var theme

    @State private var selectedSize: Int = 8

    private let bestTime: (BoardSize) -> TimeInterval?
    private let bestMoves: (BoardSize) -> Int?
    private let onStartGame: (BoardSize) -> Void

    public init(
        bestTime: @escaping (BoardSize) -> TimeInterval? = { _ in nil },
        bestMoves: @escaping (BoardSize) -> Int? = { _ in nil },
        onStartGame: @escaping (BoardSize) -> Void = { _ in }
    ) {
        self.bestTime = bestTime
        self.bestMoves = bestMoves
        self.onStartGame = onStartGame
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Queens Puzzle")
                .font(.largeTitle.bold())
                .foregroundStyle(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            scoresTable

            Spacer(minLength: 0)

            bottomBar
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
    }

    private var scoresTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Board")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Best Time")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Best Moves")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Rectangle()
                .fill(theme.divider)
                .frame(height: 1)

            ForEach(BoardSize.range, id: \.self) { n in
                let size = BoardSize(n)!
                ScoreRow(
                    size: n,
                    bestTime: bestTimeText(for: size),
                    bestMoves: bestMovesText(for: size)
                )
                if n < BoardSize.maximum {
                    Rectangle()
                        .fill(theme.divider)
                        .frame(height: 1)
                        .padding(.leading, 16)
                }
            }
        }
        .background(theme.cardInset, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button("Start New Puzzle", action: startGame)
                .buttonStyle(PrimaryBarButtonStyle())

            Picker("Size", selection: $selectedSize) {
                ForEach(BoardSize.range, id: \.self) { n in
                    Text("\(n)").tag(n)
                }
            }
            .pickerStyle(.menu)
            .tint(theme.textPrimary)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityLabel("Board size")
        }
        .padding(.horizontal)
    }

    private func startGame() {
        guard let size = BoardSize(selectedSize) else { return }
        onStartGame(size)
    }

    private func bestTimeText(for size: BoardSize) -> String {
        guard let time = bestTime(size) else { return "-" }
        return TimeFormatting.minutesSeconds(time)
    }

    private func bestMovesText(for size: BoardSize) -> String {
        guard let moves = bestMoves(size) else { return "-" }
        return "\(moves)"
    }
}

#Preview("Empty scores") {
    HomeView()
}

#Preview("Seeded scores") {
    let times: [Int: TimeInterval] = [4: 60, 5: 170, 8: 245]
    let moves: [Int: Int] = [4: 6, 5: 11, 8: 24]
    HomeView(
        bestTime: { times[$0.n] },
        bestMoves: { moves[$0.n] }
    )
}
