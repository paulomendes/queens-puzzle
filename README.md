# Queens Puzzle

An iOS SwiftUI implementation of the N-Queens puzzle. Pick a board size (4–10), tap to place queens, and try to fill the board so that no two queens attack each other.

## Build

The Xcode project lives in `QueensPuzzle/`. Open and build from there:

```bash
cd QueensPuzzle
xcodebuild -project QueensPuzzle.xcodeproj -scheme QueensPuzzle \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Or open `QueensPuzzle.xcworkspace` in Xcode 26+ and build with `⌘B`.

Requirements: Xcode 26.4+, iOS 26.4 simulator or device. No third-party dependencies.

## Run

In Xcode, select the `QueensPuzzle` scheme and a simulator (iPhone 17 Pro and iPad Pro 13" M5 are the canonical targets), then `⌘R`.

## Test

The project has two test targets:

- `QueensPuzzleTests` — Swift Testing (`@Test`, `#expect`). Covers the rules engine, reducer, store, and UI snapshots.
- `QueensPuzzleUITests` — XCTest + `XCUIApplication` for the end-to-end golden path.

Run everything from the command line:

```bash
cd QueensPuzzle
xcodebuild -project QueensPuzzle.xcodeproj -scheme QueensPuzzle \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Or `⌘U` in Xcode.

---

## Architecture

The app is split into two local Swift packages plus the App target. Dependencies flow strictly one way: **App → QueensUI → QueensCore**.

```
QueensPuzzle/
├── Packages/
│   ├── QueensCore/   # Pure domain + logic. No SwiftUI.
│   └── QueensUI/     # SwiftUI views. Depends only on QueensCore.
└── QueensPuzzle/     # App target. Composition root, services, navigation.
```

`ARCHITECTURE.md` is the source of truth for the decisions below — this section is the high-level tour.

### 1. Game logic is fully independent from the view layer

`QueensCore` knows nothing about SwiftUI. To keep that boundary lean but expressive, the core is built around a **reducer**:

```swift
func reduce(_ state: inout GameState, _ action: GameAction)
```

All mutations funnel through this single pure function. Views call `store.send(.tap(position))`; they never write to state directly.

**Why a reducer:**

- It captures the game state as a single, explicit value — no scattered mutability.
- Every state transition is an `Action`, so the legal vocabulary of the game (tap, reset, new game, tick, won) is visible at a glance and easy to extend.
- Adding a new interaction means one new case and one new branch — both with focused tests.
- `GameState` is `Equatable` and trivially serializable, so save-game, share-state, or basic multiplayer become natural extensions rather than rewrites.

**Trade-off:**

- The reducer is shaped specifically for the N-Queens problem. Generalising to other constraint-satisfaction puzzles (N-rooks, bishops, knights) would mean revisiting `Rules` and introducing a `Problem` abstraction layer over CSPs. That's a deliberate non-goal for v1 — paying for it up front would be premature.

### 2. The UI

`QueensUI` is **pure SwiftUI** and knows nothing about navigation or game logic. It is, however, deliberately purpose-built for the N-Queens problem — it is not a generic chess UI kit.

Every exported view is a function of `data in → callbacks out`. Views take values (state, theme, closures) and emit intent. They never reference services, repositories, or the navigation stack, which means they render in Xcode Previews with no app-level setup and stay fully decoupled from the App's composition.

The UI is **fully compatible with iPad** as well as iPhone, and supports both portrait and landscape orientations. Layouts adapt to the available space rather than assuming a fixed phone-sized canvas.

### 3. The App

The App target is where composition happens — it wires `QueensUI` to the game logic in `QueensCore`.

- **`GameStore`** is the driver. It receives intents from the UI, runs them through the reducer, and publishes the new state back to the views. SwiftUI's diffing means only the affected leaves re-render on each transition, so even larger boards stay smooth.
- **Device-specific effects** (haptics, sound, timer, persistence) live here, behind protocols defined in `QueensCore`. The reducer itself stays pure.
- **Sound** uses `AudioServicesPlaySystemSound` rather than `AVAudioPlayer`. This API is purpose-built for short system-style cues (placing a piece, tapping a cell), it's cheap, and it doesn't require constructing and managing a player just to fire a quick effect. The one trade-off worth calling out: system sounds follow the **ringer** volume, not the media volume. That's actually desirable here — you don't want move-piece sounds blasting at music volume — but it's a deliberate choice, not an oversight.

### 4. Accessibility

Full VoiceOver support, with each cell announced using **algebraic chess notation** (`a1`, `b3`, etc.). It keeps the experience close to how chess players actually talk about a board, and gives non-sighted users a precise, familiar coordinate system instead of generic "row 3, column 5" labels.

### 5. Compromises

A few deliberate trade-offs given the scope of the exercise:

- **Conflict detection** is a straightforward O(k²) pair check. With k ≤ 10 queens there are at most 100 comparisons, so a smarter row/column/diagonal index wasn't worth the extra code.
- **Board size is capped at 10.** Beyond that, tap targets on iPhone become uncomfortably small. Raising the ceiling is a one-line change in `BoardSize.maximum`, but it would also need touch-ergonomic work (zoom, draggable cursor) to be usable.
- **Dynamic Type support is partial.** At the largest accessibility sizes, depending on orientation, some HUD elements can clip. A production version would either reflow the HUD or scope which elements scale.
