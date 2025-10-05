//
//  ContentView.swift
//  brew
//
//  Created by toño on 02/09/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationsViewModel = LocationsViewModel()
    @StateObject private var reportViewModel = ReportViewModel()
    
    var body: some View {
        TabBarView()
            .environmentObject(locationsViewModel)
            .environmentObject(reportViewModel)
    }
}

// MARK: - Enhanced DashboardView with data integration
struct DashboardView: View {
    @EnvironmentObject private var vm: LocationsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dashboard Header¨_
                HStack {
                    Text("Tablero de Control")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Overview Cards Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    // Total Locations Card
                    DashboardCard(
                        title: "Total Parcelas",
                        value: "\(vm.locations.count)",
                        icon: "map.fill",
                        color: .blue
                    )
                    
                    // Safe Locations
                    DashboardCard(
                        title: "Parcelas Sanas",
                        value: "\(vm.locations.filter { $0.kind == .safe }.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    // Risk Locations
                    DashboardCard(
                        title: "En Riesgo",
                        value: "\(vm.locations.filter { $0.kind == .risk }.count)",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    )
                    
                    // Danger Locations
                    DashboardCard(
                        title: "Alerta",
                        value: "\(vm.locations.filter { $0.kind == .danger }.count)",
                        icon: "xmark.octagon.fill",
                        color: .red
                    )
                }
                .padding(.horizontal)
                
                // Plot State Chart - Using existing component
                PlotStateChart(
                    data: [
                        PlotState(name: "Sana", plots: vm.locations.filter { $0.kind == .safe }.count),
                        PlotState(name: "En riesgo", plots: vm.locations.filter { $0.kind == .risk }.count),
                        PlotState(name: "Enferma", plots: vm.locations.filter { $0.kind == .danger }.count)
                    ],
                    title: "Estado de Parcelas"
                )
                .padding(.horizontal)
                
                // Weather Overview
                WeatherCard()
                    .padding(.horizontal)
                
                // Recent Reports Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reportes Recientes")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(vm.locations.prefix(3), id: \.id) { location in
                        LocationReportCard(location: location)
                    }
                    .padding(.horizontal)
                }
                
                // Crop Recommendations
                CropRecommendationsCard()
                
                // Crop Alerts
                CropAlertsCard()
            }
            .padding(.vertical)
        }
        .navigationTitle("Tablero")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Dashboard Card Component
struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Location Report Card for Dashboard
struct LocationReportCard: View {
    let location: Location
    
    private var latestReport: plotReport? {
        location.reports.max(by: { $0.date < $1.date })
    }
    
    private var statusColor: Color {
        switch location.kind {
        case .safe: return .green
        case .risk: return .orange
        case .danger: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            // Location info
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(location.cityName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Latest report info
            if let report = latestReport {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(report.code)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(formatDate(report.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
