//
//  TabBarView.swift
//  brew
//
//  Created by Regina Romero on 9/10/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
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
    }
}


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

#Preview {
    TabBarView()
}
