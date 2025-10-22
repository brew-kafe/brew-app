//
//  AdminStatisticsView.swift
//  brew
//
//  Created for Admin Dashboard
//

import SwiftUI

struct AdminStatisticsView: View {
    let locations: [Location]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // OVERVIEW CARDS
                    overviewSection
                    
                    // STATUS DISTRIBUTION
                    statusDistributionSection
                    
                    // METRICS AVERAGES
                    metricsSection
                    
                    // REPORTS SUMMARY
                    reportsSection
                }
                .padding()
            }
            .navigationTitle("Estadísticas Generales")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen General")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                OverviewCard(
                    title: "Total Parcelas",
                    value: "\(locations.count)",
                    icon: "leaf.fill",
                    color: .blue
                )
                
                OverviewCard(
                    title: "Parcelas Sanas",
                    value: "\(safeCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                OverviewCard(
                    title: "En Riesgo",
                    value: "\(riskCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .yellow
                )
                
                OverviewCard(
                    title: "Afectadas",
                    value: "\(dangerCount)",
                    icon: "xmark.octagon.fill",
                    color: .red
                )
            }
        }
    }
    
    // MARK: - Status Distribution
    private var statusDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución por Estado")
                .font(.headline)
            
            VStack(spacing: 16) {
                StatusBar(label: "Sanas", count: safeCount, total: locations.count, color: .green)
                StatusBar(label: "En Riesgo", count: riskCount, total: locations.count, color: .yellow)
                StatusBar(label: "Afectadas", count: dangerCount, total: locations.count, color: .red)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
        }
    }
    
    // MARK: - Metrics Section
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Promedios de Métricas")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(
                    title: "Humedad",
                    value: "\(Int(avgMoisture))%",
                    icon: "drop.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Luz Solar",
                    value: "\(Int(avgSun))%",
                    icon: "sun.max.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Severidad Plagas",
                    value: "\(Int(avgPest))%",
                    icon: "ladybug.fill",
                    color: avgPest > 50 ? .red : .yellow
                )
                
                MetricCard(
                    title: "Reportes Totales",
                    value: "\(totalReports)",
                    icon: "doc.text.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Reports Section
    private var reportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reportes Recientes")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(Array(recentReports.prefix(5)), id: \.code) { report in
                    ReportRow(report: report)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
        }
    }
    
    // MARK: - Computed Properties
    private var safeCount: Int {
        locations.filter { $0.kind == .safe }.count
    }
    
    private var riskCount: Int {
        locations.filter { $0.kind == .risk }.count
    }
    
    private var dangerCount: Int {
        locations.filter { $0.kind == .danger }.count
    }
    
    private var avgMoisture: Double {
        let sum = locations.reduce(0) { $0 + $1.metrics.moisture }
        return locations.isEmpty ? 0 : Double(sum) / Double(locations.count)
    }
    
    private var avgSun: Double {
        let sum = locations.reduce(0) { $0 + $1.metrics.sun }
        return locations.isEmpty ? 0 : Double(sum) / Double(locations.count)
    }
    
    private var avgPest: Double {
        let sum = locations.reduce(0) { $0 + $1.metrics.pestSeverity }
        return locations.isEmpty ? 0 : Double(sum) / Double(locations.count)
    }
    
    private var totalReports: Int {
        locations.reduce(0) { $0 + $1.reports.count }
    }
    
    private var recentReports: [plotReport] {
        locations
            .flatMap { $0.reports }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - Supporting Views
struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(color)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
    }
}

struct StatusBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(count) (\(Int(percentage * 100))%)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
    }
}

struct ReportRow: View {
    let report: plotReport
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(report.code)
                    .font(.headline)
                Text(report.manager)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(report.date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if report.file != nil {
                Image(systemName: "doc.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AdminStatisticsView(locations: LocationsDataService.locations)
}
