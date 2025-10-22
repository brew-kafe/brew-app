//
//  TabBarViewAdmin.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//

import SwiftUI

struct TabBarViewAdmin: View {
    @EnvironmentObject private var locationsViewModel: LocationsViewModel
    @EnvironmentObject private var reportsViewModel: ReportViewModel
    
    init() {
        // Set the background color of the tab bar using a custom UIColor from hex
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#403003")
        
        //Appearance of tab bar on scrollable and non-scrollable views
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        //Change color of unselected icon color and text
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: "#E3DBC7")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "#E3DBC7")]
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeViewAdmin()
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }
            
            NavigationStack {
                ReportsView()
            }
            .tabItem { Label("Reporte", systemImage: "doc.text.fill")}

            NavigationStack {
                AdminDashboardView()
            }
            .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }

            NavigationStack {
                LocationsView()
                    .environmentObject(locationsViewModel)
            }
            .tabItem { Label("Mapa", systemImage: "map.fill") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .tint(Color(hex: "#737839"))
    }
}

// Note: Color extensions moved to ColorExtensions.swift

#Preview {
    TabBarViewAdmin()
        .environmentObject(LocationsViewModel())
        .environmentObject(ReportViewModel())
}


