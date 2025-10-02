//
//  brewApp.swift
//  brew
//
//  Created by toño on 02/09/25.
//

import SwiftUI
import SwiftData

@main
struct brewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Activity.self)
    }
}
