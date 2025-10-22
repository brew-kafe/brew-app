//
//  ReportDetailView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI
import Charts

struct EnhancedReportDetailView: View {
    let report: ReportEntity
    @ObservedObject var viewModel: ReportViewModel
    @ObservedObject var diagnosisViewModel: DiagnosisViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab = 0
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                headerCard
                
                // Tab Selector
                tabSelector
                
                // Content based on selected tab
                if selectedTab == 0 {
                    overviewSection
                } else if selectedTab == 1 {
                    diagnosesSection
                } else {
                    analyticsSection
                }
            }
            .padding()
        }
        .navigationTitle(report.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showShareSheet = true }) {
                        Label("Compartir", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Eliminar", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Eliminar Reporte", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.deleteReport(
                        reportId: report.id,
                        entity: report,
                        modelContext: modelContext
                    )
                }
            }
        } message: {
            Text("¿Estás seguro de que deseas eliminar este reporte?")
        }
        .task {
            await viewModel.fetchReportWithDiagnoses(reportId: report.id)
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if let type = report.reportTypeEnum {
                    Image(systemName: type.icon)
                        .font(.title)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading) {
                    Text(report.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let type = report.reportTypeEnum {
                        Text(type.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            // Metadata
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Fecha", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(report.reportDate, style: .date)
                        .font(.caption)
                }
                
                HStack {
                    Label("Diagnósticos", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(report.diagnosisCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                if let score = report.performanceScore {
                    HStack {
                        Label("Puntuación", systemImage: "chart.bar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", score))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(scoreColor(score))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Resumen", icon: "doc.text", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Diagnósticos", icon: "leaf", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Análisis", icon: "chart.xyaxis.line", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let notes = report.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notas")
                        .font(.headline)
                    
                    Text(notes)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            if let fullReport = viewModel.currentReport {
                quickStatsView(fullReport: fullReport)
            }
        }
    }
    
    // MARK: - Diagnoses Section
    private var diagnosesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let fullReport = viewModel.currentReport {
                Text("Diagnósticos Vinculados")
                    .font(.headline)
                
                if fullReport.diagnoses.isEmpty {
                    Text("No hay diagnósticos vinculados")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    ForEach(fullReport.diagnoses) { diagnosis in
                        DiagnosisDetailCard(diagnosis: diagnosis)
                    }
                }
            } else if viewModel.isProcessing {
                ProgressView("Cargando diagnósticos...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
    }
    
    // MARK: - Analytics Section
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let fullReport = viewModel.currentReport {
                // Deficiency Distribution Chart
                deficiencyDistributionChart(diagnoses: fullReport.diagnoses)
                
                // Detection State Distribution
                detectionStateChart(diagnoses: fullReport.diagnoses)
                
                // Confidence Levels
                confidenceLevelsView(diagnoses: fullReport.diagnoses)
                
                // Nutritional Analysis (Radar Chart)
                if let firstDiagnosis = fullReport.diagnoses.first,
                   let localDiagnosis = diagnosisViewModel.diagnosesList.first(where: { $0.id.uuidString == firstDiagnosis.diagnosisId }) {
                    nutritionalRadarChart(diagnosis: localDiagnosis)
                }
            } else if viewModel.isProcessing {
                ProgressView("Cargando análisis...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
    }
    
    // MARK: - Quick Stats View
    private func quickStatsView(fullReport: ReportWithDiagnosesAPI) -> some View {
        let avgConfidence = fullReport.diagnoses.compactMap { $0.aiConfidence }.reduce(0, +) / Double(max(fullReport.diagnoses.count, 1))
        let dangerCount = fullReport.diagnoses.filter { $0.detectionState == "danger" }.count
        let optimalCount = fullReport.diagnoses.filter { $0.detectionState == "optimal" }.count
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas Rápidas")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickStatCard(
                    title: "Confianza Prom.",
                    value: String(format: "%.1f%%", avgConfidence * 100),
                    color: .blue
                )
                
                QuickStatCard(
                    title: "Críticos",
                    value: "\(dangerCount)",
                    color: .red
                )
                
                QuickStatCard(
                    title: "Óptimos",
                    value: "\(optimalCount)",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Charts
    private func deficiencyDistributionChart(diagnoses: [DiagnosisSummaryAPI]) -> some View {
        let deficiencyCounts = Dictionary(grouping: diagnoses, by: { $0.primaryDeficiency })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Distribución de Deficiencias")
                .font(.headline)
            
            Chart(deficiencyCounts.prefix(5), id: \.key) { item in
                BarMark(
                    x: .value("Cantidad", item.value),
                    y: .value("Deficiencia", item.key)
                )
                .foregroundStyle(.blue.gradient)
                .annotation(position: .trailing) {
                    Text("\(item.value)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 1)
        }
    }
    
    private func detectionStateChart(diagnoses: [DiagnosisSummaryAPI]) -> some View {
        let stateCounts = Dictionary(grouping: diagnoses, by: { $0.detectionState })
            .mapValues { $0.count }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Estado de Detección")
                .font(.headline)
            
            Chart(Array(stateCounts.keys), id: \.self) { state in
                SectorMark(
                    angle: .value("Count", stateCounts[state] ?? 0),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Estado", state))
                .annotation(position: .overlay) {
                    Text("\(stateCounts[state] ?? 0)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 200)
            .chartForegroundStyleScale([
                "danger": .red,
                "moderate": .orange,
                "optimal": .green
            ])
            .chartLegend(position: .bottom, alignment: .center)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 1)
        }
    }
    
    private func confidenceLevelsView(diagnoses: [DiagnosisSummaryAPI]) -> some View {
        let confidences = diagnoses.compactMap { $0.aiConfidence }
        let avgConfidence = confidences.isEmpty ? 0 : confidences.reduce(0, +) / Double(confidences.count)
        let minConfidence = confidences.min() ?? 0
        let maxConfidence = confidences.max() ?? 0
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Niveles de Confianza")
                .font(.headline)
            
            VStack(spacing: 12) {
                ConfidenceBar(title: "Promedio", value: avgConfidence, color: .blue)
                ConfidenceBar(title: "Mínimo", value: minConfidence, color: .orange)
                ConfidenceBar(title: "Máximo", value: maxConfidence, color: .green)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 1)
        }
    }
    
    private func nutritionalRadarChart(diagnosis: DiagnosisEntity) -> some View {
        let nutritionalData = diagnosis.allElements.map { element in
            NutritionalData(
                nutrient: element.element,
                symptomsPercentage: 100 - element.percentage,
                weightingValue: Int(element.percentage / 20) + 1
            )
        }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Análisis Nutricional")
                .font(.headline)
            
            if !nutritionalData.isEmpty {
                UnifiedRadarChartView(
                    dataSets: [RadarChartDataSet.fromNutritionalData(nutritionalData)]
                )
                .frame(height: 400)
            } else {
                Text("No hay datos nutricionales disponibles")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

struct DiagnosisDetailCard: View {
    let diagnosis: DiagnosisSummaryAPI
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(diagnosis.parcelName)
                        .font(.headline)
                    
                    if let plantNumber = diagnosis.plantNumber {
                        Text("Planta \(plantNumber)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Image(systemName: stateIcon(diagnosis.detectionState))
                    .foregroundColor(stateColor(diagnosis.detectionState))
                    .font(.title2)
            }
            
            Divider()
            
            // Deficiency Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Deficiencia:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(diagnosis.primaryDeficiency)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Elemento:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(diagnosis.deficiencyElement)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                if let confidence = diagnosis.aiConfidence {
                    HStack {
                        Text("Confianza:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: confidence)
                            .tint(confidenceColor(confidence))
                        
                        Text(String(format: "%.1f%%", confidence * 100))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(confidenceColor(confidence))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func stateIcon(_ state: String) -> String {
        switch state {
        case "danger": return "exclamationmark.triangle.fill"
        case "moderate": return "exclamationmark.circle.fill"
        case "optimal": return "checkmark.circle.fill"
        default: return "questionmark.circle"
        }
    }
    
    private func stateColor(_ state: String) -> Color {
        switch state {
        case "danger": return .red
        case "moderate": return .orange
        case "optimal": return .green
        default: return .gray
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ConfidenceBar: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f%%", value * 100))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        EnhancedReportDetailView(
            report: ReportEntity(
                id: 1,
                title: "Reporte Semanal - Semana 42",
                userId: UUID(),
                reportType: "nutrition",
                performanceScore: 75.5, diagnosisCount: 5
            ),
            viewModel: ReportViewModel(),
            diagnosisViewModel: DiagnosisViewModel()
        )
    }
    .modelContainer(for: [ReportEntity.self, DiagnosisEntity.self])
}
