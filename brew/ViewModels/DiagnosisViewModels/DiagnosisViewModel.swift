//
//  DiagnosisViewModel.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI
import Combine
import UIKit

class DiagnosisViewModel: ObservableObject {
    @Published var diagnoses: [DiagnosisEntity] = []
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var analysisCompleted = false

    private let diagnosticService = PlantDiagnosticService.shared

    // Foundation Models service (iOS 18.1+)
    @available(iOS 18.1, macOS 15.1, *)
    private lazy var foundationModelsService: FoundationModelsDiagnosisService = {
        FoundationModelsDiagnosisService.shared
    }()    // MARK: - Create Test Diagnosis
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
    
    // MARK: - Real Photo Analysis with CoreML
    func analyzePhoto(request: PhotoAnalysisRequest, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        guard let image = UIImage(data: request.imageData) else {
            let error = NSError(domain: "DiagnosisViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
            completion(.failure(error))
            return
        }

        isAnalyzing = true
        analysisCompleted = false

        diagnosticService.classifyImage(image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false

                switch result {
                case .success(let classifications):
                    self?.analysisCompleted = true
                    completion(.success(classifications))

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Generate AI Diagnosis using Foundation Models
    @available(iOS 18.1, macOS 15.1, *)
    func generateAIDiagnosis(
        from photoAnalysis: [ClassificationResult],
        parcelName: String,
        technicianName: String,
        plantNumber: String? = nil,
        additionalNotes: String = "",
        completion: @escaping (Result<DiagnosisEntity, Error>) -> Void
    ) {
        Task {
            do {
                let parcelInfo = """
                Parcel: \(parcelName)
                Technician: \(technicianName)
                \(plantNumber != nil ? "Plant Number: \(plantNumber!)" : "")
                Additional Notes: \(additionalNotes.isEmpty ? "None" : additionalNotes)
                """

                let aiDiagnosis = try await foundationModelsService.generateDiagnosis(
                    from: photoAnalysis,
                    parcelInfo: parcelInfo,
                    additionalNotes: additionalNotes
                )

                // Convert to DiagnosisEntity
                let entity = DiagnosisEntity(
                    parcelName: parcelName,
                    plantNumber: plantNumber,
                    technicianName: technicianName,
                    primaryDeficiency: aiDiagnosis.primaryDeficiency,
                    deficiencyElement: aiDiagnosis.deficiencyElement,
                    detectionState: aiDiagnosis.detectionState,
                    aiConfidence: aiDiagnosis.confidencePercentage / 100.0,
                    aiDescription: aiDiagnosis.detailedDescription,
                    aiRecommendations: aiDiagnosis.recommendations,
                    allElements: aiDiagnosis.elementAnalysis.map { aiElement in
                        ElementAnalysis(
                            element: aiElement.element,
                            percentage: aiElement.percentage,
                            detectionState: DetectionState(rawValue: aiElement.detectionState) ?? .moderate,
                            deficiencyLevel: aiElement.deficiencyLevel,
                            recommendations: aiElement.recommendations
                        )
                    },
                    photoURLs: [],
                    diagnosisDate: Date(),
                    createdAt: Date()
                )

                await MainActor.run {
                    self.diagnoses.insert(entity, at: 0)
                    self.analysisCompleted = true

                    // Also persist to AIDiagnosisDataService (must be on MainActor)
                    do {
                        try AIDiagnosisDataService.shared.saveDiagnosis(
                            aiDiagnosis,
                            parcelName: parcelName,
                            technicianName: technicianName,
                            additionalNotes: additionalNotes.isEmpty ? nil : additionalNotes,
                            photoUrls: []
                        )
                    } catch {
                        print("Failed to save to AIDiagnosisDataService: \(error)")
                    }

                    completion(.success(entity))
                }

            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate AI diagnosis: \(error.localizedDescription)"
                    self.showError = true
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Check Foundation Models Availability
    @MainActor
    @available(iOS 18.1, macOS 15.1, *)
    var isFoundationModelsAvailable: Bool {
        foundationModelsService.isModelAvailable
    }
    
    @MainActor
    @available(iOS 18.1, macOS 15.1, *)
    var foundationModelsAvailabilityMessage: String {
        foundationModelsService.availabilityMessage
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
