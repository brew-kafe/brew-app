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
    @Guide(description: "A comprehensive title for the plant diagnosis")
    let title: String
    
    @Guide(description: "A detailed description of the plant's current health condition based on the photo analysis")
    let detailedDescription: String
    
    @Guide(description: "The primary nutritional deficiency detected")
    let primaryDeficiency: String
    
    @Guide(description: "The specific nutrient element that is deficient")
    let deficiencyElement: String
    
    @Guide(description: "Overall health assessment")
    @Guide(.anyOf(["danger", "moderate", "optimal"]))
    let detectionState: String
    
    @Guide(description: "AI confidence level as a percentage (0-100)")
    let confidencePercentage: Double
    
    @Guide(description: "List of detailed recommendations for treatment")
    @Guide(.count(3...6))
    let recommendations: [String]
    
    @Guide(description: "Analysis of different nutritional elements")
    @Guide(.count(5...8))
    let elementAnalysis: [ElementAnalysisAI]
    
    @Guide(description: "Immediate actions that should be taken")
    @Guide(.count(2...4))
    let immediateActions: [String]
    
    @Guide(description: "Long-term care plan recommendations")
    @Guide(.count(2...3))
    let longTermCare: [String]
    
    @Guide(description: "Expected recovery timeframe")
    let expectedRecoveryTime: String
    
    @Guide(description: "Risk assessment and potential complications")
    let riskAssessment: String
}

@available(iOS 18.1, macOS 15.1, *)
@Generable
struct ElementAnalysisAI: Codable {
    @Guide(description: "The nutrient element name (e.g., Nitrogen, Phosphorus, Potassium)")
    let element: String
    
    @Guide(description: "Estimated percentage level (0-100)")
    let percentage: Double
    
    @Guide(description: "Detection state for this element")
    @Guide(.anyOf(["danger", "moderate", "optimal"]))
    let detectionState: String
    
    @Guide(description: "Specific deficiency level description")
    let deficiencyLevel: String
    
    @Guide(description: "Element-specific recommendations")
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
    
    var isModelAvailable: Bool {
        model.availability == .available
    }
    
    var availabilityMessage: String {
        switch model.availability {
        case .available:
            return "Foundation Models ready for on-device diagnosis generation"
        case .unavailable(.deviceNotEligible):
            return "This device doesn't support Apple Intelligence"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Please enable Apple Intelligence in Settings"
        case .unavailable(.modelNotReady):
            return "Model is downloading. Please try again later"
        case .unavailable(let other):
            return "Foundation Models unavailable: \(String(describing: other))"
        }
    }
    
    // MARK: - Session Setup
    
    private func setupSession() {
        guard isModelAvailable else { return }
        
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
    }
    
    // MARK: - Diagnosis Generation
    
    func generateDiagnosis(
        from photoAnalysis: [ClassificationResult],
        parcelInfo: String,
        additionalNotes: String = ""
    ) async throws -> AIGeneratedDiagnosis {
        
        guard let session = session else {
            throw DiagnosisGenerationError.modelNotAvailable
        }
        
        isGenerating = true
        generationProgress = "Analyzing photo results..."
        currentDiagnosis = nil
        error = nil
        
        let prompt = buildDiagnosisPrompt(
            photoAnalysis: photoAnalysis,
            parcelInfo: parcelInfo,
            additionalNotes: additionalNotes
        )
        
        do {
            generationProgress = "Generating comprehensive diagnosis..."
            
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
                    generationProgress = "Analyzing plant condition..."
                }
                if partialResponse.content.primaryDeficiency != nil {
                    generationProgress = "Identifying deficiencies..."
                }
                if partialResponse.content.recommendations != nil {
                    generationProgress = "Generating recommendations..."
                }
                
                // Check if this is the final complete response
                if let title = partialResponse.content.title,
                   let description = partialResponse.content.detailedDescription,
                   let deficiency = partialResponse.content.primaryDeficiency,
                   let element = partialResponse.content.deficiencyElement,
                   let state = partialResponse.content.detectionState,
                   let confidence = partialResponse.content.confidencePercentage,
                   let recommendations = partialResponse.content.recommendations,
                   let elementAnalysis = partialResponse.content.elementAnalysis,
                   let immediateActions = partialResponse.content.immediateActions,
                   let longTermCare = partialResponse.content.longTermCare,
                   let recoveryTime = partialResponse.content.expectedRecoveryTime,
                   let riskAssessment = partialResponse.content.riskAssessment {
                    
                    finalDiagnosis = AIGeneratedDiagnosis(
                        title: title,
                        detailedDescription: description,
                        primaryDeficiency: deficiency,
                        deficiencyElement: element,
                        detectionState: state,
                        confidencePercentage: confidence,
                        recommendations: recommendations,
                        elementAnalysis: elementAnalysis as! [ElementAnalysisAI],
                        immediateActions: immediateActions,
                        longTermCare: longTermCare,
                        expectedRecoveryTime: recoveryTime,
                        riskAssessment: riskAssessment
                    )
                }
            }
            
            generationProgress = "Diagnosis complete!"
            isGenerating = false
            
            guard let diagnosis = finalDiagnosis else {
                throw DiagnosisGenerationError.incompleteGeneration
            }
            
            return diagnosis
            
        } catch {
            isGenerating = false
            self.error = error
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
            "- \(result.displayName): \(String(format: "%.1f", result.confidence * 100))% confidence"
            + (result.nutrient != nil ? " (affects \(result.nutrient!))" : "")
            + " - Severity: \(result.severity)"
        }.joined(separator: "\n")
        
        return Prompt {
            """
            Please analyze this coffee plant and provide a comprehensive diagnosis.
            
            PHOTO ANALYSIS RESULTS:
            \(analysisResults)
            
            PARCEL INFORMATION:
            \(parcelInfo)
            
            ADDITIONAL OBSERVATIONS:
            \(additionalNotes.isEmpty ? "None provided" : additionalNotes)
            
            Please provide a detailed diagnosis with specific recommendations for treatment and recovery.
            Focus on the most likely nutritional deficiencies and provide actionable advice for coffee farmers.
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
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "Foundation Models not available on this device"
        case .incompleteGeneration:
            return "Diagnosis generation was incomplete"
        case .invalidPhotoAnalysis:
            return "Invalid photo analysis results"
        }
    }
}

// MARK: - Conversion Extensions

extension AIGeneratedDiagnosis {
    func toAIPlantDiagnosis(
        parcelName: String,
        technicianName: String,
        photoUrls: [String]
    ) -> AIPlantDiagnosis {
        
        let convertedElements = elementAnalysis.map { element in
            ElementAnalysis(
                element: element.element,
                percentage: element.percentage,
                detectionState: DetectionState(rawValue: element.detectionState) ?? .moderate,
                deficiencyLevel: element.deficiencyLevel,
                recommendations: element.recommendations
            )
        }
        
        return AIPlantDiagnosis(
            parcelName: parcelName,
            technicianName: technicianName,
            diagnosisDate: Date(),
            primaryDeficiency: primaryDeficiency,
            deficiencyElement: deficiencyElement,
            detectionState: DetectionState(rawValue: detectionState) ?? .moderate,
            aiDiagnosisDescription: detailedDescription,
            aiRecommendations: recommendations,
            allElements: convertedElements,
            photoUrls: photoUrls,
            aiConfidence: confidencePercentage / 100.0,
            analysisTimestamp: Date()
        )
    }
}
