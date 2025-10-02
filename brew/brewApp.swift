//
//  brewApp.swift
//  brew
//
//  Created by toño on 02/09/25.
//

import SwiftUI

@main
struct brewApp: App {
    
    @StateObject private var vm = LocationsViewModel()
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .modelContainer(dataController.container)
        }
    }
}
