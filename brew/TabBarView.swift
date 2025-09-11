//
//  TabBarView.swift
//  brew
//
//  Created by Regina Romero on 9/10/25.
//

import SwiftUI

struct TabBarView: View {
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
        //Creation of tab bar with Home, Diagnostic, Map and Dashboard icons + navigation
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }

            NavigationView {
                DiagnosticView()
            }
            .tabItem {
                Label("Diagnostico", systemImage: "leaf.fill")
            }

            NavigationView {
                MapView()
            }
            .tabItem {
                Label("Mapa", systemImage: "map.fill")
            }

            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Tablero", systemImage: "chart.bar.xaxis.ascending")
            }
        }
        //Change color of highlighted icon
        .tint(Color(hex: "#737839"))
    }
}

//Dummy views to test navigation
struct HomeView: View {
    var body: some View {
        Text("Diagnostico")
            .navigationTitle("Diagnostico")
    }
}

struct DiagnosticView: View {
    var body: some View {
        Text("Diagnostico")
            .navigationTitle("Diagnostico")
    }
}

struct MapView: View {
    var body: some View {
        Text("Mapa")
            .navigationTitle("Mapa")
    }
}

struct DashboardView: View {
    var body: some View {
        Text("Tablero")
            .navigationTitle("Tablero")
    }
}

//Convert hex string to UIColor
extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        //Converts the string "9B8F7C" into a numeric RGB value
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
//In order to use hex colors in SwiftUI
extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

#Preview {
    TabBarView()
}
