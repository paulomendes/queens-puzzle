# Queens Puzzle — Architecture

A SwiftUI iOS game for the N-Queens problem. The player picks a board size (4–10) and places queens so that none attack each other. This document is the source of truth for architectural decisions and conventions. Claude Code should read this before implementing or extending the app.

> **Upper bound rationale**: capped at 10 because tap targets on an 11×11+ grid on iPhone become too small to hit reliably. Raising the ceiling later is a one-line change in `BoardSize.maximum`, but also requires reconsidering touch ergonomics (e.g. pinch-to-zoom or a repositionable cursor).

## Platform & Constraints

- **Language / UI**: Swift, SwiftUI only. No UIKit in app code (system interop through SwiftUI-wrapped APIs only where strictly needed, e.g. haptics).
- **Minimum iOS**: 18.0. We rely on `@Observable`, `SymbolEffect`, and modern SwiftUI animation APIs.
- **Xcode**: 16 or newer.
- **No third-party dependencies** in the core or UI packages. If we ever introduce one (e.g. snapshot testing), it lives only in the app/test targets.
- **No game engine, no game loop, no SpriteKit.** This is a turn-based puzzle; mutations happen on tap. A timer drives elapsed-time updates via reducer actions.

## Project Structure

Two local Swift packages plus the app target:

```
QueensPuzzle/               # Xcode project root
├── Packages/
│   ├── QueensCore/         # Pure domain + logic. No SwiftUI, no UIKit.
│   └── QueensUI/           # SwiftUI views and the observable store. Depends on QueensCore.
└── App/                    # @main, DI composition root, concrete service impls, confetti.
```

Dependency direction is strict and one-way: **App → QueensUI → QueensCore**. If `import SwiftUI` ever appears in `QueensCore`, we've made a mistake. The package graph itself is part of the demonstrated architecture — it should be showable in the interview walkthrough.

### QueensCore responsibilities
- Domain value types (`BoardSize`, `Position`, `GameState`, `GameAction`, `GameStatus`).
- Rules engine (pure functions for conflict detection, win detection, optional solver).
- Reducer (pure `(inout State, Action) -> Void`).
- Service protocols (`Clock`, `HapticsService`, `SoundService`, `BestScoresRepository`).
- No side effects, no I/O, no UIKit, no SwiftUI.

### QueensUI responsibilities

**Pure SwiftUI views only.** Every exported view is a function of `data in → callbacks out`. Views must be fully constructible from values — not services, not repositories, not navigation containers — so they render in Xcode Previews without any App-level composition.

Concretely:
- Screens: `HomeView`, `GameView`.
- Board rendering: `BoardView`, `CellView`, `QueenView`.
- HUD components: size picker, timer display, move counter, queens-left indicator.
- **Design system**: `Colors.xcassets`, `Theme` struct, and the `EnvironmentValues` key for `\.theme`. The default theme is shipped from here so views work in previews without App-level setup. See `DESIGN.md` for the palette.
- Depends only on `QueensCore` (for value types like `BoardSize`, `Position`).

Explicit non-goals for QueensUI:
- **No `NavigationStack` / `NavigationPath` / `navigationDestination`.** Views expose intent through callbacks (e.g. `onStartGame: (BoardSize) -> Void`); the App target owns the stack and decides what the callback means.
- **No repository or service references.** Views take plain data (values, closures) for best times/moves/etc. They don't know `BestScoresRepository` exists.
- **No store/reducer ownership.** The `GameStore` (wiring reducer + services) lives in the App target; views read state it passes in and fire intent callbacks.
- **No `@main`, no concrete services, no persistence.**

### App target responsibilities
- `@main` app struct.
- **Root navigation**: `NavigationStack` + `NavigationPath` + `navigationDestination(for: BoardSize.self)` that constructs `GameView`. Views from `QueensUI` are composed here; they don't wrap themselves.
- **`GameStore`** (the `@Observable` class that wraps the reducer and owns side-effecting services). Lives here because it references services; the reducer it wraps still lives in `QueensCore` and stays pure.
- Concrete service implementations: `SystemClock`, `SystemHapticsService`, `SystemSoundService`, `UserDefaultsBestScoresRepository`, and `InMemoryBestScoresRepository` (useful as a default and for previews/tests).
- Dependency injection wiring (composition root).
- **`AccentColor`** asset in the app's `Assets.xcassets`, mirroring `green/primary` (`#81B64C`). iOS reads the system accent from the main bundle; packages can't satisfy this, so this is the one color we duplicate outside `QueensUI`.
- App icon and launch screen.

Suggested App-target folder layout (file-system-synchronized group, no `project.pbxproj` edits needed):

