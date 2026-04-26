import SwiftUI
import QueensCore

struct CellView: View {
    @Environment(\.theme) private var theme

    let position: Position
    let boardSize: BoardSize
    let isDarkSquare: Bool
    let hasQueen: Bool
    let isInConflict: Bool
    let isAttacked: Bool
    let isInteractive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                background
                if hasQueen {
                    queen
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isInteractive)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityLabel))
        .accessibilityHint(Text(accessibilityHint))
        .accessibilityIdentifier(notation)
        .accessibilityAddTraits(.isButton)
    }

    private var background: some View {
        let base = isDarkSquare ? theme.boardDark : theme.boardLight
        let conflict = isDarkSquare ? theme.conflictOnDark : theme.conflictOnLight
        return ZStack {
            Rectangle().fill(base)
            if isInConflict {
                Rectangle().fill(conflict)
            } else if isAttacked {
                Circle()
                    .fill(theme.background)
                    .opacity(0.5)
                    .padding(8)

            }
        }
    }

    private var queen: some View {
        Image("white-queen", bundle: .module)
            .resizable()
            .scaledToFit()
            .padding(6)
            .foregroundStyle(isInConflict ? Color.white : theme.textPrimary)
            .symbolEffect(.pulse, options: .repeating, isActive: isInConflict)
    }

    private var notation: String {
        position.algebraic(boardSize: boardSize)
    }

    private var accessibilityLabel: LocalizedStringResource {
        if hasQueen {
            if isInConflict {
                return .gameCellA11YQueenPlacedConflict(notation)
            }
            return .gameCellA11YQueenPlaced(notation)
        }
        if isAttacked {
            return .gameCellA11YUnderAttack(notation)
        }
        return .gameCellA11YEmpty(notation)
    }

    private var accessibilityHint: LocalizedStringResource {
        hasQueen ? .gameCellA11YHintRemove : .gameCellA11YHintPlace
    }
}

