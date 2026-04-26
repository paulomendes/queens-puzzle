//
//  QueensPuzzleUITests.swift
//  QueensPuzzleUITests
//
//  Created by Paulo Mendes on 24/04/26.
//

import XCTest

@MainActor
final class QueensPuzzleUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += [LaunchArguments.inMemoryScores]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSolve4x4() throws {
        startNewPuzzle(size: 4)

        // One of the two 4-queens solutions.
        tapCell("b4")
        tapCell("d3")
        tapCell("a2")
        tapCell("c1")

        let winTitle = app.staticTexts["You won!"]
        XCTAssertTrue(winTitle.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Time"].exists)
        XCTAssertTrue(app.staticTexts["Moves"].exists)
        // The in-memory repo starts empty, so a clean solve sets both bests.
        XCTAssertTrue(app.staticTexts["New best time and move count!"].exists)
        XCTAssertTrue(app.buttons["Retry"].exists)

        app.buttons["Leave"].tap()
        XCTAssertTrue(app.buttons["Start New Puzzle"].waitForExistence(timeout: 2))
    }

    private func startNewPuzzle(size: Int) {
        app.buttons["Size, Board size"].firstMatch.tap()
        app.buttons["\(size)"].firstMatch.tap()
        app.buttons["Start New Puzzle"].tap()
    }

    private func tapCell(_ algebraic: String) {
        app.buttons[algebraic].tap()
    }
}
