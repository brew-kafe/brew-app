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
    
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var dataController = DataController()
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                ContentView()
                    .environmentObject(authVM)
                    .modelContainer(dataController.container)
            } else {
                LoginView(authVM: authVM)
            }
        }
        .environmentObject(languageManager)
    }
}