```
QueensPuzzle/QueensPuzzle/
├── QueensPuzzleApp.swift         # @main, hands off to RootNavigation
├── Navigation/
│   └── RootNavigation.swift      # NavigationStack + destinations + callback wiring
├── Scores/
│   ├── InMemoryBestScoresRepository.swift
│   └── UserDefaultsBestScoresRepository.swift  # added later
├── Store/
│   └── GameStore.swift           # added when reducer is wired
└── Services/                     # SystemClock, SystemHapticsService, SystemSoundService
```

## The Reducer Pattern (short explainer)

The idea is to make state changes boring and testable by funneling them through one pure function:

```swift
func reduce(_ state: inout GameState, _ action: GameAction)
```

All mutations happen there. Views never mutate state directly — they call `store.send(.tap(position))`, which runs the reducer. Tests are then trivial: construct an input state, call `reduce`, assert the output state with `XCTAssertEqual`. No mocks, no async, no UI involved. Side effects (haptics, sound, timer, persistence) are handled by the `GameStore` *after* running the reducer, not inside it.

If this scales up later we can introduce explicit `Effect` return values from the reducer, but for the scope of this app we will keep side effects in the store.

## Domain Model (QueensCore)

```swift
public struct BoardSize: Equatable, Hashable, Codable {
    public let n: Int                 // valid range: 4...10
    public init?(_ n: Int)            // returns nil if out of range
    public static let minimum = 4
    public static let maximum = 10
}

public struct Position: Equatable, Hashable, Codable {
    public let row: Int
    public let col: Int
}

public enum GameStatus: Equatable {
    case playing
    case won
}

public struct GameState: Equatable {
    public var size: BoardSize
    public var placements: Set<Position>
    public var conflicts: Set<Position>   // derived — recomputed in reduce; never set by callers
    public var moveCount: Int
    public var elapsed: TimeInterval
    public var status: GameStatus

    public var queensRemaining: Int { size.n - placements.count }
}

public enum GameAction: Equatable {
    case tap(Position)
    case tick(TimeInterval)    // delta seconds
    case reset
    case newGame(BoardSize)
}
```

`placements` is a `Set` because queen placement is orderless and tap semantics (toggle membership) map directly onto set operations. `conflicts` is stored in state as a derived cache so the view can render conflict styling without re-running the rules engine every render pass, but the *only* place that writes `conflicts` is the reducer.

## Rules Engine (QueensCore)

Pure, stateless functions:

```swift
public enum Rules {
    /// Returns the subset of positions that are in conflict with at least one other.
    public static func conflicts(in placements: Set<Position>) -> Set<Position>

    /// True iff `placements.count == size.n` AND conflicts is empty.
    public static func isSolved(placements: Set<Position>, size: BoardSize) -> Bool

    /// Optional: backtracking solver. Used as a test oracle and possibly a future hint feature.
    public static func solve(size: BoardSize) -> Set<Position>?
}
```

Conflict detection is O(k²) in the number of placed queens (k ≤ 10 → at most 100 pair checks). No need for clever data structures.

## Reducer (QueensCore)

```swift
public func reduce(_ state: inout GameState, _ action: GameAction)
```

Behavior, per action:

- **`.tap(p)`** — No-op if `status == .won`. Otherwise toggle `p` in `placements`, increment `moveCount`, recompute `conflicts`, set `status = .won` if `Rules.isSolved` holds.
- **`.tick(dt)`** — Adds `dt` to `elapsed` only while `status == .playing`. No-op otherwise.
- **`.reset`** — Clears placements, conflicts, moveCount, elapsed. Preserves `size`. Sets `status = .playing`.
- **`.newGame(size)`** — Same as `.reset` but also replaces `size`.

The reducer never returns early without a well-defined state. It is exhaustively pattern-matched on `GameAction`.

## Store (App target)

```swift
@Observable
public final class GameStore {
    public private(set) var state: GameState

    public init(
        initial: GameState,
        clock: Clock,
        haptics: HapticsService,
        sound: SoundService,
        scores: BestScoresRepository
    )

    public func send(_ action: GameAction)
}
```

`send` runs the reducer, then dispatches side effects based on the transition:

- On a placement toggle → fire a light haptic and place/remove SFX.
- On a placement that creates new conflicts → fire a warning haptic.
- On the transition into `.won` → stop the timer task, record the run via `scores.record(...)` if it beats existing best time/moves, fire celebration SFX.
- On `.newGame` or `.reset` → start/restart the timer task.

The timer is a single `Task` held by the store that awaits a stream from `Clock` and calls `send(.tick(dt))`. Cancelled on `.won`, on deinit, and when restarted.

The store is the only layer that knows services exist. Views must not import or reference service types.

