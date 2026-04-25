import SwiftUI
import QueensCore

public struct BoardView: View {
    @Environment(\.theme) private var theme

    let size: BoardSize
    let placements: Set<Position>
    let conflicts: Set<Position>
    let attackedSquares: Set<Position>
    let isInteractive: Bool
    let onTap: (Position) -> Void

    public init(
        size: BoardSize,
        placements: Set<Position> = [],
        conflicts: Set<Position> = [],
        attackedSquares: Set<Position> = [],
        isInteractive: Bool = true,
        onTap: @escaping (Position) -> Void = { _ in }
    ) {
        self.size = size
        self.placements = placements
        self.conflicts = conflicts
        self.attackedSquares = attackedSquares
        self.isInteractive = isInteractive
        self.onTap = onTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<size.n, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<size.n, id: \.self) { col in
                        let position = Position(row: row, col: col)
                        CellView(
                            position: position,
                            isDarkSquare: isDark(row: row, col: col),
                            hasQueen: placements.contains(position),
                            isInConflict: conflicts.contains(position),
                            isAttacked: attackedSquares.contains(position),
                            isInteractive: isInteractive,
                            onTap: { onTap(position) }
                        )
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            Rectangle().stroke(theme.divider, lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.18), value: placements)
        .animation(.easeInOut(duration: 0.18), value: conflicts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(.gameBoardA11YLabel(size.n, size.n)))
    }

    private func isDark(row: Int, col: Int) -> Bool {
        (row + col).isMultiple(of: 2) == false
    }
}

#Preview("Empty 8x8") {
    BoardView(size: BoardSize(8)!)
        .padding()
        .background(Theme.chessDotCom.background)
}

#Preview("With placements + conflicts") {
    let placements: Set<Position> = [
        Position(row: 0, col: 0),
        Position(row: 1, col: 1),
        Position(row: 3, col: 5)
    ]
    let conflicts = Rules.conflicts(in: placements)
    let attacked = Rules.attackedSquares(by: placements, size: BoardSize(8)!)
    return BoardView(
        size: BoardSize(8)!,
        placements: placements,
        conflicts: conflicts,
        attackedSquares: attacked
    )
    .padding()
    .background(Theme.chessDotCom.background)
}
