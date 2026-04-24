# Queens Puzzle — Visual Design

UI language is borrowed from Chess.com: warm greens on a dark, muted background, with the familiar board cream/green as the gameplay surface. This document defines the color palette and semantic tokens. Fonts are intentionally out of scope — use the system font.

## Sourcing note

Chess.com does not publish an official brand-guidelines kit. The hex values below are taken from the public Chess.com site (logo, default "Green" board theme, dark UI chrome) and community-maintained palette references. Treat them as faithful approximations of the Chess.com look — not a legally endorsed brand kit. For a take-home coding exercise that's fine; if this ever shipped commercially we'd want Chess.com's actual brand assets.

## Palette — Raw Tokens

These are the source-of-truth hex values. Everything else in the app references a semantic name that resolves to one of these.

### Brand greens

| Name               | Hex       | Use                                                        |
| ------------------ | --------- | ---------------------------------------------------------- |
| `green/primary`    | `#81B64C` | Primary CTA button fill, brand accents, active states.     |
| `green/primaryDark`| `#6B9A3C` | Pressed / hover state of primary CTA.                      |
| `green/deep`       | `#769656` | Board dark square; secondary brand green.                  |
| `green/forest`     | `#4E7837` | Darker green for subtle accents, borders on green cards.   |

### Board surface

| Name                 | Hex       | Use                                                   |
| -------------------- | --------- | ----------------------------------------------------- |
| `board/lightSquare`  | `#EEEED2` | Light squares of the chessboard (warm cream).         |
| `board/darkSquare`   | `#769656` | Dark squares of the chessboard (Chess.com green).     |
| `board/highlight`    | `#BACA44` | Tap feedback / selected square glow (yellow-green).   |
| `board/conflict`     | `#EB6150` | Cell overlay when a queen conflicts (warm red).       |
| `board/conflictDark` | `#C3412F` | Conflict overlay on light squares (deeper red).       |

### Surface / chrome (dark UI)

| Name               | Hex       | Use                                                 |
| ------------------ | --------- | --------------------------------------------------- |
| `surface/root`     | `#312E2B` | App background behind everything (dark warm gray). |
| `surface/elevated` | `#3D3A37` | Cards, modals, HUD pill backgrounds.                |
| `surface/inset`    | `#262421` | Deeper inset — e.g. best-scores list rows.          |
| `surface/divider`  | `#4B4847` | 1pt separator lines and subtle borders.             |

### Text

| Name              | Hex       | Use                                              |
| ----------------- | --------- | ------------------------------------------------ |
| `text/primary`    | `#FFFFFF` | Primary text on dark surfaces.                   |
| `text/secondary`  | `#B8B6B4` | Secondary / metadata text on dark surfaces.      |
| `text/inverse`    | `#2C2B29` | Text on light surfaces (e.g. on cream cards).    |
| `text/onAccent`   | `#FFFFFF` | Text drawn on top of `green/primary`.            |

### State

| Name            | Hex       | Use                                                  |
| --------------- | --------- | ---------------------------------------------------- |
| `state/success` | `#81B64C` | Win badge, "new record" badge (same as primary).     |
| `state/warning` | `#F7C948` | Non-blocking warnings (currently unused, reserved).  |
| `state/error`   | `#EB6150` | Error/conflict color (matches `board/conflict`).     |

## Semantic Tokens (how the app consumes colors)

Views never reference raw hex or the raw token names above. They consume semantic roles, resolved through a single `Theme` type in `QueensUI`. This keeps the door open for a light theme, seasonal themes, or accessibility variants later.

| Semantic role                | Resolves to            |
| ---------------------------- | ---------------------- |
| `theme.background`           | `surface/root`         |
| `theme.card`                 | `surface/elevated`     |
| `theme.cardInset`            | `surface/inset`        |
| `theme.divider`              | `surface/divider`      |
| `theme.textPrimary`          | `text/primary`         |
| `theme.textSecondary`        | `text/secondary`       |
| `theme.accent`               | `green/primary`        |
| `theme.accentPressed`        | `green/primaryDark`    |
| `theme.onAccent`             | `text/onAccent`        |
| `theme.boardLight`           | `board/lightSquare`    |
| `theme.boardDark`            | `board/darkSquare`     |
| `theme.boardHighlight`       | `board/highlight`      |
| `theme.conflictOnLight`      | `board/conflictDark`   |
| `theme.conflictOnDark`       | `board/conflict`       |
| `theme.winBadge`             | `state/success`        |

## Queen piece

- Queen glyph: SF Symbol `crown.fill` or `♛` character, rendered in `text/primary` (white) on both light and dark squares. This is slightly non-traditional (chess pieces are usually black on light / white on dark), but for a single-color-player puzzle a consistent white queen reads better and pops against both the cream light square and the green dark square.
- When in conflict: keep the queen white but tint the **cell** with the appropriate conflict color at ~60% opacity. Optionally pulse the queen glyph with `SymbolEffect` (iOS 18) — respect Reduce Motion and skip the pulse when it's enabled.