## Services (protocols in QueensCore, implementations in App)

```swift
public protocol Clock {
    /// Emits `dt` (seconds since last tick) on a target cadence until the caller cancels.
    func ticks(interval: TimeInterval) -> AsyncStream<TimeInterval>
}

public enum HapticEvent {
    case placeQueen, removeQueen, conflict, win
}
public protocol HapticsService {
    func play(_ event: HapticEvent)
}

public enum SoundEffect {
    case placeQueen, removeQueen, conflict, win
}
public protocol SoundService {
    func play(_ effect: SoundEffect)
}

public protocol BestScoresRepository {
    func bestTime(for size: BoardSize) -> TimeInterval?
    func bestMoves(for size: BoardSize) -> Int?
    func record(time: TimeInterval, moves: Int, size: BoardSize)
}
```

**Implementations (in App target):**
- `SystemClock` — wraps `Task.sleep` or `ContinuousClock`.
- `SystemHapticsService` — `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator` (SwiftUI-wrapped). Consider Core Haptics for the win event if budget allows.
- `SystemSoundService` — AudioToolbox's `AudioServicesPlaySystemSound`. Each `SoundEffect` maps to a `.wav` in the app bundle (`add`, `remove`, `conflict`, `won`); IDs are registered once at init via `AudioServicesCreateSystemSoundID` and disposed on deinit. Picked over `AVAudioPlayer` because the cues are short, fire-and-forget effects — no player lifecycle to manage, no need to size buffers. The trade-off is that system sounds follow the **ringer** volume rather than media volume, which is actually desirable here (move-piece SFX should not blast at music volume).
- `UserDefaultsBestScoresRepository` — see Persistence section.

Test targets provide fakes (`FakeClock`, `SpyHaptics`, etc.) that capture events for assertions.

## UI Flow

Two screens. No separate "win screen" — the win state is an overlay on the game screen.

### HomeView (entry)

- App title / branding.
- **Best scores table**: one row per `n` in the full 4...10 range, showing best time (formatted `m:ss`) and best move count in two columns side-by-side. Missing values render as `-`. No separate tabs — the table is small enough to fit both metrics on screen at once.
- **New Game** button + inline size picker (SwiftUI `Picker` with `n = 4...10`, default 8). Tapping Start fires an `onStartGame: (BoardSize) -> Void` callback; the App's `RootNavigation` pushes `GameView(size:)` onto the stack.
- HomeView receives `bestTime: (BoardSize) -> TimeInterval?` and `bestMoves: (BoardSize) -> Int?` closures — it never sees the repository.

### GameView

- `BoardView` — NxN grid of flexible `Rectangle`s inside a VStack of HStacks, wrapped in `.aspectRatio(1, contentMode: .fit)`. No `GeometryReader`.
- HUD at the top: queens remaining, elapsed time, move count.
- Bottom bar: Abort (secondary) and Reset (primary). Abort fires `onAbort: () -> Void`; Reset fires `onReset: () -> Void`. The App wires Abort to pop the nav stack and Reset to dispatch to the store.
- Taps on cells fire `onTap: (Position) -> Void` (wired when the reducer/store lands; App sends `.tap` to the store).
- Conflicting queens highlighted (red tint + subtle `SymbolEffect` pulse on the queen glyph).
- **Win overlay**: when `state.status == .won`, a dimming overlay appears with the final time, move count, a "New best…" badge if applicable, and two buttons — **Retry** (restart the same board size) and **Leave** (return to home). Wired through `onRetry` / `onLeave` callbacks; the App target dispatches retry to the store and pops the nav stack on leave. The celebration is the `SoundEffect.win` cue plus the win haptic, fired by the store on the `playing → won` transition — there is no overlaid animation (see Celebration).

### Navigation

`NavigationStack` rooted at the App target's `RootNavigation` view, with `HomeView` as the root content and `GameView` registered via `navigationDestination(for: BoardSize.self)`. The views themselves never touch `NavigationStack`, `NavigationPath`, or `navigationDestination`.

## Celebration

**No confetti, no particle effects.** The win celebration is two cues fired by `GameStore` on the `playing → won` transition: `SoundEffect.win` (a short jingle in `won.wav`, played through `SystemSoundService`) and `HapticEvent.win`. Combined with the win overlay, that's the entire celebration.

This is a deliberate scope cut from the original plan, which had a `ConfettiView` (SwiftUI `Canvas` + `TimelineView`) injected into `GameView` via a view-builder generic:

```swift
// Original plan — not built:
public struct GameView<Celebration: View>: View {
    let celebration: (Bool) -> Celebration
}
```

The reasoning for dropping it:

