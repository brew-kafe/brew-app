//
//  DiagnosisCoordinator.swift
//  brew
//
//  Created by toño on 21/10/25.
//

import Foundation
import UIKit
import SwiftData

/// Coordinates between CoreML classification and API diagnosis services
/// Handles the complete workflow of analyzing plants and saving diagnoses
@MainActor
class DiagnosisCoordinator: ObservableObject {
    static let shared = DiagnosisCoordinator()
    
    private let coreMLService = PlantDiagnosticService.shared
    private let apiService = APIDiagnosisService.shared
    
    @Published var isProcessing = false
    @Published var currentStep: ProcessingStep = .idle
    
    private init() {}
    
    enum ProcessingStep {
        case idle
        case analyzingImage
        case uploadingToAPI
        case savingLocally
        case completed
        case failed(Error)
        
        var description: String {
            switch self {
            case .idle:
                return "Listo"
            case .analyzingImage:
                return "Analizando imagen..."
            case .uploadingToAPI:
                return "Procesando con IA..."
            case .savingLocally:
                return "Guardando diagnóstico..."
            case .completed:
                return "Completado"
            case .failed(let error):
                return "Error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Complete Diagnosis Workflo    /// Performs a complete diagnosis workflow using Foundation Models: Analysis → API Creation → Local Storage
    func performCompleteDiagnosis(
        image: UIImage,
        userId: String,
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String,
        modelContext: ModelContext
    ) async throws -> DiagnosisEntity {
        print("🏥 Starting complete diagnosis workflow for user: \(userId), parcel: \(parcelName)")
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Step 1: Analyze with Foundation Models (local AI)
            print("🔍 Step 1: Analyzing image with CoreML...")
            currentStep = .analyzingImage
            let localResults = try await coreMLService.classifyImage(image)
            print("✅ CoreML analysis complete. Found \(localResults.count) results")
            
            // Convert CoreML results to diagnosis data
            let primaryResult = localResults.first ?? ClassificationResult(
                identifier: "deficiencia_general",
                confidence: 0.7,
                nutrient: "nitrogen",
                severity: "moderate",
                displayName: "Deficiencia General"
            )
            
            // Step 2: Create diagnosis request
            print("📋 Step 2: Creating API request...")
            currentStep = .uploadingToAPI
            let createRequest = DiagnosisCreateAPIRequest(
                user_id: userId,
                parcel_name: parcelName,
                plant_number: plantNumber,
                technician_name: technicianName,
                primary_deficiency: primaryResult.displayName,
                deficiency_element: primaryResult.nutrient?.capitalized ?? "Desconocido",
                detection_state: primaryResult.severity == "severe" ? "danger" : 
                                primaryResult.severity == "moderate" ? "moderate" : "optimal",
                ai_confidence: Double(primaryResult.confidence),
                ai_description: "Diagnóstico generado usando análisis de IA local. Elemento detectado: \(primaryResult.nutrient ?? "No especificado")",
                ai_recommendations: generateRecommendations(for: primaryResult.nutrient, severity: primaryResult.severity),
                all_elements: generateElementAnalysis(from: localResults),
                photo_urls: [], // Could implement photo upload separately
                notes: nil
            )
            
            // Step 3: Save to API
            print("🌐 Step 3: Saving to API...")
            let createResponse = try await apiService.createDiagnosis(request: createRequest)
            print("✅ API save successful. Remote ID: \(createResponse.id)")
            
            // Step 4: Save to local SwiftData using mapper
            print("💾 Step 4: Saving to local SwiftData...")
            currentStep = .savingLocally
            let localEntity = DiagnosisMapper.toEntity(from: createResponse)
            
            modelContext.insert(localEntity)
            try modelContext.save()
            print("✅ Local save successful. Local ID: \(localEntity.id)")
            
            currentStep = .completed
            print("🎉 Complete diagnosis workflow finished successfully!")
            return localEntity
            
        } catch {
            print("❌ Error in diagnosis workflow: \(error)")
            currentStep = .failed(error)
            throw error
        }
    }
    
    /// Creates a diagnosis directly from user input (for manual diagnoses)
    func createManualDiagnosis(
        userId: String,
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String,
        primaryDeficiency: String,
        deficiencyElement: String,
        detectionState: String,
        aiDescription: String? = nil,
        recommendations: [String] = [],
        modelContext: ModelContext
    ) async throws -> DiagnosisEntity {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            currentStep = .uploadingToAPI
            
            let createRequest = DiagnosisCreateAPIRequest(
                user_id: userId,
                parcel_name: parcelName,
                plant_number: plantNumber,
                technician_name: technicianName,
                primary_deficiency: primaryDeficiency,
                deficiency_element: deficiencyElement,
                detection_state: detectionState,
                ai_confidence: nil,
                ai_description: aiDescription,
                ai_recommendations: recommendations,
                all_elements: [],
                photo_urls: [],
                notes: nil
            )
            
            let createResponse = try await apiService.createDiagnosis(request: createRequest)
            
            currentStep = .savingLocally
            let localEntity = DiagnosisMapper.toEntity(from: createResponse)
            
            modelContext.insert(localEntity)
            try modelContext.save()
            
            currentStep = .completed
            return localEntity
            
        } catch {
            currentStep = .failed(error)
            throw error
        }
    }
    
    // MARK: - CoreML Only Analysis
    /// Performs local CoreML analysis without API call
    func performLocalAnalysis(image: UIImage) async throws -> [ClassificationResult] {
        currentStep = .analyzingImage
        defer { currentStep = .idle }
        
        return try await coreMLService.classifyImage(image)
    }
    