## Screens — applied

### HomeView

- Background: `theme.background` (`#312E2B`).
- Title: `text/primary`, large.
- Best-scores list: each row is `theme.cardInset` (`#262421`) with `theme.divider` between rows; numbers in `text/primary`, labels in `text/secondary`.
- Size picker: segmented / wheel on a `theme.card` surface.
- **New Game / Start** button: fill `theme.accent`, text `theme.onAccent`. Pressed state uses `theme.accentPressed`.

### GameView

- Background: `theme.background`.
- HUD pills (queens remaining, elapsed, moves): `theme.card` fill, `text/primary` values, `text/secondary` labels.
- Board frame: thin border in `theme.divider` around the grid.
- Board cells: alternate `theme.boardLight` / `theme.boardDark`.
- Valid queen placement: white queen glyph, no tint.
- Conflicting queen placement: cell background overlaid with `theme.conflictOnLight` (on cream squares) or `theme.conflictOnDark` (on green squares) at ~60% alpha.
- Tap feedback on empty cell: brief `theme.boardHighlight` pulse.
- Reset button: text button in `theme.accent`.

### Win overlay

- Scrim: `#000000` at 60% alpha over the board.
- Result card: `theme.card`, centered, with time + moves in `text/primary`.
- "New record!" badge: fill `theme.winBadge`, text `theme.onAccent`.
- "Back to Home" button: `theme.accent` fill.
- Confetti particles: draw in a mix of `green/primary`, `board/highlight`, `text/primary` (white), and `state/warning` (yellow) for variety.

## Light / Dark mode

The Chess.com look is fundamentally dark. V1 ships a single dark theme and does **not** adapt to the system `.light` color scheme. The `Theme` indirection is in place so we can add a light variant later without touching any view. Asset catalog color sets should be used where practical so that if we do add a light variant, the swap is a data change, not a code change.

## Accessibility

Non-negotiable even though it isn't in the original brief:

- **Contrast**: `text/primary` on `surface/root` is ~16:1 (easily AAA). `text/secondary` on `surface/root` is ~7:1 (AAA for normal text). Conflict overlays reduce board-cell contrast for the queen glyph only slightly; we keep the white queen for consistency.
- **Color is not the only signal**: conflict state is communicated by the cell color overlay *and* by a SymbolEffect pulse on the queen *and* by a VoiceOver label suffix ("...in conflict"). Never rely on color alone.
- **Reduce Motion**: skip the SymbolEffect pulse and the confetti animation; show a static "You won!" state instead.
- **Dynamic Type**: HUD text should use semantic font styles (`.title3`, `.caption`, etc.). Board cells render the queen with a fixed size relative to the cell.

## Implementation Notes for Claude Code

- Define colors in an **Asset Catalog** (`Colors.xcassets`) in `QueensUI`, one color set per raw token (e.g. `green-primary`, `board-light-square`). This enables dark/light variants later at zero code cost. Wire the catalog into the package target in `Package.swift`:

  ```swift
  .target(
      name: "QueensUI",
      dependencies: ["QueensCore"],
      resources: [.process("Resources/Colors.xcassets")]
  )
  ```

- Expose colors via a `Theme` struct that maps semantic names to `Color`. Views consume `theme.accent`, never `Color("green-primary")` directly.
- **`Theme` lives entirely in `QueensUI`**, including a default value (`Theme.chessDotCom`) surfaced through a SwiftUI `EnvironmentValues` key. Views read it with `@Environment(\.theme) var theme` and work out-of-the-box — the App target does **not** need to inject anything at the root. If a future consumer wants to override, it does so by wrapping the root with `.environment(\.theme, customTheme)`.
- Previews should render against `theme.background` to avoid a false sense of contrast on the default white canvas.

### App-target carveout: `AccentColor`

iOS reads the system accent color (used in notifications, Control Center tint, some system-provided UI chrome) from the `AccentColor` entry in the **main app bundle's** `Assets.xcassets`. Swift packages can't satisfy that requirement. So the App target duplicates the primary green into its own asset catalog:

- `App/Assets.xcassets/AccentColor` → `#81B64C` (mirrors `green/primary`).

This is the only color duplication we accept. Everything else lives in `QueensUI`.

Sources:
- [Chess.com color palette — color-hex.com](https://www.color-hex.com/color-palette/1043818)
- [Chess Board Logo Palette — colorshexa.com](https://colorshexa.com/palette/chess-board-logo)
- [Chess Board Color Palette — color-hex.com](https://www.color-hex.com/color-palette/8548)
