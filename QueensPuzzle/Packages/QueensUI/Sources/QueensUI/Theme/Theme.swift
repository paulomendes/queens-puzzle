import SwiftUI

public struct Theme: Sendable {
    public let background: Color
    public let card: Color
    public let cardInset: Color
    public let divider: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let accent: Color
    public let accentPressed: Color
    public let onAccent: Color
    public let boardLight: Color
    public let boardDark: Color
    public let boardHighlight: Color
    public let conflictOnLight: Color
    public let conflictOnDark: Color
    public let winBadge: Color
    public let attackOnDark: Color
    public let attackOnLight: Color

    public static let chessDotCom = Theme(
        background: Color("surface-root", bundle: .module),
        card: Color("surface-elevated", bundle: .module),
        cardInset: Color("surface-inset", bundle: .module),
        divider: Color("surface-divider", bundle: .module),
        textPrimary: Color("text-primary", bundle: .module),
        textSecondary: Color("text-secondary", bundle: .module),
        accent: Color("green-primary", bundle: .module),
        accentPressed: Color("green-primary-dark", bundle: .module),
        onAccent: Color("text-on-accent", bundle: .module),
        boardLight: Color("board-light-square", bundle: .module),
        boardDark: Color("board-dark-square", bundle: .module),
        boardHighlight: Color("board-highlight", bundle: .module),
        conflictOnLight: Color("board-conflict-dark", bundle: .module),
        conflictOnDark: Color("board-conflict", bundle: .module),
        winBadge: Color("state-success", bundle: .module),
        attackOnDark: Color("attack-dark", bundle: .module),
        attackOnLight: Color("attack-light", bundle: .module)
    )
}

extension EnvironmentValues {
    @Entry public var theme: Theme = .chessDotCom
}
