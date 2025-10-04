//
//  TabBarView.swift
//  brew
//
//  Created by Regina Romero on 9/10/25.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var vm: LocationsViewModel
    
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
                HomeView()
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }

            NavigationStack {
                DiagnosticView()
            }
            .tabItem { Label("Diagnóstico", systemImage: "leaf.fill") }

            NavigationStack {
                LocationsView()
                    .environmentObject(vm)
            }
            .tabItem { Label("Mapa", systemImage: "map.fill") }

            NavigationStack {
                DashboardView()
                    .environmentObject(vm)
            }
            .tabItem { Label("Tablero", systemImage: "chart.bar.xaxis.ascending") }
        }
        .tint(Color(hex: "#737839"))
    }
}

// Note: Color extensions moved to ColorExtensions.swift

#Preview {
    TabBarView()
        .environmentObject(LocationsViewModel())
}
