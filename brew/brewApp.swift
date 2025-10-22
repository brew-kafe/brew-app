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
    @StateObject private var locationsViewModel = LocationsViewModel()
    @StateObject private var reportViewModel = ReportViewModel()
    @StateObject private var dataController = DataController()
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                Group {
                    if let user = authVM.currentUser {
                        // Mostrar el TabBar según el rol del usuario
                        if user.role.lowercased() == "admin" || user.role.lowercased() == "administrador" {
                            TabBarViewAdmin()
                                .environmentObject(authVM)
                                .environmentObject(locationsViewModel)
                                .environmentObject(reportViewModel)
                        } else {
                            // Por defecto mostrar TabBar técnico
                            TabBarView()
                                .environmentObject(authVM)
                                .environmentObject(locationsViewModel)
                                .environmentObject(reportViewModel)
                        }
                    } else {
                        // Fallback a TabBar técnico si no hay usuario
                        TabBarView()
                            .environmentObject(authVM)
                            .environmentObject(locationsViewModel)
                            .environmentObject(reportViewModel)
                    }
                }
                .modelContainer(dataController.container)
            } else {
                LoginView(authVM: authVM)
            }
        }
        .environmentObject(languageManager)
    }
}


