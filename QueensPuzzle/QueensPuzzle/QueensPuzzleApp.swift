//
//  QueensPuzzleApp.swift
//  QueensPuzzle
//
//  Created by Paulo Mendes on 24/04/26.
//

import SwiftUI

@main
struct QueensPuzzleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootNavigation()
        }
    }
}
