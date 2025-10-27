//
//  FoundationModelsDiagnosisService.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import Foundation
@preconcurrency import FoundationModels
import UIKit

// MARK: - Generable Models for Structured Diagnosis Output

@available(iOS 18.1, macOS 15.1, *)
@Generable
struct AIGeneratedDiagnosis: Codable {
    @Guide(description: "Un título comprensivo para el diagnóstico de la planta")
    let title: String
    
    @Guide(description: "Una descripción detallada de la condición actual de salud de la planta basada en el análisis de la foto")
    let detailedDescription: String
    
    @Guide(description: "La deficiencia nutricional principal detectada")
    let primaryDeficiency: String
    
    @Guide(description: "El elemento nutriente específico que está deficiente")
    let deficiencyElement: String
    
    @Guide(description: "Evaluación general de salud")
    @Guide(.anyOf(["danger", "moderate", "optimal"]))
    let detectionState: String
    
    @Guide(description: "Nivel de confianza de la IA como porcentaje (0-100)")
    let confidencePercentage: Double
    
    @Guide(description: "Lista de recomendaciones detalladas para el tratamiento")
    @Guide(.count(3...6))
    let recommendations: [String]
    
    @Guide(description: "Análisis de diferentes elementos nutricionales")
    @Guide(.count(5...8))
    let elementAnalysis: [ElementAnalysisAI]
    
    @Guide(description: "Acciones inmediatas que deben tomarse")
    @Guide(.count(2...4))
    let immediateActions: [String]
    
    @Guide(description: "Recomendaciones del plan de cuidado a largo plazo")
    @Guide(.count(2...3))
    let longTermCare: [String]
    
    @Guide(description: "Tiempo de recuperación esperado")
    let expectedRecoveryTime: String
    
    @Guide(description: "Evaluación de riesgo y complicaciones potenciales")
    let riskAssessment: String
}

@available(iOS 18.1, macOS 15.1, *)
@Generable
struct ElementAnalysisAI: Codable {
    @Guide(description: "El nombre del elemento nutriente (ej. Nitrógeno, Fósforo, Potasio)")
    let element: String
    
    @Guide(description: "Nivel porcentual estimado (0-100)")
    let percentage: Double
    
    @Guide(description: "Estado de detección para este elemento")
    @Guide(.anyOf(["danger", "moderate", "optimal"]))
    let detectionState: String
    
    @Guide(description: "Descripción específica del nivel de deficiencia")
    let deficiencyLevel: String
    
    @Guide(description: "Recomendaciones específicas del elemento")
    @Guide(.count(1...3))
    let recommendations: [String]
    
    // Add Identifiable conformance for SwiftUI
    var id: String { element }
}

// MARK: - Foundation Models Diagnosis Service

@available(iOS 18.1, macOS 15.1, *)
@MainActor
class FoundationModelsDiagnosisService: ObservableObject {
    static let shared = FoundationModelsDiagnosisService()
    
    @Published var isGenerating = false
    @Published var generationProgress: String = ""
    @Published var currentDiagnosis: AIGeneratedDiagnosis.PartiallyGenerated?
    @Published var error: Error?
    
    private var session: LanguageModelSession?
    private let model = SystemLanguageModel.default
    
    private init() {
        setupSession()
    }
    
    // MARK: - Model Availability Check

    private var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    var isModelAvailable: Bool {
        // Apple Intelligence does NOT work on simulators
        guard !isRunningOnSimulator else {
            return false
        }
        return model.availability == .available
    }

    var availabilityMessage: String {
        // Check simulator first
        if isRunningOnSimulator {
            return """
            Apple Intelligence NO funciona en el simulador.

            Necesitas ejecutar la app en un dispositivo físico:
            • iPhone 15 Pro o más reciente
            • iOS 18.1 o superior
            • Apple Intelligence habilitado
            """
        }

        switch model.availability {
        case .available:
            return "Foundation Models listo para generación de diagnósticos en dispositivo"
        case .unavailable(.deviceNotEligible):
            return """
            Este dispositivo no es compatible con Apple Intelligence.

            Dispositivos compatibles:
            • iPhone 15 Pro o más reciente
            • iPad con M1 o más reciente
            • Mac con Apple Silicon
            """
        case .unavailable(.appleIntelligenceNotEnabled):
            return """
            Apple Intelligence no está habilitado.

            Para habilitarlo:
            1. Abre Configuración
            2. Ve a 'Apple Intelligence & Siri'
            3. Activa Apple Intelligence
            4. Espera a que el modelo se descargue
            """
        case .unavailable(.modelNotReady):
            return "El modelo se está descargando. Por favor, espera e intenta de nuevo."
        case .unavailable(let other):
            return "Foundation Models no disponible: \(String(describing: other))"
        }
    }
    
