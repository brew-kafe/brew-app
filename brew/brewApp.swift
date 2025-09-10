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
    
    var body: some Scene {
        WindowGroup {
            LocationsView()
                .environmentObject(vm)
        }
    }
}
