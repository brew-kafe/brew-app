//
//  TabBarView.swift
//  brew
//
//  Created by Regina Romero on 9/10/25.
//

import SwiftUI

struct TabItem: Identifiable, Hashable {
    let id: String
    let title: String
    let sf: String
    let view: AnyView
}

func tabs(for role: UserRole) -> [TabItem] {
    switch role {
    case .admin:
        return [
            .init(id:"homeAdmin",  title:"Inicio",    sf:"house.fill",
                  view: AnyView(HomeViewAdmin())),
            .init(id:"report",     title:"Reporte",   sf:"doc.text.fill",
                  view: AnyView(ReportsView())),
            .init(id:"dashboard",  title:"Dashboard", sf:"rectangle.grid.2x2",
                  view: AnyView(AdminDashboardView())),
            .init(id:"map",        title:"Mapa",      sf:"map.fill",
                  view: AnyView(LocationsView())),
            .init(id:"settings",   title:"Ajustes",   sf:"gearshape",
                  view: AnyView(SettingsView()))
        ]
    case .technician:
        return [
            .init(id:"home",       title:"Inicio",    sf:"house.fill",
                  view: AnyView(HomeView())),
            .init(id:"report",     title:"Reporte",   sf:"doc.text.fill",
                  view: AnyView(ReportsView())),
            .init(id:"diagnostic", title:"Diagnóstico", sf:"leaf.fill",
                  view: AnyView(DiagnosticView())),
            .init(id:"map",        title:"Mapa",      sf:"map.fill",
                  view: AnyView(LocationsView())),
            .init(id:"settings",   title:"Ajustes",   sf:"gearshape",
                  view: AnyView(SettingsView()))
        ]
    }
}

struct TabBarView: View {
    @EnvironmentObject private var locationsViewModel: LocationsViewModel
    @EnvironmentObject private var reportsViewModel: ReportViewModel
    @EnvironmentObject private var session: Session

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#403003")
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: "#E3DBC7")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "#E3DBC7")]
    }

    var body: some View {
        let items = tabs(for: session.role)
        TabView(selection: $session.selectedTab) {
            ForEach(items) { item in
                NavigationStack {
                    item.view
                        .environmentObject(locationsViewModel)
                        .environmentObject(reportsViewModel)
                }
                .tabItem { Label(item.title, systemImage: item.sf) }
                .tag(item.id)
            }
        }
        .tint(Color(hex: "#737839"))
        .onAppear {
            if !items.map(\.id).contains(session.selectedTab) {
                session.selectedTab = items.first?.id ?? "home"
            }
        }
    }
}


#Preview {
    TabBarView()
        .environmentObject(LocationsViewModel())
}
