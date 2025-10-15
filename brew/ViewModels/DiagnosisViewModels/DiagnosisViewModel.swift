//
//  DiagnosisViewModel.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI
import Combine

class DiagnosisViewModel: ObservableObject {
    @Published var diagnoses: [DiagnosisEntity] = []
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isTestMode = false
    @Published var analysisCompleted = false
    
    private let diagnosticService = PlantDiagnosticService.shared
    
    // MARK: - Test Mode Toggle
    func toggleTestMode() {
        isTestMode.toggle()
        print("🧪 Test mode \(isTestMode ? "enabled" : "disabled")")
    }
    
    // MARK: - Create Test Diagnosis
    func createTestDiagnosis(completion: (() -> Void)? = nil) {
        print("🧪 Creating test diagnosis...")
        
        isAnalyzing = true
        analysisCompleted = false
        
        // Simulate analysis delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isAnalyzing = false
            self?.analysisCompleted = true
            
            let testDiagnosis = self?.generateMockDiagnosis()
            if let diagnosis = testDiagnosis {
                self?.diagnoses.insert(diagnosis, at: 0)
                print("✅ Test diagnosis created successfully")
                completion?()
            }
        }
    }
    
    // MARK: - Generate Mock Diagnosis
    private func generateMockDiagnosis() -> DiagnosisEntity {
        let mockScenarios = [
            (
                deficiency: "Deficiencia de Nitrógeno",
                element: "Nitrógeno",
                state: "Moderado",
                confidence: 0.85,
                description: "Se detectó deficiencia de nitrógeno en las hojas. Las hojas más viejas muestran amarillamiento que comienza desde la punta hacia el centro.",
                recommendations: [
                    "Aplicar fertilizante nitrogenado (urea 20-30 kg/ha)",
                    "Monitorear el desarrollo de nuevas hojas",
                    "Realizar análisis de suelo para evaluar disponibilidad de nutrientes"
                ]
            ),
            (
                deficiency: "Deficiencia de Fósforo",
                element: "Fósforo",
                state: "Severo",
                confidence: 0.92,
                description: "Deficiencia severa de fósforo detectada. Las hojas presentan coloración púrpura en los bordes y crecimiento stunted.",
                recommendations: [
                    "Aplicar fertilizante fosfórico (DAP 15-25 kg/ha)",
                    "Ajustar pH del suelo para mejorar absorción",
                    "Aplicar abono orgánico rico en fósforo"
                ]
            ),
            (
                deficiency: "Planta Saludable",
                element: "N/A",
                state: "Saludable",
                confidence: 0.95,
                description: "La planta presenta un estado saludable óptimo. Coloración verde uniforme y desarrollo normal.",
                recommendations: [
                    "Mantener el programa de fertilización actual",
                    "Continuar con monitoreo rutinario",
                    "Evaluar condiciones de riego y drenaje"
                ]
            ),
            (
                deficiency: "Deficiencia de Potasio",
                element: "Potasio",
                state: "Moderado",
                confidence: 0.78,
                description: "Se observa deficiencia de potasio con síntomas característicos en los bordes de las hojas.",
                recommendations: [
                    "Aplicar sulfato de potasio (KCl 10-15 kg/ha)",
                    "Evaluar balance de cationes en el suelo",
                    "Monitorear desarrollo de frutos"
                ]
            )
        ]
        
        let randomScenario = mockScenarios.randomElement()!
        let randomPlantNumber = Int.random(in: 1...100)
        
        // Create mock ElementAnalysis
        let mockElements = createMockElementAnalysis(for: randomScenario.element)
        
        return DiagnosisEntity(
            parcelName: "Parcela Test \(Int.random(in: 1...10))",
            plantNumber: "PT-\(randomPlantNumber)",
            technicianName: "Técnico Test",
            primaryDeficiency: randomScenario.deficiency,
            deficiencyElement: randomScenario.element,
            detectionState: randomScenario.state,
            aiConfidence: randomScenario.confidence,
            aiDescription: randomScenario.description,
            aiRecommendations: randomScenario.recommendations,
            allElements: mockElements,
            photoURLs: [],
            diagnosisDate: Date(),
            createdAt: Date()
        )
    }
    
    // MARK: - Create Mock Element Analysis
    private func createMockElementAnalysis(for primaryElement: String) -> [ElementAnalysis] {
        let allElements = ["Nitrógeno", "Fósforo", "Potasio", "Calcio", "Magnesio", "Hierro"]
        var elements: [ElementAnalysis] = []
        
        for element in allElements {
            let isPrimary = element == primaryElement
            let percentage = isPrimary ? Double.random(in: 60...90) : Double.random(in: 15...45)
            let detectionState: DetectionState = isPrimary ? .danger : (percentage > 30 ? .optimal : .moderate)
            let deficiencyLevel = isPrimary ? "Alto" : (percentage > 30 ? "Normal" : "Bajo")
            let recommendations = isPrimary ? 
                ["Aplicar fertilizante específico", "Monitorear evolución"] :
                ["Mantener niveles actuales"]
            
            elements.append(ElementAnalysis(
                element: element,
                percentage: percentage,
                detectionState: detectionState,
                deficiencyLevel: deficiencyLevel,
                recommendations: recommendations
            ))
        }
        
        return elements.sorted { $0.percentage > $1.percentage }
    }
    
    func analyzePhoto(request: PhotoAnalysisRequest) {
        if isTestMode {
            // In test mode, ignore the photo and create a test diagnosis
            createTestDiagnosis()
        } else {
            // Original implementation would go here
            print("Analyzing photo with ML model...")
            // TODO: Implement actual ML analysis
        }
    }
    
    func deleteDiagnosis(_ diagnosis: DiagnosisEntity) {
        diagnoses.removeAll { $0.id == diagnosis.id }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct PhotoAnalysisRequest {
    let imageData: Data
    let parcelName: String
    let plantNumber: String
    let technicianName: String
    let totalPlants: Int
    let additionalNotes: String?
}
