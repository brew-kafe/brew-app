//
//  TabBarView.swift
//  brew
//
//  Updated with AI Assistant integration
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var locationsViewModel: LocationsViewModel
    @EnvironmentObject private var reportViewModel: ReportViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    
    @State private var selectedTab = 0
    
    private let brewBrown = Color(red: 81/255, green: 57/255, blue: 29/255)
    private let brewGreen = Color(red: 76/255, green: 130/255, blue: 89/255)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .environmentObject(locationsViewModel)
                .tabItem {
                    Label("Tablero", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            // Map/Locations Tab
            LocationsView()
                .environmentObject(locationsViewModel)
                .tabItem {
                    Label("Parcelas", systemImage: "map.fill")
                }
                .tag(1)
            
            // AI Assistant Tab (NEW)
            BrewAssistantView()
                .environmentObject(languageManager)
                .tabItem {
                    Label("Asistente", systemImage: "leaf.fill")
                }
                .tag(2)
                .badge(hasUnreadMessages ? "!" : nil)
            
            // Reports Tab
            ReportsListView()
                .environmentObject(reportViewModel)
                .tabItem {
                    Label("Reportes", systemImage: "doc.text.fill")
                }
                .tag(3)
            
            // Profile/Settings Tab
            ProfileView()
                .environmentObject(languageManager)
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(brewBrown)
    }
    
    private var hasUnreadMessages: Bool {
        // Logic to check for unread assistant messages
        // Can be implemented based on notification preferences
        return false
    }
}

// MARK: - Supporting Views

struct ReportsListView: View {
    @EnvironmentObject var reportViewModel: ReportViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(reportViewModel.reports) { report in
                    ReportRow(report: report)
                }
            }
            .navigationTitle("Reportes")
        }
    }
}

struct ReportRow: View {
    let report: Report
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(report.code)
                .font(.headline)
            Text(report.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showLanguagePicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Idioma / Language") {
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack {
                            Text(languageManager.currentLanguage.icon)
                            Text(languageManager.currentLanguage.displayName)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Información") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Perfil")
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView()
                    .environmentObject(languageManager)
            }
        }
    }
}

struct LanguagePickerView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button {
                        languageManager.currentLanguage = language
                        dismiss()
                    } label: {
                        HStack {
                            Text(language.icon)
                                .font(.title2)
                            Text(language.displayName)
                                .foregroundColor(.primary)
                            Spacer()
                            if languageManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Idioma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(LocationsViewModel())
            .environmentObject(ReportViewModel())
            .environmentObject(LanguageManager.shared)
    }
}