- A short SFX + haptic on a one-off win event lands as well as confetti and is significantly less code to get right (Reduce Motion handling, particle perf, layering with the overlay, etc.).
- Removing the generic also removes a real ergonomic cost — `GameView<EmptyView>` is awkward in previews, snapshot tests, and call sites that don't care about celebration.
- The seam still exists: a future visual celebration can re-introduce the view-builder parameter without touching the reducer or the store. The win cue stays as the audio/haptic layer regardless.

The shipped `GameView` therefore takes plain callbacks (`onTap`, `onReset`, `onAbort`, `onRetry`, `onLeave`) and no celebration generic.

## Persistence

`UserDefaultsBestScoresRepository` only. One key per record, namespaced:

```
queens.bestTime.<n>    // Double, seconds
queens.bestMoves.<n>   // Int
```

No resume-in-progress. No iCloud. No schema migration. If we outgrow this, we wrap in a versioned `Codable` blob and stop splitting by key.

## Testing Strategy

Target ~95% line coverage on `QueensCore`. UI/integration coverage is lighter but present.

### QueensCore tests

- **RulesTests**
  - Exhaustive for n = 4, 5, 6: enumerate the known valid configurations, assert `isSolved` is true for each; assert `conflicts` is empty.
  - Crafted conflict cases: same row, same column, `/` diagonal, `\` diagonal, mixed. Assert the expected subset is flagged.
  - Negative cases: too few queens (never solved), too many queens, empty board.
- **ReducerTests** — one test per action case, plus:
  - Tap on a won board is a no-op.
  - Tap on occupied cell removes the queen and decrements-ish correctly (moveCount still increments — every tap is a "move").
  - `.newGame` resets timer, moves, placements, conflicts and updates size.
  - `.tick` only advances `elapsed` when `status == .playing`.
- **SolverTests** (if implemented) — for each n in 4...10, solver returns a placement; `Rules.isSolved` agrees.

### QueensUI / App tests

- **GameStoreTests** — with `FakeClock`, `InMemoryBestScoresRepository`, `SpyHaptics`, `SpySound`:
  - Timer advances `elapsed` on tick.
  - On win, record is written iff it beats the existing best time OR best moves (record both independently).
  - On reset, no record is written.
  - Haptic/sound events fire on the right transitions.
- **Snapshot tests** on `BoardView` (optional): empty, partial, conflict, solved. Only if we're willing to add `pointfreeco/swift-snapshot-testing` to the test target.
- **One XCUITest** golden path: launch → start 4×4 game → solve → see win overlay → back to home → new best scores visible.

## Extension Points

Designed-in seams. When the interview follow-up extends the app, reach for one of these:

- **New action**: add a case to `GameAction`, a branch to the reducer, tests. Example: `.undo`, `.hint`, `.clearRow(Int)`.
- **New rule**: add a pure function to `Rules`, compose into the validator. Example: "no knight-move conflict" variant.
- **New service**: define a protocol in `QueensCore`, implement in App, inject into `GameStore`. Example: `LeaderboardService`, `AnalyticsService`.
- **Theme**: introduce a `Theme` environment value consumed by `CellView` / `QueenView`; swap at runtime for skinning.

## Non-Goals (explicit — do not build in v1)

- No resume-in-progress. Closing the app mid-puzzle loses state.
- No iCloud / Game Center sync.
- No online multiplayer.
- No custom piece types or alternative board topologies.
- No in-app hint UI (solver may exist internally as a test oracle).
- No analytics.
- No localization beyond English. Strings should still go through `String(localized:)` so adding locales later is cheap.

## Accessibility

Accessibility is a first-class requirement even though it's not in the original brief.

- **Algebraic chess notation for cells**, not "Row X, column Y." Each `Position` exposes `.algebraic(boardSize:)` (defined in `QueensCore`), which produces strings like `a1`, `e4`, `h8`. `CellView` uses this string for both `accessibilityLabel` and `accessibilityIdentifier`. Two reasons:
  - It matches how chess players actually talk about a board, so VoiceOver users get a precise, familiar coordinate system instead of a generic grid description.
  - Reusing the same string as the accessibility identifier means UI tests can drive the board with `app.buttons["b4"].tap()` and stay in sync with VoiceOver labels — if one breaks, both do.
- **HUD elements** have their own labels (queens remaining, elapsed time, move count) defined in localized strings.
- **Dynamic Type** on the HUD is partial — at the largest accessibility sizes some elements clip depending on orientation. A production version would either reflow or scope which elements scale.

## Open Notes

- If Core Haptics turns out to be worth it for the win event, keep `HapticsService` as-is but branch inside `SystemHapticsService` based on the event. Don't leak the distinction into `QueensCore`.
