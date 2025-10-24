//
//  ReportCoordinator.swift
//  brew
//
//  Created by toño on 22/10/25.
//

import Foundation
import SwiftData

/// Coordinates between API and local storage for reports
/// Handles the complete workflow of creating, fetching, and syncing reports
@MainActor
class ReportCoordinator: ObservableObject {
    static let shared = ReportCoordinator()
    
    private let apiService = APIReportService.shared
    private let dataService = ReportDataService.shared
    
    @Published var isProcessing = false
    @Published var currentStep: ProcessingStep = .idle
    
    private init() {}
    
    enum ProcessingStep {
        case idle
        case creatingReport
        case fetchingReports
        case syncingData
        case deletingReport
        case completed
        case failed(Error)
        
        var description: String {
            switch self {
            case .idle:
                return "Listo"
            case .creatingReport:
                return "Creando reporte..."
            case .fetchingReports:
                return "Obteniendo reportes..."
            case .syncingData:
                return "Sincronizando..."
            case .deletingReport:
                return "Eliminando reporte..."
            case .completed:
                return "Completado"
            case .failed(let error):
                return "Error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Create Report
    /// Creates a report in API and saves locally
    func createReport(
        userId: UUID,
        title: String,
        diagnosisIds: [UUID],
        parcelId: Int? = nil,
        reportType: ReportType = .nutrition,
        notes: String? = nil,
        performanceScore: Double? = nil,
        modelContext: ModelContext
    ) async throws -> ReportEntity {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            currentStep = .creatingReport
            
            // Create request
            let request = ReportCreateRequest(
                title: title,
                userId: userId,
                diagnosisIds: diagnosisIds,
                parcelId: parcelId,
                reportType: reportType.rawValue,
                notes: notes,
                performanceScore: performanceScore
            )
            
            // Send to API
            let apiResponse = try await apiService.createReport(
                userId: userId,
                request: request
            )
            
            // Save locally
            currentStep = .syncingData
            let localEntity = ReportMapper.toEntity(from: apiResponse)
            modelContext.insert(localEntity)
            try modelContext.save()
            
            currentStep = .completed
            return localEntity
            
        } catch {
            currentStep = .failed(error)
            throw error
        }
    }
    
    // MARK: - Fetch Reports
    /// Fetches reports from API and syncs with local database
    func fetchAndSyncReports(
        userId: UUID,
        modelContext: ModelContext
    ) async throws -> [ReportEntity] {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            currentStep = .fetchingReports
            
            // Fetch from API
            let apiReports = try await apiService.fetchReports(userId: userId)
            
            currentStep = .syncingData
            
            // Get existing local reports
            let descriptor = FetchDescriptor<ReportEntity>(
                predicate: #Predicate { $0.userId == userId }
            )
            let localReports = try modelContext.fetch(descriptor)
            
            // Sync new reports
            var syncedEntities: [ReportEntity] = []
            
            for apiReport in apiReports {
                // Check if already exists locally
                if let existingEntity = localReports.first(where: { $0.id == apiReport.reportId }) {
                    // Update existing
                    ReportMapper.updateEntity(existingEntity, from: apiReport)
                    syncedEntities.append(existingEntity)
                } else {
                    // Create new
                    let newEntity = ReportMapper.toEntity(from: apiReport)
                    modelContext.insert(newEntity)
                    syncedEntities.append(newEntity)
                }
            }
            
            try modelContext.save()
            
            currentStep = .completed
            return syncedEntities
            
        } catch {
            currentStep = .failed(error)
            throw error
        }
    }
    
    // MARK: - Fetch Single Report with Diagnoses
    /// Fetches a specific report with its diagnoses from API
    func fetchReportWithDiagnoses(reportId: Int) async throws -> ReportWithDiagnosesAPI {
        currentStep = .fetchingReports
        defer { currentStep = .idle }
        
        return try await apiService.fetchReportWithDiagnoses(reportId: reportId)
    }
    
    // MARK: - Delete Report
    /// Deletes a report from both API and local database
    func deleteReport(
        reportId: Int,
        entity: ReportEntity,
        modelContext: ModelContext
    ) async throws {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            currentStep = .deletingReport
            
            // Delete from API
            try await apiService.deleteReport(reportId: reportId)
            
            // Delete locally
            modelContext.delete(entity)
            try modelContext.save()
            
            currentStep = .completed
            
        } catch {
            currentStep = .failed(error)
            throw error
        }
    }
    
    // MARK: - Link Diagnosis to Report
    /// Links an existing diagnosis to a report
    func linkDiagnosisToReport(
        reportId: Int,
        diagnosisId: UUID
    ) async throws {
        try await apiService.linkDiagnosisToReport(
            reportId: reportId,
            diagnosisId: diagnosisId
        )
    }
}

// MARK: - Report Mapper
/// Maps between API models and local SwiftData models
struct ReportMapper {
    
    /// Convert API response to local entity
    static func toEntity(from apiResponse: ReportAPIResponse) -> ReportEntity {
        return ReportEntity(
            id: apiResponse.reportId,
            title: apiResponse.title,
            userId: apiResponse.userId,
            parcelId: apiResponse.parcelId,
            reportType: apiResponse.reportType,
            reportDate: apiResponse.reportDate,
            notes: apiResponse.notes,
            performanceScore: apiResponse.performanceScore,
            diagnosisCount: apiResponse.diagnosisCount,
            createdAt: apiResponse.createdAt
        )
    }
    
    /// Update entity from API response
    static func updateEntity(
        _ entity: ReportEntity,
        from apiResponse: ReportAPIResponse
    ) {
        entity.title = apiResponse.title
        entity.parcelId = apiResponse.parcelId
        entity.reportType = apiResponse.reportType
        entity.reportDate = apiResponse.reportDate
        entity.notes = apiResponse.notes
        entity.performanceScore = apiResponse.performanceScore
        entity.diagnosisCount = apiResponse.diagnosisCount
    }
}