    // MARK: - Session Setup

    private func setupSession() {
        guard isModelAvailable else {
            print("⚠️ Foundation Models not available: \(availabilityMessage)")
            return
        }

        let instructions = """
        You are an expert agricultural diagnostician and plant pathologist specializing in coffee plant health analysis.

        Your role is to analyze coffee plant photos and provide comprehensive, accurate diagnoses based on:
        - Visual symptoms observed in the plant leaves, stems, and overall appearance
        - Nutritional deficiency patterns common in coffee plants
        - Environmental stress indicators
        - Disease and pest damage signs

        Guidelines for your analysis:
        - Be specific about nutritional deficiencies (N, P, K, Ca, Mg, Fe, Zn, B, Mn)
        - Provide confidence levels based on visual evidence clarity
        - Include immediate and long-term treatment recommendations
        - Consider the coffee plant's growth stage and environmental factors
        - Prioritize organic and sustainable treatment options
        - Be precise about expected recovery timeframes

        Always base your diagnosis on established agricultural science and coffee cultivation best practices.
        """

        session = LanguageModelSession(instructions: instructions)
        print("✅ Foundation Models session initialized successfully")
    }

    // MARK: - Ensure Session

    private func ensureSession() throws {
        // If session is nil, try to recreate it
        if session == nil {
            guard isModelAvailable else {
                throw DiagnosisGenerationError.modelNotAvailable
            }
            setupSession()
        }

        guard session != nil else {
            throw DiagnosisGenerationError.modelNotAvailable
        }
    }
    
    // MARK: - Diagnosis Generation
    
    func generateDiagnosis(
        from photoAnalysis: [ClassificationResult],
        parcelInfo: String,
        additionalNotes: String = ""
    ) async throws -> AIGeneratedDiagnosis {

        // Ensure session is available and initialized
        try ensureSession()

        guard let session = session else {
            throw DiagnosisGenerationError.modelNotAvailable
        }
        
        isGenerating = true
        generationProgress = "Analizando foto..."
        currentDiagnosis = nil
        error = nil
        
        let prompt = buildDiagnosisPrompt(
            photoAnalysis: photoAnalysis,
            parcelInfo: parcelInfo,
            additionalNotes: additionalNotes
        )
        
        do {
            generationProgress = "Generando diagnóstico..."

            // Use streaming for better UX
            let stream = session.streamResponse(
                to: prompt,
                generating: AIGeneratedDiagnosis.self,
                options: GenerationOptions(
                    sampling: .greedy,
                    temperature: 0.3, // Lower temperature for more consistent medical/agricultural advice
                    maximumResponseTokens: 1500
                )
            )

            var finalDiagnosis: AIGeneratedDiagnosis?

            for try await partialResponse in stream {
                currentDiagnosis = partialResponse.content
                
                // Update progress based on what fields are populated
                if partialResponse.content.title != nil {
                    generationProgress = "Analizando condición de la planta..."
                }
                if partialResponse.content.primaryDeficiency != nil {
                    generationProgress = "Identificando deficiencias..."
                }
                if partialResponse.content.recommendations != nil {
                    generationProgress = "Generando recomendaciones..."
                }
                
                // Check if this is the final complete response
                if let title = partialResponse.content.title,
                   let description = partialResponse.content.detailedDescription,
                   let deficiency = partialResponse.content.primaryDeficiency,
                   let element = partialResponse.content.deficiencyElement,
                   let state = partialResponse.content.detectionState,
                   let confidence = partialResponse.content.confidencePercentage,
                   let recommendations = partialResponse.content.recommendations,
                   let partialElementAnalysis = partialResponse.content.elementAnalysis,
                   let immediateActions = partialResponse.content.immediateActions,
                   let longTermCare = partialResponse.content.longTermCare,
                   let recoveryTime = partialResponse.content.expectedRecoveryTime,
                   let riskAssessment = partialResponse.content.riskAssessment {

                    // Convert partially generated element analysis to full structs
                    var fullElementAnalysis: [ElementAnalysisAI] = []
                    var allElementsComplete = true

                    for partialElement in partialElementAnalysis {
                        if let elemName = partialElement.element,
                           let percentage = partialElement.percentage,
                           let detectionState = partialElement.detectionState,
                           let deficiencyLevel = partialElement.deficiencyLevel,
                           let recommendations = partialElement.recommendations {

                            fullElementAnalysis.append(ElementAnalysisAI(
                                element: elemName,
                                percentage: percentage,
                                detectionState: detectionState,
                                deficiencyLevel: deficiencyLevel,
                                recommendations: recommendations
                            ))
                        } else {
                            allElementsComplete = false
                            break
                        }
                    }

                    // Only set final diagnosis if all elements are complete
                    if allElementsComplete && !fullElementAnalysis.isEmpty {
                        finalDiagnosis = AIGeneratedDiagnosis(
                            title: title,
                            detailedDescription: description,
                            primaryDeficiency: deficiency,
                            deficiencyElement: element,
                            detectionState: state,
                            confidencePercentage: confidence,
                            recommendations: recommendations,
                            elementAnalysis: fullElementAnalysis,
                            immediateActions: immediateActions,
                            longTermCare: longTermCare,
                            expectedRecoveryTime: recoveryTime,
                            riskAssessment: riskAssessment
                        )
                    }
                }
            }
            
            generationProgress = "¡Diagnóstico generado!"
            isGenerating = false
            
            guard let diagnosis = finalDiagnosis else {
                throw DiagnosisGenerationError.incompleteGeneration
            }
            
            return diagnosis
            
        } catch {
            isGenerating = false
            self.error = error

            // Check if it's the inference context error
            let errorDescription = error.localizedDescription
            print("❌ Generation error: \(errorDescription)")

            if errorDescription.contains("inference context") || errorDescription.contains("Could not create") {
                throw DiagnosisGenerationError.inferenceContextFailed
            }

            throw error
        }
    }
    
