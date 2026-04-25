import SwiftUI
import QueensCore

public struct HomeView: View {
    @Environment(\.theme) private var theme
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass

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

    private var isPad: Bool {
        hSizeClass == .regular && vSizeClass == .regular
    }

    private var isCompactHeight: Bool {
        vSizeClass == .compact
    }

    public var body: some View {
        Group {
            if isPad {
                iPadBody
            } else if isCompactHeight {
                iPhoneLandscapeBody
            } else {
                portraitBody
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
    }

    private var iPadBody: some View {
        VStack(spacing: 16) {
            title
            scoresTable
            Spacer(minLength: 0)
            bottomBar
        }
        .padding(.vertical, 16)
        .containerRelativeFrame(.horizontal) { length, _ in length / 3 }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var portraitBody: some View {
        VStack(spacing: 16) {
            title
            scoresTable
            Spacer(minLength: 0)
            bottomBar
        }
        .padding(.vertical, 16)
    }

    private var iPhoneLandscapeBody: some View {
        HStack(alignment: .top, spacing: 16) {
            scoresTable
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 16) {
                title
                Spacer(minLength: 0)
                bottomBar
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
    }

    private var title: some View {
        Text(.homeTitle)
            .font(.largeTitle.bold())
            .foregroundStyle(theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }

    private var scoresTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(.homeScoresColumnBoard)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(.homeScoresColumnBestTime)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(.homeScoresColumnBestMoves)
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
            Button(action: startGame) {
                Text(.homeButtonStartNewPuzzle)
            }
            .buttonStyle(PrimaryBarButtonStyle())

            Picker(selection: $selectedSize) {
                ForEach(BoardSize.range, id: \.self) { n in
                    Text("\(n)").tag(n)
                }
            } label: {
                Text(.homeSizeLabel)
            }
            .pickerStyle(.menu)
            .tint(theme.textPrimary)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityLabel(Text(.homeSizeA11YLabel))
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
