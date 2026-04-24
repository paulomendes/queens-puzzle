# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

iOS SwiftUI game for the N-Queens puzzle, built as a take-home exercise. The problem brief is in `queens-puzzle-ask.txt`. **`ARCHITECTURE.md` is the source of truth for architectural decisions — read it before implementing or extending anything.** It defines the package layout, reducer pattern, domain model, services, testing strategy, and explicit non-goals.

## Current state

Freshly-generated Xcode 26 scaffold — `QueensPuzzle/QueensPuzzle/ContentView.swift` is still the default "Hello, world!" template. None of the architecture described in `ARCHITECTURE.md` has been implemented yet: there is no `Packages/QueensCore`, no `Packages/QueensUI`, no reducer, no board. When asked to build a feature, assume you are starting from the scaffold and following the plan in `ARCHITECTURE.md`.

## Repository layout quirk

Two git repos exist: the outer `queens-puzzle/` repo and an inner `QueensPuzzle/` repo (Xcode created its own). Work happens in the inner repo; the outer one tracks docs/brief. Don't `git init` or restructure without asking.

## Build, run, test

Work from `QueensPuzzle/` (the Xcode project root):

```bash
cd QueensPuzzle

# Build for simulator
xcodebuild -project QueensPuzzle.xcodeproj -scheme QueensPuzzle \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run all tests (unit + UI)
xcodebuild -project QueensPuzzle.xcodeproj -scheme QueensPuzzle \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Run a single unit test (Swift Testing uses -only-testing with the test identifier)
xcodebuild -project QueensPuzzle.xcodeproj -scheme QueensPuzzle \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test \
  -only-testing:QueensPuzzleTests/QueensPuzzleTests/example
```

The `QueensPuzzle` scheme is user-local (not shared). If CI needs it, share it via Xcode → Product → Scheme → Manage Schemes.

## Testing frameworks — mixed on purpose

- `QueensPuzzleTests/` uses **Swift Testing** (`import Testing`, `@Test`, `#expect`). This is where the core logic / reducer / rules tests belong.
- `QueensPuzzleUITests/` uses **XCTest** with `XCUIApplication`. Keep it that way — XCUITest is still XCTest-based.

Don't mix the two frameworks inside a single target.

## File-system-synchronized groups

The Xcode project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16+). **Adding a `.swift` file under `QueensPuzzle/QueensPuzzle/`, `QueensPuzzleTests/`, or `QueensPuzzleUITests/` automatically includes it in the matching target — no `project.pbxproj` edits needed.** This does NOT extend to new Swift packages: `Packages/QueensCore` and `Packages/QueensUI` (per `ARCHITECTURE.md`) will need to be added as local package references in the project, which *does* require an Xcode/pbxproj change.

## Architectural guardrails (from ARCHITECTURE.md)

A few rules that are easy to break and expensive to unwind — read the full doc for the rest:

- **Dependency direction is one-way: App → QueensUI → QueensCore.** If `import SwiftUI` ever appears in `QueensCore`, something is wrong.
- **All state mutations go through the pure reducer** `reduce(_ state: inout GameState, _ action: GameAction)`. Views call `store.send(action)`; they never mutate state directly.
- **Side effects (haptics, sound, timer, persistence) live in `GameStore`, not in the reducer.** Service protocols are defined in `QueensCore`; implementations live in the App target and are injected.
- **Confetti/celebration lives in the App target**, injected into `GameView` via a view-builder parameter. `QueensUI` does not know what celebration looks like.
- **No third-party dependencies** in the core or UI packages. Snapshot-testing libs (if added) live only in test targets.
- **`conflicts` in `GameState` is derived cache** — only the reducer writes it.

## Project settings to be aware of

- Deployment target: iOS 26.4 (despite `ARCHITECTURE.md` saying 18.0 — the scaffold was created on newer Xcode; align with whatever the user decides).
- Swift 5.0, Xcode 26.4.
- Bundle id: `lilystar.QueensPuzzle`.
