//
//  ReportViewModel.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class ReportViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var reports: [ReportEntity] = []
    @Published var currentReport: ReportWithDiagnosesAPI?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var processingStep: String = ""
    
    // MARK: - Services
    private let coordinator = ReportCoordinator.shared
    private let apiService = APIReportService.shared
    
    // MARK: - User Data
    var userId: UUID = UUID(uuidString: "9d3e1b2f-3540-41f3-b08b-ebd9589fea61")! // Test user UUID
    
    // MARK: - Create Report
    /// Creates a new report linked to diagnoses
    func createReport(
        title: String,
        diagnosisIds: [UUID],
        parcelId: Int? = nil,
        reportType: ReportType = .nutrition,
        notes: String? = nil,
        performanceScore: Double? = nil,
        modelContext: ModelContext
    ) async {
        guard !diagnosisIds.isEmpty else {
            errorMessage = "Debe seleccionar al menos un diagnóstico"
            return
        }
        
        print("📊 ReportViewModel: Starting report creation...")
        print("📝 Title: '\(title)', Diagnoses: \(diagnosisIds.count)")
        
        isProcessing = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let report = try await coordinator.createReport(
                userId: userId,
                title: title,
                diagnosisIds: diagnosisIds,
                parcelId: parcelId,
                reportType: reportType,
                notes: notes,
                performanceScore: performanceScore,
                modelContext: modelContext
            )
            
            print("✅ ReportViewModel: Report created successfully with ID: \(report.id)")
            successMessage = "Reporte creado exitosamente"
            
            // Refresh list
            await fetchReports(modelContext: modelContext)
            
        } catch {
            print("❌ ReportViewModel: Error creating report: \(error.localizedDescription)")
            errorMessage = "Error al crear reporte: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    /// Test method to verify report creation with fallback
    func testReportCreation(modelContext: ModelContext) async {
        print("🧪 Starting report creation test...")
        
        // Get some diagnosis IDs from local diagnoses
        do {
            let descriptor = FetchDescriptor<DiagnosisEntity>()
            let diagnoses = try modelContext.fetch(descriptor)
            
            if diagnoses.isEmpty {
                print("❌ No diagnoses found for test")
                errorMessage = "No diagnoses available for test"
                return
            }
            
            let diagnosisIds = Array(diagnoses.prefix(2).map { $0.id })
            print("📋 Using \(diagnosisIds.count) diagnoses for test")
            
            await createReport(
                title: "Test Report - \(Date().formatted())",
                diagnosisIds: diagnosisIds,
                reportType: .nutrition,
                notes: "Auto-generated test report",
                modelContext: modelContext
            )
            
        } catch {
            print("❌ Test failed: \(error.localizedDescription)")
            errorMessage = "Test failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Fetch Reports
    /// Fetch and sync reports from API
    func fetchReports(modelContext: ModelContext) async {
        isProcessing = true
        processingStep = "Obteniendo reportes..."
        
        do {
            let fetchedReports = try await coordinator.fetchAndSyncReports(
                userId: userId,
                modelContext: modelContext
            )
            
            reports = fetchedReports
            processingStep = "Reportes actualizados"
            
        } catch {
            errorMessage = "Error al obtener reportes: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    /// Load reports from local database only
    func loadLocalReports(modelContext: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<ReportEntity>(
                predicate: #Predicate { $0.userId == userId },
                sortBy: [SortDescriptor(\.reportDate, order: .reverse)]
            )
            reports = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error al cargar reportes locales: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Fetch Report with Diagnoses
    /// Fetch a specific report with its diagnoses
    func fetchReportWithDiagnoses(reportId: Int) async {
        isProcessing = true
        processingStep = "Cargando detalles del reporte..."
        
        do {
            currentReport = try await coordinator.fetchReportWithDiagnoses(reportId: reportId)
            processingStep = "Detalles cargados"
        } catch {
            errorMessage = "Error al cargar detalles: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - Delete Report
    func deleteReport(
        reportId: Int,
        entity: ReportEntity,
        modelContext: ModelContext
    ) async {
        isProcessing = true
        
        do {
            try await coordinator.deleteReport(
                reportId: reportId,
                entity: entity,
                modelContext: modelContext
            )
            
            successMessage = "Reporte eliminado"
            await fetchReports(modelContext: modelContext)
            
        } catch {
            errorMessage = "Error al eliminar: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - Statistics
    func calculateStatistics() -> ReportStatistics {
        let total = reports.count
        var byType: [ReportType: Int] = [:]
        var totalScore: Double = 0
        var scoreCount = 0
        
        for report in reports {
            if let type = report.reportTypeEnum {
                byType[type, default: 0] += 1
            }
            
            if let score = report.performanceScore {
                totalScore += score
                scoreCount += 1
            }
        }
        
        let averageScore = scoreCount > 0 ? totalScore / Double(scoreCount) : nil
        
        return ReportStatistics(
            totalReports: total,
            byType: byType,
            averagePerformanceScore: averageScore,
            recentReports: Array(reports.prefix(5))
        )
    }
}

// MARK: - Report Statistics
struct ReportStatistics {
    let totalReports: Int
    let byType: [ReportType: Int]
    let averagePerformanceScore: Double?
    let recentReports: [ReportEntity]
}

// MARK: - Example SwiftUI View
struct ReportExampleView: View {
    @StateObject private var viewModel = ReportViewModel()
    @StateObject private var diagnosisViewModel = DiagnosisViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @State private var showCreateSheet = false
    @State private var reportTitle = ""
    @State private var selectedDiagnosisIds: Set<UUID> = []
    @State private var reportType: ReportType = .nutrition
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Crear Reporte") {
                    Button("Nuevo Reporte") {
                        showCreateSheet = true
                    }
                }
                
                Section("Reportes") {
                    if viewModel.isProcessing {
                        HStack {
                            ProgressView()
                            Text(viewModel.processingStep)
                        }
                    }
                    
                    ForEach(viewModel.reports) { report in
                        NavigationLink(destination: ReportDetailViewWrapper(report: report, viewModel: viewModel)) {
                            ReportRowView(report: report)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let report = viewModel.reports[index]
                            Task {
                                await viewModel.deleteReport(
                                    reportId: report.id,
                                    entity: report,
                                    modelContext: modelContext
                                )
                            }
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                if let success = viewModel.successMessage {
                    Section {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Reportes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sincronizar") {
                        Task {
                            await viewModel.fetchReports(modelContext: modelContext)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateReportSheet(
                    viewModel: viewModel,
                    diagnosisViewModel: diagnosisViewModel,
                    reportTitle: $reportTitle,
                    selectedDiagnosisIds: $selectedDiagnosisIds,
                    reportType: $reportType,
                    notes: $notes,
                    modelContext: modelContext
                )
            }
            .task {
                await viewModel.loadLocalReports(modelContext: modelContext)
                await diagnosisViewModel.fetchDiagnoses(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Supporting Views

struct ReportRowView: View {
    let report: ReportEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(report.title)
                .font(.headline)
            
            HStack {
                if let type = report.reportTypeEnum {
                    Label(type.displayName, systemImage: type.icon)
                        .font(.caption)
                }
                
                Spacer()
                
                Text(report.reportDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(report.diagnosisCount) diagnósticos")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ReportDetailViewWrapper: View {
    let report: ReportEntity
    @ObservedObject var viewModel: ReportViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isProcessing {
                    ProgressView(viewModel.processingStep)
                }
                
                if let fullReport = viewModel.currentReport {
                    // Display full report with diagnoses
                    ReportDetailContent(report: fullReport)
                } else {
                    Text("Cargando detalles...")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(report.title)
        .task {
            await viewModel.fetchReportWithDiagnoses(reportId: report.id)
        }
    }
}

struct ReportDetailContent: View {
    let report: ReportWithDiagnosesAPI
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Report info
            Group {
                Text("Tipo: \(report.reportType)")
                Text("Fecha: \(report.reportDate, style: .date)")
                Text("Diagnósticos: \(report.diagnosisCount)")
                
                if let score = report.performanceScore {
                    Text("Puntuación: \(score, specifier: "%.1f")")
                }
                
                if let notes = report.notes {
                    Text("Notas:")
                        .font(.headline)
                    Text(notes)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Diagnoses
            Text("Diagnósticos Incluidos")
                .font(.title2)
                .bold()
            
            ForEach(report.diagnoses) { diagnosis in
                DiagnosisCardView(diagnosis: diagnosis)
            }
        }
    }
}

struct DiagnosisCardView: View {
    let diagnosis: DiagnosisSummaryAPI
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(diagnosis.parcelName)
                    .font(.headline)
                
                Spacer()
                
                if let plantNumber = diagnosis.plantNumber {
                    Text("Planta \(plantNumber)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Text(diagnosis.primaryDeficiency)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(diagnosis.detectionState, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                
                Spacer()
                
                if let confidence = diagnosis.aiConfidence {
                    Text("Confianza: \(confidence * 100, specifier: "%.1f")%")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CreateReportSheet: View {
    @ObservedObject var viewModel: ReportViewModel
    @ObservedObject var diagnosisViewModel: DiagnosisViewModel
    @Binding var reportTitle: String
    @Binding var selectedDiagnosisIds: Set<UUID>
    @Binding var reportType: ReportType
    @Binding var notes: String
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información del Reporte") {
                    TextField("Título", text: $reportTitle)
                    
                    Picker("Tipo", selection: $reportType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    TextField("Notas (opcional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Seleccionar Diagnósticos") {
                    ForEach(diagnosisViewModel.diagnosesList) { diagnosis in
                        Button(action: {
                            if selectedDiagnosisIds.contains(diagnosis.id) {
                                selectedDiagnosisIds.remove(diagnosis.id)
                            } else {
                                selectedDiagnosisIds.insert(diagnosis.id)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedDiagnosisIds.contains(diagnosis.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedDiagnosisIds.contains(diagnosis.id) ? .blue : .gray)
                                
                                VStack(alignment: .leading) {
                                    Text(diagnosis.parcelName)
                                        .foregroundColor(.primary)
                                    Text(diagnosis.primaryDeficiency)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Crear Reporte") {
                        Task {
                            await viewModel.createReport(
                                title: reportTitle,
                                diagnosisIds: Array(selectedDiagnosisIds),
                                reportType: reportType,
                                notes: notes.isEmpty ? nil : notes,
                                modelContext: modelContext
                            )
                            
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(reportTitle.isEmpty || selectedDiagnosisIds.isEmpty || viewModel.isProcessing)
                }
            }
            .navigationTitle("Nuevo Reporte")
            .navigationBarItems(leading: Button("Cancelar") {
                dismiss()
            })
        }
    }
}
