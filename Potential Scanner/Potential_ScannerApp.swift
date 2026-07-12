//
//  Potential_ScannerApp.swift
//  Potential Scanner
//
//  Created by yowenomo on 7/12/26.
//

import SwiftUI
import SwiftData

@main
struct Potential_ScannerApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ScanCard.self)
    }
}