    // MARK: - Foundation Models Analysis
    /// Performs comprehensive AI analysis using Foundation Models (iOS 18.1+)
    @available(iOS 18.1, macOS 15.1, *)
    func performFoundationModelsAnalysis(
        image: UIImage,
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String
    ) async throws -> AIGeneratedDiagnosis {
        currentStep = .analyzingImage
        defer { currentStep = .idle }
        
        // Get initial CoreML results
        let coreMLResults = try await coreMLService.classifyImage(image)
        
        // Use Foundation Models for comprehensive analysis
        let parcelInfo = "Parcela: \(parcelName)" + 
                        (plantNumber != nil ? ", Planta: \(plantNumber!)" : "") +
                        ", Técnico: \(technicianName)"
        
        return try await FoundationModelsDiagnosisService.shared.generateDiagnosis(
            from: coreMLResults,
            parcelInfo: parcelInfo,
            additionalNotes: ""
        )
    }
    
    // MARK: - API Only Analysis (DISABLED - endpoint doesn't exist)
    /// Performs API analysis without local CoreML
    /// NOTE: This endpoint doesn't exist in the current API
    /*
    func performAPIAnalysis(
        image: UIImage,
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String
    ) async throws -> PhotoAnalysisResponse {
        currentStep = .uploadingToAPI
        defer { currentStep = .idle }
        
        return try await apiService.analyzePhoto(
            image: image,
            parcelName: parcelName,
            plantNumber: plantNumber,
            technicianName: technicianName
        )
    }
    */
    
    // MARK: - Sync Operations
    /// Fetches diagnoses from API and syncs with local database
    func syncDiagnoses(
        userId: String,
        modelContext: ModelContext
    ) async throws -> [DiagnosisEntity] {
        // Fetch from API
        let apiDiagnoses = try await apiService.fetchDiagnoses(userId: userId)
        
        // Get existing local diagnoses
        let descriptor = FetchDescriptor<DiagnosisEntity>()
        let localDiagnoses = try modelContext.fetch(descriptor)
        
        // Sync new diagnoses
        var syncedEntities: [DiagnosisEntity] = []
        
        for apiDiagnosis in apiDiagnoses {
            // Check if already exists locally
            if let existingEntity = localDiagnoses.first(where: { $0.id.uuidString == apiDiagnosis.diagnosis_id }) {
                // Update existing using mapper
                DiagnosisMapper.updateEntity(existingEntity, from: apiDiagnosis)
                syncedEntities.append(existingEntity)
            } else {
                // Create new using mapper
                let newEntity = DiagnosisMapper.toEntity(from: apiDiagnosis)
                modelContext.insert(newEntity)
                syncedEntities.append(newEntity)
            }
        }
        
        try modelContext.save()
        return syncedEntities
    }
    
    /// Deletes a diagnosis from both API and local database
    func deleteDiagnosis(
        diagnosisId: String,
        entity: DiagnosisEntity,
        modelContext: ModelContext
    ) async throws {
        // Delete from API
        try await apiService.deleteDiagnosis(diagnosisId: diagnosisId)
        
        // Delete from local database
        modelContext.delete(entity)
        try modelContext.save()
    }
    
    // MARK: - Utility Methods
    /// Fetches detection states from API
    func fetchDetectionStates() async throws -> DetectionStateResponse {
        try await apiService.getDetectionStates()
    }
    
    /// Fetches supported elements from API
    func fetchSupportedElements() async throws -> ElementListResponse {
        try await apiService.getSupportedElements()
    }
    
    // MARK: - Helper Methods
    
    /// Generates recommendations based on nutrient deficiency
    private func generateRecommendations(for nutrient: String?, severity: String) -> [String] {
        guard let nutrient = nutrient else {
            return [
                "Realizar análisis completo del suelo",
                "Consultar con especialista en nutrición vegetal",
                "Implementar plan de fertilización balanceada"
            ]
        }
        
        switch nutrient.lowercased() {
        case "nitrogen", "nitrógeno":
            if severity == "severe" {
                return [
                    "Aplicar fertilizante rico en nitrógeno inmediatamente",
                    "Implementar riego más frecuente",
                    "Monitorear el progreso semanalmente"
                ]
            } else {
                return [
                    "Aplicar fertilizante balanceado con nitrógeno",
                    "Mantener humedad del suelo estable"
                ]
            }
        case "phosphorus", "fósforo":
            return [
                "Aplicar fertilizante rico en fósforo",
                "Mejorar el drenaje del suelo",
                "Verificar pH del suelo"
            ]
        case "potassium", "potasio":
            return [
                "Aplicar fertilizante rico en potasio",
                "Incrementar riego gradualmente",
                "Monitorear síntomas en hojas"
            ]
        default:
            return [
                "Realizar análisis completo del suelo",
                "Consultar con especialista en nutrición vegetal",
                "Implementar plan de fertilización balanceada"
            ]
        }
    }
    
    /// Generates element analysis from CoreML results
    private func generateElementAnalysis(from results: [ClassificationResult]) -> [ElementAnalysisAPI] {
        return results.map { result in
            ElementAnalysisAPI(
                element: result.nutrient?.capitalized ?? "Desconocido",
                percentage: Double(result.confidence) * 100,
                detection_state: result.severity == "severe" ? "danger" : 
                               result.severity == "moderate" ? "moderate" : "optimal",
                deficiency_level: result.severity.capitalized,
                recommendations: generateRecommendations(for: result.nutrient, severity: result.severity)
            )
        }
    }
}

