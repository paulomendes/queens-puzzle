//
//  QueensPuzzleApp.swift
//  QueensPuzzle
//
//  Created by Paulo Mendes on 24/04/26.
//

import QueensCore
import SwiftUI

@main
struct QueensPuzzleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let scoresRepository: BestScoresRepository

    init() {
        if LaunchArguments.hasInMemoryScores {
            scoresRepository = InMemoryBestScoresRepository()
        } else {
            scoresRepository = UserDefaultsBestScoreRepository(userDefaults: .standard)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootNavigation(scores: scoresRepository)
        }
    }
}
