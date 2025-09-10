//
//  ContentView.swift
//  brew
//
//  Created by toño on 02/09/25.
//

import SwiftUI

struct ContentView: View {
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
    ContentView()
    
}
