//
//  ReportsView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI
import SwiftData

struct ReportsView: View {
    @StateObject private var viewModel = ReportViewModel()
    @StateObject private var diagnosisViewModel = DiagnosisViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @State private var showCreateSheet = false
    @State private var searchText = ""
    @State private var selectedReportType: ReportType?
    
    var filteredReports: [ReportEntity] {
        var filtered = viewModel.reports
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { report in
                report.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by type
        if let type = selectedReportType {
            filtered = filtered.filter { $0.reportType == type.rawValue }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            if viewModel.reports.isEmpty && !viewModel.isProcessing {
                emptyStateView
            } else {
                mainContentView
            }
        }
        .navigationTitle("Reportes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        Task {
                            await viewModel.fetchReports(modelContext: modelContext)
                        }
                    }) {
                        Label("Sincronizar", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: { showCreateSheet = true }) {
                        Label("Nuevo Reporte", systemImage: "plus")
                    }
                    
                    // Test button for debugging
                    Button(action: {
                        Task {
                            await viewModel.testReportCreation(modelContext: modelContext)
                        }
                    }) {
                        Label("Test Report Creation", systemImage: "testtube.2")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Buscar reportes...")
        .sheet(isPresented: $showCreateSheet) {
            CreateReportView(
                viewModel: viewModel,
                diagnosisViewModel: diagnosisViewModel,
                modelContext: modelContext
            )
        }
        .task {
            await viewModel.loadLocalReports(modelContext: modelContext)
            await diagnosisViewModel.fetchDiagnoses(modelContext: modelContext)
        }
        .refreshable {
            await viewModel.fetchReports(modelContext: modelContext)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay reportes")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Crea tu primer reporte vinculando diagnósticos")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showCreateSheet = true }) {
                Label("Crear Reporte", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Statistics Card
                statisticsCard
                
                // Filter by Type
                filterSection
                
                // Reports List
                reportsListSection
                
                // Error/Success Messages
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }
                
                if let success = viewModel.successMessage {
                    SuccessBanner(message: success)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        let stats = viewModel.calculateStatistics()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Resumen")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItemView(
                    title: "Total",
                    value: "\(stats.totalReports)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                if let avgScore = stats.averagePerformanceScore {
                    StatItemView(
                        title: "Prom. Score",
                        value: String(format: "%.1f", avgScore),
                        icon: "chart.bar.fill",
                        color: .green
                    )
                }
                
                StatItemView(
                    title: "Este Mes",
                    value: "\(reportsThisMonth())",
                    icon: "calendar",
                    color: .orange
                )
            }
            
            // By Type Breakdown
            if !stats.byType.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Por Tipo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(stats.byType.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { type in
                        HStack {
                            Label(type.displayName, systemImage: type.icon)
                                .font(.caption)
                            Spacer()
                            Text("\(stats.byType[type] ?? 0)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "Todos",
                    isSelected: selectedReportType == nil,
                    action: { selectedReportType = nil }
                )
                
                ForEach(ReportType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.displayName,
                        icon: type.icon,
                        isSelected: selectedReportType == type,
                        action: { selectedReportType = type }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Reports List
    private var reportsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reportes")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if filteredReports.isEmpty {
                Text("No se encontraron reportes")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(filteredReports) { report in
                    NavigationLink(destination: EnhancedReportDetailView(
                        report: report,
                        viewModel: viewModel,
                        diagnosisViewModel: diagnosisViewModel
                    )) {
                        ReportCardView(report: report)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func reportsThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        return viewModel.reports.filter { report in
            calendar.isDate(report.reportDate, equalTo: now, toGranularity: .month)
        }.count
    }
}

// MARK: - Supporting Views

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct ReportCardView: View {
    let report: ReportEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                if let type = report.reportTypeEnum {
                    Image(systemName: type.icon)
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let type = report.reportTypeEnum {
                        Text(type.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Divider()
            
            // Info
            HStack {
                Label("\(report.diagnosisCount) diagnósticos", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(report.reportDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let score = report.performanceScore {
                HStack {
                    Text("Puntuación:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", score))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(scoreColor(score))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SuccessBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .font(.caption)
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview {
    ReportsView()
        .modelContainer(for: [ReportEntity.self, DiagnosisEntity.self])
}
