//
//
//

import SwiftUI
import SwiftData

struct CreateReportView: View {
    @ObservedObject var viewModel: ReportViewModel
    @ObservedObject var diagnosisViewModel: DiagnosisViewModel
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var reportTitle: String = ""
    @State private var selectedDiagnosisIds: Set<UUID> = []
    @State private var reportType: ReportType = .nutrition
    @State private var notes: String = ""
    @State private var performanceScore: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Reporte")) {
                    TextField("Título del reporte", text: $reportTitle)
                        .autocapitalization(.words)
                    
                    Picker("Tipo de Reporte", selection: $reportType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    TextField("Puntuación (opcional)", text: $performanceScore)
                        .keyboardType(.decimalPad)
                    
                    TextField("Notas (opcional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Seleccionar Diagnósticos")) {
                    if diagnosisViewModel.diagnosesList.isEmpty {
                        Text("No hay diagnósticos disponibles")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(diagnosisViewModel.diagnosesList) { diagnosis in
                            DiagnosisSelectionRow(
                                diagnosis: diagnosis,
                                isSelected: selectedDiagnosisIds.contains(diagnosis.id),
                                onToggle: { toggleDiagnosisSelection(diagnosis.id) }
                            )
                        }
                    }
                }
                
                Section {
                    Button(action: createReport) {
                        HStack {
                            Spacer()
                            if viewModel.isProcessing {
                                ProgressView()
                            } else {
                                Text("Crear Reporte")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(reportTitle.isEmpty || selectedDiagnosisIds.isEmpty || viewModel.isProcessing)
                }
                
                // Show error or success message
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Nuevo Reporte")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    dismiss()
                },
                trailing: selectedDiagnosisIds.isEmpty ? nil : Text("\(selectedDiagnosisIds.count) seleccionados")
                    .font(.caption)
                    .foregroundColor(.secondary)
            )
        }
    }
    
    private func createReport() {
        Task {
            // Parse performance score
            let score = Double(performanceScore.trimmingCharacters(in: .whitespaces))
            
            await viewModel.createReport(
                title: reportTitle,
                diagnosisIds: Array(selectedDiagnosisIds),
                reportType: reportType,
                notes: notes.isEmpty ? nil : notes,
                performanceScore: score,
                modelContext: modelContext
            )
            
            // Dismiss if successful
            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
    
    private func colorForState(_ state: DetectionState) -> Color {
        switch state {
        case .danger: return .red
        case .moderate: return .orange
        case .optimal: return .green
        }
    }
    
    private func toggleDiagnosisSelection(_ diagnosisId: UUID) {
        if selectedDiagnosisIds.contains(diagnosisId) {
            selectedDiagnosisIds.remove(diagnosisId)
        } else {
            selectedDiagnosisIds.insert(diagnosisId)
        }
    }
}

// MARK: - Diagnosis Selection Row
struct DiagnosisSelectionRow: View {
    let diagnosis: DiagnosisEntity
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(diagnosis.parcelName)
                        .foregroundColor(.primary)
                        .font(.headline)
                    
                    HStack {
                        if let plantNumber = diagnosis.plantNumber {
                            Text("Planta \(plantNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(diagnosis.primaryDeficiency)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Detection state badge
                    if let state = diagnosis.detectionStateEnum {
                        Label(state.displayName, systemImage: state.icon)
                            .font(.caption2)
                            .foregroundColor(state.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(state.color.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DiagnosisEntity.self, ReportEntity.self,
        configurations: config
    )
    let context = container.mainContext
    
    // Create sample diagnoses
    let sampleDiagnoses = [
        DiagnosisEntity(
            parcelName: "Parcela A",
            plantNumber: "001",
            technicianName: "Luis",
            primaryDeficiency: "Nitrogen Deficiency",
            deficiencyElement: "Nitrogen",
            detectionState: "danger",
            aiConfidence: 0.92,
            aiDescription: "Severe deficiency",
            aiRecommendations: ["Apply fertilizer"],
            allElements: [],
            photoURLs: []
        ),
        DiagnosisEntity(
            parcelName: "Parcela B",
            plantNumber: "002",
            technicianName: "Ana",
            primaryDeficiency: "Healthy Plant",
            deficiencyElement: "None",
            detectionState: "optimal",
            aiConfidence: 0.98,
            aiDescription: "Optimal health",
            aiRecommendations: ["Maintain care"],
            allElements: [],
            photoURLs: []
        )
    ]
    
    for diagnosis in sampleDiagnoses {
        context.insert(diagnosis)
    }
    
    let viewModel = ReportViewModel()
    let diagnosisViewModel = DiagnosisViewModel()
    diagnosisViewModel.diagnosesList = sampleDiagnoses
    
    return CreateReportView(
        viewModel: viewModel,
        diagnosisViewModel: diagnosisViewModel,
        modelContext: context
    )
    .modelContainer(container)
}
