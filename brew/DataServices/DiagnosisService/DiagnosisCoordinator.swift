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
    
    // MARK: - Complete Diagnosis Workflow
    /// Performs a complete diagnosis workflow: API → Local Storage
    func performCompleteDiagnosis(
        image: UIImage,
        userId: String,
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String,
        modelContext: ModelContext
    ) async throws -> DiagnosisEntity {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Step 1: Analyze with API (includes AI processing)
            currentStep = .uploadingToAPI
            let apiResponse = try await apiService.analyzePhoto(
                image: image,
                parcelName: parcelName,
                plantNumber: plantNumber,
                technicianName: technicianName
            )
            
            // Step 2: Create diagnosis request using mapper
            let createRequest = DiagnosisMapper.toCreateRequest(
                from: apiResponse,
                userId: userId,
                parcelName: parcelName,
                plantNumber: plantNumber,
                technicianName: technicianName
            )
            
            // Step 3: Save to API
            let createResponse = try await apiService.createDiagnosis(userId: userId, request: createRequest)
            
            // Step 4: Save to local SwiftData using mapper
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
    
    // MARK: - API Only Analysis
    /// Performs API analysis without local CoreML
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
        userId: String,
        diagnosisId: String,
        entity: DiagnosisEntity,
        modelContext: ModelContext
    ) async throws {
        // Delete from API
        try await apiService.deleteDiagnosis(userId: userId, diagnosisId: diagnosisId)
        
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
}