    // MARK: - Prompt Building
    
    private func buildDiagnosisPrompt(
        photoAnalysis: [ClassificationResult],
        parcelInfo: String,
        additionalNotes: String
    ) -> Prompt {
        
        let analysisResults = photoAnalysis.map { result in
            "- \(result.displayName): \(String(format: "%.1f", result.confidence * 100))% confianza"
            + (result.nutrient != nil ? " (afecta \(result.nutrient!))" : "")
            + " - Nivel de severidad: \(result.severity)"
        }.joined(separator: "\n")
        
        return Prompt {
            """
            Por favor analiza esta planta de café y proporciona un diagnóstico comprensivo.
            
            RESULTADOS DEL ANÁLISIS FOTOGRÁFICO:
            \(analysisResults)
            
            INFORMACIÓN DE LA PARCELA:
            \(parcelInfo)
            
            OBSERVACIONES ADICIONALES:
            \(additionalNotes.isEmpty ? "Ninguna proporcionada" : additionalNotes)
            
            Por favor proporciona un diagnóstico detallado con recomendaciones específicas para el tratamiento y recuperación.
            Enfócate en las deficiencias nutricionales más probables y proporciona consejos accionables para los caficultores.
            """
        }
    }
    
    // MARK: - Utility Methods
    
    func prewarmModel() {
        guard let session = session else { return }
        session.prewarm()
    }
    
    func resetGeneration() {
        isGenerating = false
        generationProgress = ""
        currentDiagnosis = nil
        error = nil
    }
}

// MARK: - Error Handling

enum DiagnosisGenerationError: LocalizedError {
    case modelNotAvailable
    case incompleteGeneration
    case invalidPhotoAnalysis
    case inferenceContextFailed

    var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "Foundation Models no disponible en este dispositivo"
        case .incompleteGeneration:
            return "La generación del diagnóstico fue incompleta"
        case .invalidPhotoAnalysis:
            return "Resultados de análisis fotográfico inválidos"
        case .inferenceContextFailed:
            return """
            Apple Intelligence no puede ejecutarse en este dispositivo.

            Requisitos:
            • iPhone 15 Pro o más reciente (dispositivo físico, NO simulador)
            • iOS 18.1 o superior
            • Apple Intelligence habilitado en Configuración
            • Región configurada a Estados Unidos

            El simulador de iOS NO soporta Apple Intelligence.
            """
        }
    }
}

// MARK: - Conversion Extensions

extension AIGeneratedDiagnosis {
    func toDiagnosisEntity(
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String,
        photoUrls: [String]
    ) -> DiagnosisEntity {
        
        let convertedElements = elementAnalysis.map { element in
            ElementAnalysis(
                element: element.element,
                percentage: element.percentage,
                detectionState: element.detectionState,
                deficiencyLevel: element.deficiencyLevel,
                recommendations: element.recommendations
            )
        }
        
        return DiagnosisEntity(
            parcelName: parcelName,
            plantNumber: plantNumber,
            technicianName: technicianName,
            primaryDeficiency: primaryDeficiency,
            deficiencyElement: deficiencyElement,
            detectionState: detectionState,
            aiConfidence: confidencePercentage / 100.0,
            aiDescription: detailedDescription,
            aiRecommendations: recommendations,
            allElements: convertedElements,
            photoURLs: photoUrls,
            diagnosisDate: Date(),
            createdAt: Date()
        )
    }
}
