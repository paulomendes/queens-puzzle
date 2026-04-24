import SwiftUI
import QueensCore

struct CellView: View {
    @Environment(\.theme) private var theme

    let position: Position
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
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }

    private var background: some View {
        let base = isDarkSquare ? theme.boardDark : theme.boardLight
        let conflict = isDarkSquare ? theme.conflictOnDark : theme.conflictOnLight
        // Attack highlight is drawn as a translucent overlay so the underlying
        // light/dark square still reads through — otherwise the whole attacked
        // region flattens into a single colour and the checkerboard disappears.
        return ZStack {
            Rectangle().fill(base)
            if isInConflict {
                Rectangle().fill(conflict)
            } else if isAttacked {
                Rectangle().fill(theme.boardHighlight.opacity(0.65))
            }
        }
    }

    private var queen: some View {
        Image("white-queen", bundle: .module)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .padding(6)
            .foregroundStyle(isInConflict ? Color.white : theme.textPrimary)
            .symbolEffect(.pulse, options: .repeating, isActive: isInConflict)
    }

    private var accessibilityLabel: String {
        let row = position.row + 1
        let col = position.col + 1
        if hasQueen {
            if isInConflict {
                return "Row \(row), column \(col), queen placed, in conflict"
            }
            return "Row \(row), column \(col), queen placed"
        }
        if isAttacked {
            return "Row \(row), column \(col), under attack"
        }
        return "Row \(row), column \(col), empty"
    }

    private var accessibilityHint: String {
        hasQueen ? "Double tap to remove queen" : "Double tap to place queen"
    }
}
