//
//  DiagnosisViewModel.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import SwiftUI

class DiagnosisViewModel: ObservableObject {
    @Published var diagnoses: [Diagnosis] = []
    @Published var isAnalyzing: Bool = false
    @Published var analysisError: String?
    @Published var currentAnalysisRequest: PhotoAnalysisRequest?
    
    init() {
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    func analyzePhoto(request: PhotoAnalysisRequest) {
        isAnalyzing = true
        analysisError = nil
        currentAnalysisRequest = request
        
        // Simulate AI analysis with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.completeAnalysis(request: request)
        }
    }
    
    func deleteDiagnosis(_ diagnosis: Diagnosis) {
        diagnoses.removeAll { $0.id == diagnosis.id }
    }
    
    func exportDiagnosis(_ diagnosis: Diagnosis) -> String {
        // Export diagnosis data as formatted string
        var export = """
        === DIAGNÓSTICO DE CAFÉ ===
        
        Parcela: \(diagnosis.parcelName)
        Planta: \(diagnosis.plantNumber)
        Técnico: \(diagnosis.technicianName)
        Fecha: \(formatDate(diagnosis.date))
        
        Estado General: \(diagnosis.overallHealth.rawValue)
        
        """
        
        if !diagnosis.nutritionalDeficiencies.isEmpty {
            export += "\nDeficiencias Nutricionales:\n"
            for deficiency in diagnosis.nutritionalDeficiencies {
                export += """
                - \(deficiency.nutrient.rawValue) (\(deficiency.nutrient.symbol))
                  Severidad: \(deficiency.severity.rawValue)
                  Plantas afectadas: \(deficiency.plantsAffected) (\(String(format: "%.1f", deficiency.percentage))%)
                  Recomendaciones: \(deficiency.recommendations)
                
                """
            }
        }
        
        export += "\nDiagnóstico:\n\(diagnosis.diagnosis)\n"
        
        if let notes = diagnosis.notes {
            export += "\nNotas adicionales:\n\(notes)\n"
        }
        
        return export
    }
    
    // MARK: - Private Methods
    
    private func completeAnalysis(request: PhotoAnalysisRequest) {
        // Simulate AI analysis results
        let mockDeficiencies = generateMockDeficiencies()
        let overallHealth = calculateOverallHealth(from: mockDeficiencies)
        
        let diagnosis = Diagnosis(
            parcelName: request.parcelName,
            plantNumber: request.plantNumber,
            technicianName: request.technicianName,
            diagnosis: generateDiagnosisText(deficiencies: mockDeficiencies, health: overallHealth),
            date: Date(),
            imageData: request.imageData,
            nutritionalDeficiencies: mockDeficiencies,
            overallHealth: overallHealth,
            notes: request.additionalNotes
        )
        
        diagnoses.insert(diagnosis, at: 0)
        isAnalyzing = false
        currentAnalysisRequest = nil
    }
    
    private func generateMockDeficiencies() -> [NutritionalDeficiency] {
        // Generate random mock deficiencies for demonstration
        let possibleDeficiencies: [(NutrientType, DeficiencySeverity, String)] = [
            (.nitrogen, .moderate, "Aplicar fertilizante nitrogenado. Considerar urea o sulfato de amonio."),
            (.phosphorus, .mild, "Incrementar aporte de fósforo. Aplicar superfosfato triple."),
            (.potassium, .severe, "Urgente aplicación de potasio. Usar cloruro o sulfato de potasio."),
            (.magnesium, .mild, "Aplicar sulfato de magnesio foliar. Verificar pH del suelo.")
        ]
        
        let numberOfDeficiencies = Int.random(in: 1...3)
        let selectedDeficiencies = possibleDeficiencies.shuffled().prefix(numberOfDeficiencies)
        
        return selectedDeficiencies.map { nutrient, severity, recommendations in
            let plantsAffected = Int.random(in: 5...25)
            let percentage = Double(plantsAffected) * 100.0 / 50.0 // Assuming 50 total plants
            
            return NutritionalDeficiency(
                nutrient: nutrient,
                severity: severity,
                plantsAffected: plantsAffected,
                percentage: percentage,
                recommendations: recommendations
            )
        }
    }
    
    private func calculateOverallHealth(from deficiencies: [NutritionalDeficiency]) -> PlantHealth {
        if deficiencies.isEmpty {
            return .excellent
        }
        
        let severityScore = deficiencies.reduce(0) { score, deficiency in
            let severityValue: Int
            switch deficiency.severity {
            case .mild: severityValue = 1
            case .moderate: severityValue = 2
            case .severe: severityValue = 3
            case .critical: severityValue = 4
            }
            return score + severityValue
        }
        
        let averageSeverity = Double(severityScore) / Double(deficiencies.count)
        
        switch averageSeverity {
        case 0..<1.5: return .good
        case 1.5..<2.5: return .fair
        case 2.5..<3.5: return .poor
        default: return .critical
        }
    }
    
    private func generateDiagnosisText(deficiencies: [NutritionalDeficiency], health: PlantHealth) -> String {
        if deficiencies.isEmpty {
            return "Las plantas analizadas presentan un estado nutricional óptimo. No se detectaron deficiencias significativas. Se recomienda continuar con el programa de fertilización actual."
        }
        
        var text = "Análisis nutricional completado. "
        text += "Estado general: \(health.rawValue). "
        
        if deficiencies.count == 1 {
            text += "Se detectó una deficiencia nutricional. "
        } else {
            text += "Se detectaron \(deficiencies.count) deficiencias nutricionales. "
        }
        
        text += "Se recomienda seguir el plan de fertilización sugerido para cada nutriente deficiente."
        
        return text
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
    
    private func loadMockData() {
        // Load some mock diagnoses for testing
        let mockDiagnoses = [
            Diagnosis(
                parcelName: "Parcela Norte A",
                plantNumber: "PN-045",
                technicianName: "Juan Pérez",
                diagnosis: "Se detectó deficiencia moderada de nitrógeno en el 30% de las plantas analizadas. Se recomienda aplicación de fertilizante nitrogenado.",
                date: Date().addingTimeInterval(-86400 * 2),
                nutritionalDeficiencies: [
                    NutritionalDeficiency(
                        nutrient: .nitrogen,
                        severity: .moderate,
                        plantsAffected: 15,
                        percentage: 30.0,
                        recommendations: "Aplicar urea 46% a razón de 150 kg/ha"
                    )
                ],
                overallHealth: .fair,
                notes: "Revisar en 15 días"
            ),
            Diagnosis(
                parcelName: "Parcela Sur B",
                plantNumber: "PS-023",
                technicianName: "María González",
                diagnosis: "Plantas en estado nutricional óptimo. No se detectaron deficiencias significativas.",
                date: Date().addingTimeInterval(-86400 * 5),
                nutritionalDeficiencies: [],
                overallHealth: .excellent,
                notes: nil
            )
        ]
        
        diagnoses = mockDiagnoses
    }
}
