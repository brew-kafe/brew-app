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
                FAQView()
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

//Convert hex string to UIColor
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(rgb & 0x0000FF) / 255,
                  alpha: 1)
    }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

#Preview {
    TabBarView()
        .environmentObject(LocationsViewModel())
}
